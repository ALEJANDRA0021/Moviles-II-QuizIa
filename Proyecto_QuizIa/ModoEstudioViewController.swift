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

        // Variables de control siguiendo la rúbrica MMS
        var id_quiz_actual: Int = 0
        var lista_preguntas: [(id: Int64, texto: String, respuesta: String)] = []
        var indice_actual: Int = 0

        override func viewDidLoad() {
                super.viewDidLoad()
                // Limpiamos el texto inicial para evitar el efecto "label"
                label_feedback.text = ""
                cargarDatosCompletos()
        }

        /**
         * Entradas: Ninguna
         * Salidas: Carga de preguntas en memoria
         * Valor de retorno: Ninguno
         * Función: Recupera todas las preguntas de la BD y muestra la primera
         * Variables: lista_preguntas, indice_actual
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: obtenerPreguntas()
         */
        func cargarDatosCompletos() {
                lista_preguntas = SQLiteManager.shared.obtenerPreguntas(idQuiz: id_quiz_actual)
                
                if lista_preguntas.isEmpty == false {
                        actualizarPantalla()
                } else {
                        label_pregunta.text = "Este quiz no tiene preguntas aún."
                }
        }

        /**
         * Entradas: Ninguna
         * Salidas: Cambio de textos en la interfaz
         * Valor de retorno: Ninguno
         * Función: Refresca los componentes según el índice actual de la lista
         * Variables: item_actual, label_pregunta, label_feedback
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: Ninguna
         */
        func actualizarPantalla() {
                let item_actual = lista_preguntas[indice_actual]
                label_pregunta.text = item_actual.texto
                label_feedback.text = "Pregunta \(indice_actual + 1) de \(lista_preguntas.count)"
                label_feedback.textColor = .secondaryLabel
                
                // Lógica de habilitar/deshabilitar botones sin usar switch
                btn_anterior.isEnabled = (indice_actual > 0)
                btn_siguiente.isEnabled = (indice_actual < lista_preguntas.count - 1)
        }

        @IBAction func btnSiguientePresionado(_ sender: UIButton) {
                if indice_actual < lista_preguntas.count - 1 {
                        indice_actual += 1
                        actualizarPantalla()
                }
        }

        @IBAction func btnAnteriorPresionado(_ sender: UIButton) {
                if indice_actual > 0 {
                        indice_actual -= 1
                        actualizarPantalla()
                }
        }

        @IBAction func btnVerdaderoPresionado(_ sender: UIButton) {
                verificarRespuesta(eleccion: "Verdadero")
        }

        @IBAction func btnFalsoPresionado(_ sender: UIButton) {
                verificarRespuesta(eleccion: "Falso")
        }

        func verificarRespuesta(eleccion: String) {
                let respuesta_real = lista_preguntas[indice_actual].respuesta
                
                if eleccion == respuesta_real {
                        label_feedback.text = "¡Correcto!"
                        label_feedback.textColor = .systemGreen
                } else {
                        label_feedback.text = "Incorrecto"
                        label_feedback.textColor = .systemRed
                }
        }
}
