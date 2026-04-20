//
//  ViewController.swift
//  Proyecto_QuizIa
//
//  Created by macbook pro on 3/22/26.
//

import UIKit

class ViewController: UIViewController {

    private let nombreTextField = UITextField()
    private let preguntaTextField = UITextField()
    private let respuestaCorrectaSwitch = UISwitch()
    private let guardarButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Crear Quiz"
        setupUI()
        
        // Probar lectura de BD (opcional)
        let quizzes = SQLiteManager.shared.obtenerQuizzes()
        print("📋 Quizzes guardados: \(quizzes.count)")
        for q in quizzes {
            print("   - \(q.nombre) (\(q.categoria))")
        }
    }

    private func setupUI() {
        // Nombre del Quiz
        nombreTextField.placeholder = "Nombre del Quiz (ej. Historia)"
        nombreTextField.borderStyle = .roundedRect
        nombreTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nombreTextField)

        // Pregunta
        preguntaTextField.placeholder = "Escribe la pregunta"
        preguntaTextField.borderStyle = .roundedRect
        preguntaTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preguntaTextField)

        // Label para el Switch
        let switchLabel = UILabel()
        switchLabel.text = "¿La respuesta correcta es Verdadero?"
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchLabel)

        // Switch
        respuestaCorrectaSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(respuestaCorrectaSwitch)

        // Botón Guardar
        guardarButton.setTitle("Guardar Quiz", for: .normal)
        guardarButton.translatesAutoresizingMaskIntoConstraints = false
        guardarButton.addTarget(self, action: #selector(guardarQuiz), for: .touchUpInside)
        view.addSubview(guardarButton)

        // Constraints
        NSLayoutConstraint.activate([
            nombreTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nombreTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nombreTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            preguntaTextField.topAnchor.constraint(equalTo: nombreTextField.bottomAnchor, constant: 20),
            preguntaTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            preguntaTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            switchLabel.topAnchor.constraint(equalTo: preguntaTextField.bottomAnchor, constant: 20),
            switchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            respuestaCorrectaSwitch.centerYAnchor.constraint(equalTo: switchLabel.centerYAnchor),
            respuestaCorrectaSwitch.leadingAnchor.constraint(equalTo: switchLabel.trailingAnchor, constant: 10),

            guardarButton.topAnchor.constraint(equalTo: switchLabel.bottomAnchor, constant: 40),
            guardarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func guardarQuiz() {
        guard let nombre = nombreTextField.text, !nombre.isEmpty,
              let textoPregunta = preguntaTextField.text, !textoPregunta.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Completa todos los campos")
            return
        }

        // Guardar quiz
        guard let idQuiz = SQLiteManager.shared.insertarQuiz(nombre: nombre, categoria: "General") else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo guardar el quiz")
            return
        }

        // Guardar pregunta
        let respuesta = respuestaCorrectaSwitch.isOn ? "Verdadero" : "Falso"
        let exito = SQLiteManager.shared.insertarPregunta(
            idQuiz: idQuiz,
            tipo: "verdadero_falso",
            texto: textoPregunta,
            opA: "Verdadero",
            opB: "Falso",
            opC: nil,
            opD: nil,
            respuesta: respuesta
        )

        if exito {
            mostrarAlerta(titulo: "Éxito", mensaje: "Quiz guardado correctamente")
            nombreTextField.text = ""
            preguntaTextField.text = ""
            respuestaCorrectaSwitch.isOn = false
        } else {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo guardar la pregunta")
        }
    }

    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
