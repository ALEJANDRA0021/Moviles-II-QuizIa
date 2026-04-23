//
//  ManualViewController.swift
//  Proyecto_QuizIa
//
//  Created by Miguel on 22/4/26.
//

import UIKit

class ManualViewController: UIViewController {

        private let txt_nombre = UITextField()
        private let txt_pregunta = UITextField()
        private let sw_respuesta = UISwitch()
        private let btn_guardar = UIButton(type: .system)
        private let btn_terminar = UIButton(type: .system) // Nuevo botón

        // Variable para saber a qué quiz le estamos metiendo preguntas
        var id_quiz_activo: Int64 = 0

        override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = .systemBackground
                title = "Crear Quiz"
                configurarInterfaz()
        }

        /**
         * Entradas: Ninguna
         * Salidas: Componentes visuales en pantalla
         * Valor de retorno: Ninguno
         * Función: Dibuja los campos de texto y botones programáticamente
         * Variables: txt_nombre, txt_pregunta, sw_respuesta, btn_guardar, btn_terminar
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: Ninguna
         */
        private func configurarInterfaz() {
                // Configuración de elementos (código original de Alejandra adaptado)
                txt_nombre.placeholder = "Nombre del Quiz (ej. Historia)"
                txt_nombre.borderStyle = .roundedRect
                txt_nombre.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(txt_nombre)

                txt_pregunta.placeholder = "Escribe la pregunta"
                txt_pregunta.borderStyle = .roundedRect
                txt_pregunta.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(txt_pregunta)

                let lbl_switch = UILabel()
                lbl_switch.text = "¿La respuesta correcta es Verdadero?"
                lbl_switch.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(lbl_switch)

                sw_respuesta.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(sw_respuesta)

                btn_guardar.setTitle("Comenzar Nuevo Quiz", for: .normal)
                btn_guardar.translatesAutoresizingMaskIntoConstraints = false
                btn_guardar.addTarget(self, action: #selector(accionGuardar), for: .touchUpInside)
                view.addSubview(btn_guardar)

                btn_terminar.setTitle("Terminar y Salir", for: .normal)
                btn_terminar.setTitleColor(.systemRed, for: .normal)
                btn_terminar.translatesAutoresizingMaskIntoConstraints = false
                btn_terminar.addTarget(self, action: #selector(accionTerminar), for: .touchUpInside)
                btn_terminar.isHidden = true // Se oculta hasta que haya un quiz activo
                view.addSubview(btn_terminar)

                // Posiciones (Constraints)
                NSLayoutConstraint.activate([
                        txt_nombre.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                        txt_nombre.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        txt_nombre.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                        txt_pregunta.topAnchor.constraint(equalTo: txt_nombre.bottomAnchor, constant: 20),
                        txt_pregunta.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        txt_pregunta.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                        lbl_switch.topAnchor.constraint(equalTo: txt_pregunta.bottomAnchor, constant: 20),
                        lbl_switch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

                        sw_respuesta.centerYAnchor.constraint(equalTo: lbl_switch.centerYAnchor),
                        sw_respuesta.leadingAnchor.constraint(equalTo: lbl_switch.trailingAnchor, constant: 10),

                        btn_guardar.topAnchor.constraint(equalTo: lbl_switch.bottomAnchor, constant: 40),
                        btn_guardar.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                        btn_terminar.topAnchor.constraint(equalTo: btn_guardar.bottomAnchor, constant: 20),
                        btn_terminar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
        }

        /**
         * Entradas: Ninguna
         * Salidas: Datos guardados en SQLite
         * Valor de retorno: Ninguno
         * Función: Crea el quiz si no existe, y le anexa la pregunta escrita
         * Variables: id_quiz_activo, nombre, texto_pregunta
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: insertarQuiz, insertarPregunta
         */
        @objc private func accionGuardar() {
                guard let nombre = txt_nombre.text, !nombre.isEmpty,
                      let texto_pregunta = txt_pregunta.text, !texto_pregunta.isEmpty else {
                        mostrarAlerta(titulo: "Error", mensaje: "Completa todos los campos")
                        return
                }

                // Si es un quiz nuevo, primero lo creamos
                if id_quiz_activo == 0 {
                        if let nuevo_id = SQLiteManager.shared.insertarQuiz(nombre: nombre, categoria: "General") {
                                id_quiz_activo = nuevo_id
                                
                                // Cambiamos la interfaz visualmente
                                txt_nombre.isEnabled = false // Bloqueamos el nombre
                                txt_nombre.backgroundColor = .systemGray6
                                btn_guardar.setTitle("Guardar Pregunta", for: .normal)
                                btn_terminar.isHidden = false // Mostramos botón de salir
                        }
                }

                // Guardamos la pregunta anexada a ese ID
                if id_quiz_activo != 0 {
                        let respuesta = sw_respuesta.isOn ? "Verdadero" : "Falso"
                        let exito = SQLiteManager.shared.insertarPregunta(
                                idQuiz: id_quiz_activo, tipo: "verdadero_falso", texto: texto_pregunta,
                                opA: "Verdadero", opB: "Falso", opC: nil, opD: nil, respuesta: respuesta
                        )

                        if exito == true {
                                mostrarAlerta(titulo: "Éxito", mensaje: "Pregunta anexada al quiz")
                                txt_pregunta.text = "" // Limpiamos solo la pregunta
                                sw_respuesta.isOn = false
                        }
                }
        }

        /**
         * Entradas: Ninguna
         * Salidas: Interfaz reiniciada
         * Valor de retorno: Ninguno
         * Función: Reinicia las variables y limpia los campos para un nuevo quiz
         * Variables: id_quiz_activo, txt_nombre, txt_pregunta
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: Ninguna
         */
        @objc private func accionTerminar() {
                id_quiz_activo = 0
                txt_nombre.isEnabled = true
                txt_nombre.backgroundColor = .clear
                txt_nombre.text = ""
                txt_pregunta.text = ""
                btn_guardar.setTitle("Comenzar Nuevo Quiz", for: .normal)
                btn_terminar.isHidden = true
                
                // Opcional: Regresamos al usuario a la primera pestaña
                self.tabBarController?.selectedIndex = 0
        }

        private func mostrarAlerta(titulo: String, mensaje: String) {
                let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }
}
