//
//  Pregunta.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import Foundation

/*
 * Función:    Pregunta (struct)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   id_pregunta, id_quiz, tipo_pregunta, texto_pregunta,
 *             opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta
 * Salidas:    Instancia de Pregunta
 * Retorno:    Pregunta
 * Variables:  todos los campos del struct
 * Rutinas:    Ninguna
 * Descripción: Modelo de datos que representa una pregunta de un quiz
 */
struct Pregunta {
        var id_pregunta: Int
        var id_quiz: Int
        var tipo_pregunta: String        // "multiple" | "verdadero_falso"
        var texto_pregunta: String
        var opcion_a: String
        var opcion_b: String
        var opcion_c: String             // Vacío si es verdadero_falso
        var opcion_d: String             // Vacío si es verdadero_falso
        var respuesta_correcta: String

        init(
                id_pregunta: Int = 0,
                id_quiz: Int,
                tipo_pregunta: String,
                texto_pregunta: String,
                opcion_a: String,
                opcion_b: String,
                opcion_c: String = "",
                opcion_d: String = "",
                respuesta_correcta: String
        ) {
                self.id_pregunta = id_pregunta
                self.id_quiz = id_quiz
                self.tipo_pregunta = tipo_pregunta
                self.texto_pregunta = texto_pregunta
                self.opcion_a = opcion_a
                self.opcion_b = opcion_b
                self.opcion_c = opcion_c
                self.opcion_d = opcion_d
                self.respuesta_correcta = respuesta_correcta
        }

        /*
         * Función:    allOptions
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Array de opciones no vacías
         * Retorno:    [String]
         * Variables:  opts
         * Rutinas:    filter
         * Descripción: Retorna solo las opciones que tienen contenido
         */
        func allOptions() -> [String] {
                let opts = [opcion_a, opcion_b, opcion_c, opcion_d]
                return opts.filter { !$0.isEmpty }
        }
}

