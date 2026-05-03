//
//  GroqManager.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import Foundation

/*
 * Función:    GroqManager (class)
 * Autor:      QuizIA Team
 * Fecha:      01/05/2026
 * Entradas:   Texto de PDF, cantidad de preguntas deseadas
 * Salidas:    Array de Pregunta generadas por IA (vía Result)
 * Retorno:    GroqManager
 * Variables:  api_key, base_url, model, shared
 * Rutinas:    generateQuestions, parseQuestions, GroqError
 * Descripción: Gestiona la comunicación con la API de Groq para
 *              generar preguntas automáticas a partir de texto PDF.
 *              Incluye logs de depuración, parseo tolerante y errores específicos.
 */
class GroqManager {

    static let shared = GroqManager()

    // ⚠️ REEMPLAZA con tu API key real (la que compartiste queda comprometida, genera una nueva)
    private let api_key  = "La api es dato que no debe subirse a lugares publicos"
    private let base_url = "https://api.groq.com/openai/v1/chat/completions"
    private let model    = "llama-3.1-8b-instant"  // también puedes probar "mixtral-8x7b-32768"

    private init() {}

    /*
     * Función:    generateQuestions
     * Autor:      QuizIA Team
     * Fecha:      01/05/2026
     * Entradas:   text: String, count: Int,
     *             completion: @escaping (Result<[Pregunta], Error>) -> Void
     * Salidas:    Resultado con [Pregunta] o Error
     * Retorno:    Void
     * Variables:  trimmed, prompt, body, url, jsonData, request
     * Rutinas:    URLSession.dataTask, parseQuestions
     * Descripción: Llama a la API de Groq, decodifica la respuesta y
     *              retorna las preguntas o un error descriptivo.
     */
    func generateQuestions(
        from text: String,
        count: Int = 5,
        completion: @escaping (Result<[Pregunta], Error>) -> Void
    ) {
        // 1. Limitar texto para no exceder tokens
        let trimmed = String(text.prefix(3500))

        // 2. Construir el prompt (más firme para obtener solo JSON)
        let prompt = """
        Eres un asistente educativo experto. Genera exactamente \(count) preguntas \
        de opción múltiple basadas en el siguiente texto.

        Devuelve ÚNICAMENTE un array JSON válido, sin ningún otro texto, \
        sin bloques de código, sin explicaciones. El formato debe ser exactamente:
        [
          {
            "texto_pregunta": "¿Pregunta aquí?",
            "opcion_a": "Primera opción",
            "opcion_b": "Segunda opción",
            "opcion_c": "Tercera opción",
            "opcion_d": "Cuarta opción",
            "respuesta_correcta": "La opción correcta exactamente como aparece"
          }
        ]

        TEXTO:
        \(trimmed)
        """

        let body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 2500,
            "temperature": 0.3
        ]

        guard let url = URL(string: base_url),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(GroqError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(api_key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 30

        print("🟠 Enviando solicitud a Groq...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Error de red
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            // Validar respuesta HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(GroqError.invalidResponse)) }
                return
            }

            print("🔵 Código HTTP: \(httpResponse.statusCode)")

            // Leer el cuerpo (sea éxito o error)
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(GroqError.noData)) }
                return
            }

            if let rawString = String(data: data, encoding: .utf8) {
                print("🟢 Respuesta cruda:\n\(rawString)")
            }

            // Manejar códigos de error HTTP
            guard (200...299).contains(httpResponse.statusCode) else {
                let bodyStr = String(data: data, encoding: .utf8) ?? ""
                let msg = "Error HTTP \(httpResponse.statusCode): \(bodyStr)"
                DispatchQueue.main.async {
                    completion(.failure(GroqError.httpError(statusCode: httpResponse.statusCode, body: msg)))
                }
                return
            }

            // Parsear JSON de Groq
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let message = first["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                DispatchQueue.main.async { completion(.failure(GroqError.parsingError(message: "No se encontró 'choices[0].message.content' en la respuesta")) )
                }
                return
            }

            print("🟡 Contenido del mensaje:\n\(content)")

            let preguntas = self.parseQuestions(from: content)
            DispatchQueue.main.async { completion(.success(preguntas)) }
        }.resume()
    }

    /*
     * Función:    parseQuestions
     * Autor:      QuizIA Team
     * Fecha:      01/05/2026
     * Entradas:   text: String (contenido del mensaje de la IA)
     * Salidas:    [Pregunta]
     * Retorno:    [Pregunta]
     * Variables:  jsonStr, start, end, cleaned, data, arr
     * Rutinas:    JSONSerialization, compactMap
     * Descripción: Extrae el array JSON del contenido (incluso si está
     *              envuelto en ```json) y lo convierte en structs Pregunta.
     */
    private func parseQuestions(from text: String) -> [Pregunta] {
        var jsonStr = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Quitar bloques de código Markdown (ej: ```json ... ```)
        jsonStr = jsonStr
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")

        // Encontrar el primer '[' y el último ']'
        guard let start = jsonStr.firstIndex(of: "["),
              let end = jsonStr.lastIndex(of: "]") else {
            print("⚠️ No se encontró un array JSON en la respuesta")
            return []
        }

        let cleaned = String(jsonStr[start...end])

        guard let data = cleaned.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("⚠️ No se pudo parsear el JSON del array")
            return []
        }

        return arr.compactMap { dict -> Pregunta? in
            guard let texto = dict["texto_pregunta"] as? String,
                  let a = dict["opcion_a"] as? String,
                  let b = dict["opcion_b"] as? String,
                  let c = dict["opcion_c"] as? String,
                  let d = dict["opcion_d"] as? String,
                  let resp = dict["respuesta_correcta"] as? String else {
                print("⚠️ Elemento JSON incompleto: \(dict)")
                return nil
            }
            return Pregunta(
                id_quiz: 0,
                tipo_pregunta: "multiple",
                texto_pregunta: texto,
                opcion_a: a, opcion_b: b,
                opcion_c: c, opcion_d: d,
                respuesta_correcta: resp
            )
        }
    }

    // MARK: - Errores personalizados
    enum GroqError: Error, LocalizedError {
        case invalidRequest
        case invalidResponse
        case httpError(statusCode: Int, body: String)
        case noData
        case parsingError(message: String)

        var errorDescription: String? {
            switch self {
            case .invalidRequest:
                return "No se pudo crear la solicitud."
            case .invalidResponse:
                return "Respuesta del servidor no válida."
            case .httpError(let code, let body):
                return "Error HTTP \(code). Respuesta: \(body)"
            case .noData:
                return "No se recibieron datos del servidor."
            case .parsingError(let msg):
                return "Error al procesar la respuesta: \(msg)"
            }
        }
    }
}
