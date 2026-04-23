//
//  ManualViewController.swift
//  Proyecto_QuizIa
//
//  Created by Miguel on 22/4/26.
//

import UIKit

class ManualViewController: UIViewController {

        private let nombreTextField = UITextField()
        private let preguntaTextField = UITextField()
        
        // Selector de tipo de pregunta
        private let tipoPreguntaSegmented = UISegmentedControl(items: ["Verdadero/Falso", "Opción Múltiple"])
        
        // Elementos para V/F
        private let switchLabel = UILabel()
        private let respuestaCorrectaSwitch = UISwitch()
        
        // Elementos para Opción Múltiple
        private let txtOpcionA = UITextField()
        private let txtOpcionB = UITextField()
        private let txtOpcionC = UITextField()
        private let txtOpcionD = UITextField()
        private let selectorRespuestaCorrecta = UISegmentedControl(items: ["A", "B", "C", "D"])
        
        private let guardarButton = UIButton(type: .system)
        private let terminarButton = UIButton(type: .system)

        var id_quiz_activo: Int64 = 0

        override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = .systemBackground
                title = "Crear Quiz"
                setupUI()
                
                // Configuración inicial del selector
                tipoPreguntaSegmented.selectedSegmentIndex = 0
                tipoPreguntaSegmented.addTarget(self, action: #selector(cambioTipoPregunta), for: .valueChanged)
                cambioTipoPregunta() // Forzar la vista inicial
        }

