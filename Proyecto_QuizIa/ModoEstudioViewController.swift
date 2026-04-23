//
//  ModoEstudioViewController.swift
//  Proyecto_QuizIa
//
//  Created by Miguel on 22/4/26.
//

import UIKit

class ModoEstudioViewController: UIViewController {

        @IBOutlet weak var label_pregunta: UILabel!
        @IBOutlet weak var label_feedback: UILabel!
        @IBOutlet weak var btn_siguiente: UIButton!
        @IBOutlet weak var btn_anterior: UIButton!
        
        // Los 4 botones de respuesta
        @IBOutlet weak var btn_opcion_a: UIButton!
        @IBOutlet weak var btn_opcion_b: UIButton!
        @IBOutlet weak var btn_opcion_c: UIButton!
        @IBOutlet weak var btn_opcion_d: UIButton!

        // Variables de control (Rúbrica MMS)
        var id_quiz_actual: Int = 0
        var lista_preguntas: [(id: Int64, tipo: String, texto: String, opA: String, opB: String, opC: String?, opD: String?, respuesta: String)] = []
        var indice_actual: Int = 0

        override func viewDidLoad() {
                super.viewDidLoad()
                label_feedback.text = ""
                cargarDatosCompletos()
        }

        /**
         * Entradas: Ninguna
         * Salidas: Carga de datos desde SQLiteManager
         * Valor de retorno: Ninguno
         * Función: Recupera todas las preguntas del quiz y llena el arreglo
         * Variables: lista_preguntas
         * Fecha: 23-04-2026
         * Autor: Miguel Alexander Córdova Torres
         */
    func cargarDatosCompletos() {
                    lista_preguntas = SQLiteManager.shared.obtenerPreguntasDetalladas(idQuiz: id_quiz_actual)
                    
                    if lista_preguntas.isEmpty == false {
                            // Si hay preguntas, los botones se configuran normal
                            btn_opcion_a.isHidden = false
                            btn_opcion_b.isHidden = false
                            actualizarPantalla()
                    } else {
                            // Si no hay preguntas, escondemos todo el peligro
                            label_pregunta.text = "No hay preguntas válidas en este quiz."
                            btn_opcion_a.isHidden = true
                            btn_opcion_b.isHidden = true
                            btn_opcion_c.isHidden = true
                            btn_opcion_d.isHidden = true
                            btn_siguiente.isEnabled = false
                            btn_anterior.isEnabled = false
                    }
            }        /**
         * Entradas: Ninguna
         * Salidas: Interfaz adaptada al tipo de pregunta
         * Valor de retorno: Ninguno
         * Función: Muestra u oculta botones y cambia sus textos según el tipo
         * Variables: item_actual, tipo
         * Fecha: 23-04-2026
         * Autor: Miguel Alexander Córdova Torres
         */
        func actualizarPantalla() {
                let item_actual = lista_preguntas[indice_actual]
                label_pregunta.text = item_actual.texto
                
                // Si es múltiple, mostramos los 4 botones
                if item_actual.tipo == "multiple" {
                        btn_opcion_a.setTitle(item_actual.opA, for: .normal)
                        btn_opcion_b.setTitle(item_actual.opB, for: .normal)
                        btn_opcion_c.setTitle(item_actual.opC ?? "", for: .normal)
                        btn_opcion_d.setTitle(item_actual.opD ?? "", for: .normal)
                        
                        btn_opcion_c.isHidden = false
                        btn_opcion_d.isHidden = false
                } else {
                        // Si es V/F, solo usamos los primeros dos y escondemos el resto
                        btn_opcion_a.setTitle("Verdadero", for: .normal)
                        btn_opcion_b.setTitle("Falso", for: .normal)
                        
                        btn_opcion_c.isHidden = true
                        btn_opcion_d.isHidden = true
                }
                
                // Control de navegación
                btn_anterior.isEnabled = (indice_actual > 0)
                btn_siguiente.isEnabled = (indice_actual < lista_preguntas.count - 1)
        }

        @IBAction func accionRespuestaPresionada(_ sender: UIButton) {
                // Obtenemos el texto del botón que el usuario tocó
                guard let eleccion = sender.title(for: .normal) else { return }
                verificarRespuesta(eleccion: eleccion)
        }

    func verificarRespuesta(eleccion: String) {
                    // SEGURO: Si la lista está vacía, no hace nada y evita el crash
                    guard lista_preguntas.isEmpty == false else { return }
                    
                    let respuesta_real = lista_preguntas[indice_actual].respuesta
                    
                    if eleccion == respuesta_real {
                            label_feedback.text = "¡Correcto!"
                            label_feedback.textColor = .systemGreen
                    } else {
                            label_feedback.text = "Incorrecto"
                            label_feedback.textColor = .systemRed
                    }
            }        // MARK: - Navegación
        @IBAction func btnSiguientePresionado(_ sender: UIButton) {
                if indice_actual < lista_preguntas.count - 1 {
                        indice_actual += 1
                        label_feedback.text = "" // Limpiar feedback al pasar
                        actualizarPantalla()
                }
        }

        @IBAction func btnAnteriorPresionado(_ sender: UIButton) {
                if indice_actual > 0 {
                        indice_actual -= 1
                        label_feedback.text = ""
                        actualizarPantalla()
                }
        }
}