        /**
         * Entradas: Ninguna
         * Salidas: Elementos mostrados en pantalla
         * Valor de retorno: Ninguno
         * Función: Configura y posiciona todos los elementos visuales
         * Variables: Elementos de UI
         * Fecha: 23-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: Ninguna
         */
        private func setupUI() {
                let elementos = [nombreTextField, preguntaTextField, tipoPreguntaSegmented, switchLabel, respuestaCorrectaSwitch, txtOpcionA, txtOpcionB, txtOpcionC, txtOpcionD, selectorRespuestaCorrecta, guardarButton, terminarButton]
                
                for elemento in elementos {
                        elemento.translatesAutoresizingMaskIntoConstraints = false
                        if let textField = elemento as? UITextField {
                                textField.borderStyle = .roundedRect
                        }
                        view.addSubview(elemento)
                }

                nombreTextField.placeholder = "Nombre del Quiz (ej. Historia)"
                preguntaTextField.placeholder = "Escribe la pregunta"
                switchLabel.text = "¿La respuesta correcta es Verdadero?"
                
                txtOpcionA.placeholder = "Opción A (Ej. París)"
                txtOpcionB.placeholder = "Opción B (Ej. Londres)"
                txtOpcionC.placeholder = "Opción C (Ej. Madrid)"
                txtOpcionD.placeholder = "Opción D (Ej. Roma)"
                selectorRespuestaCorrecta.selectedSegmentIndex = 0

                guardarButton.setTitle("Crear Quiz y Guardar Pregunta 1", for: .normal)
                guardarButton.addTarget(self, action: #selector(guardarLogica), for: .touchUpInside)

                terminarButton.setTitle("Terminar Quiz", for: .normal)
                terminarButton.setTitleColor(.systemRed, for: .normal)
                terminarButton.addTarget(self, action: #selector(terminarQuiz), for: .touchUpInside)
                terminarButton.isHidden = true

                // Constraints (Posiciones)
                NSLayoutConstraint.activate([
                        nombreTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                        nombreTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        nombreTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                        preguntaTextField.topAnchor.constraint(equalTo: nombreTextField.bottomAnchor, constant: 15),
                        preguntaTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        preguntaTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                        tipoPreguntaSegmented.topAnchor.constraint(equalTo: preguntaTextField.bottomAnchor, constant: 15),
                        tipoPreguntaSegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        tipoPreguntaSegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                        // Constraints V/F
                        switchLabel.topAnchor.constraint(equalTo: tipoPreguntaSegmented.bottomAnchor, constant: 20),
                        switchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        respuestaCorrectaSwitch.centerYAnchor.constraint(equalTo: switchLabel.centerYAnchor),
                        respuestaCorrectaSwitch.leadingAnchor.constraint(equalTo: switchLabel.trailingAnchor, constant: 10),

                        // Constraints Múltiple
                        txtOpcionA.topAnchor.constraint(equalTo: tipoPreguntaSegmented.bottomAnchor, constant: 15),
                        txtOpcionA.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        txtOpcionA.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                        
                        txtOpcionB.topAnchor.constraint(equalTo: txtOpcionA.bottomAnchor, constant: 10),
                        txtOpcionB.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        txtOpcionB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                        
                        txtOpcionC.topAnchor.constraint(equalTo: txtOpcionB.bottomAnchor, constant: 10),
                        txtOpcionC.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        txtOpcionC.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                        
                        txtOpcionD.topAnchor.constraint(equalTo: txtOpcionC.bottomAnchor, constant: 10),
                        txtOpcionD.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        txtOpcionD.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                        
                        selectorRespuestaCorrecta.topAnchor.constraint(equalTo: txtOpcionD.bottomAnchor, constant: 15),
                        selectorRespuestaCorrecta.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                        selectorRespuestaCorrecta.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                        guardarButton.bottomAnchor.constraint(equalTo: terminarButton.topAnchor, constant: -15),
                        guardarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                        terminarButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                        terminarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
        }

        /**
         * Entradas: Ninguna
         * Salidas: Modificación visual de componentes
         * Valor de retorno: Ninguno
         * Función: Oculta o muestra campos dependiendo del tipo de pregunta elegido
         * Variables: tipoPreguntaSegmented
         * Fecha: 23-04-2026
         * Autor: Miguel Alexander Córdova Torres
         */
        @objc private func cambioTipoPregunta() {
                let esMultiple = tipoPreguntaSegmented.selectedSegmentIndex == 1
                
                // Ocultar/Mostrar V/F
                switchLabel.isHidden = esMultiple
                respuestaCorrectaSwitch.isHidden = esMultiple
                
                // Ocultar/Mostrar Múltiple
                txtOpcionA.isHidden = !esMultiple
                txtOpcionB.isHidden = !esMultiple
                txtOpcionC.isHidden = !esMultiple
                txtOpcionD.isHidden = !esMultiple
                selectorRespuestaCorrecta.isHidden = !esMultiple
        }

        /**
         * Entradas: Ninguna
         * Salidas: Inserción en base de datos
         * Valor de retorno: Ninguno
         * Función: Evalúa el tipo de pregunta y la guarda en SQLite
         * Variables: id_quiz_activo
         * Fecha: 23-04-2026
         * Autor: Miguel Alexander Córdova Torres
         */
        @objc private func guardarLogica() {
                guard let nombre = nombreTextField.text, !nombre.isEmpty,
                      let textoPregunta = preguntaTextField.text, !textoPregunta.isEmpty else {
                        mostrarAlerta(titulo: "Error", mensaje: "Completa la pregunta y el nombre")
                        return
                }

                if id_quiz_activo == 0 {
                        if let nuevoId = SQLiteManager.shared.insertarQuiz(nombre: nombre, categoria: "General") {
                                id_quiz_activo = nuevoId
                                nombreTextField.isEnabled = false
                                nombreTextField.backgroundColor = .systemGray6
                                guardarButton.setTitle("Agregar Siguiente Pregunta", for: .normal)
                                terminarButton.isHidden = false
                        }
                }

                if id_quiz_activo != 0 {
                        let esMultiple = tipoPreguntaSegmented.selectedSegmentIndex == 1
                        let tipoStr = esMultiple ? "multiple" : "verdadero_falso"
                        var respFinal = ""
                        var opA = "Verdadero", opB = "Falso", opC: String? = nil, opD: String? = nil

                        if esMultiple {
                                guard let a = txtOpcionA.text, !a.isEmpty,
                                      let b = txtOpcionB.text, !b.isEmpty,
                                      let c = txtOpcionC.text, !c.isEmpty,
                                      let d = txtOpcionD.text, !d.isEmpty else {
                                        mostrarAlerta(titulo: "Error", mensaje: "Llena las 4 opciones")
                                        return
                                }
                                opA = a; opB = b; opC = c; opD = d
                                let opciones = [a, b, c, d]
                                respFinal = opciones[selectorRespuestaCorrecta.selectedSegmentIndex]
                        } else {
                                respFinal = respuestaCorrectaSwitch.isOn ? "Verdadero" : "Falso"
                        }

                        let exito = SQLiteManager.shared.insertarPregunta(
                                idQuiz: id_quiz_activo, tipo: tipoStr, texto: textoPregunta,
                                opA: opA, opB: opB, opC: opC, opD: opD, respuesta: respFinal
                        )

                        if exito == true {
                                mostrarAlerta(titulo: "Éxito", mensaje: "Pregunta guardada")
                                limpiarCamposPregunta()
                        }
                }
        }

        private func limpiarCamposPregunta() {
                preguntaTextField.text = ""
                respuestaCorrectaSwitch.isOn = false
                txtOpcionA.text = ""
                txtOpcionB.text = ""
                txtOpcionC.text = ""
                txtOpcionD.text = ""
                selectorRespuestaCorrecta.selectedSegmentIndex = 0
        }

        @objc private func terminarQuiz() {
                id_quiz_activo = 0
                nombreTextField.isEnabled = true
                nombreTextField.backgroundColor = .clear
                nombreTextField.text = ""
                limpiarCamposPregunta()
                guardarButton.setTitle("Crear Quiz y Guardar Pregunta 1", for: .normal)
                terminarButton.isHidden = true
        }

        private func mostrarAlerta(titulo: String, mensaje: String) {
                let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }
}
