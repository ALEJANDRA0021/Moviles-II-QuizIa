//
//  CrearQuizViewController.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import UIKit

/*
 * Función:    CrearQuizViewController (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   Nombre y categoría del quiz via formulario
 * Salidas:    Quiz guardado en SQLite, navega a AgregarPreguntaViewController
 * Retorno:    CrearQuizViewController
 * Variables:  nombre_field, cat_field, save_btn, header_lbl
 * Rutinas:    setupUI, didTapSave, showAlert
 * Descripción: Formulario para crear un nuevo quiz ingresando
 *              nombre y categoría antes de agregar preguntas manualmente
 */
class CrearQuizViewController: UIViewController {

        private let header_lbl   = UILabel()
        private let nombre_field = UITextField()
        private let cat_field    = UITextField()
        private let save_btn     = UIButton(type: .system)

        override func viewDidLoad() {
                super.viewDidLoad()
                setupUI()
        }

        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                nombre_field.text = ""
                cat_field.text    = ""
        }

        // MARK: - Setup

        /*
         * Función:    setupUI
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Interfaz de formulario construida
         * Retorno:    Void
         * Variables:  header_lbl, nombre_field, cat_field, save_btn
         * Rutinas:    NSLayoutConstraint.activate, addTarget
         * Descripción: Configura y posiciona todos los elementos del formulario
         */
        private func setupUI() {
                title = "Nuevo Quiz"
                view.backgroundColor = .systemBackground

                // Header
                header_lbl.text = "✏️ Crear quiz manual"
                header_lbl.font = UIFont.boldSystemFont(ofSize: 22)
                header_lbl.textAlignment = .center
                header_lbl.translatesAutoresizingMaskIntoConstraints = false

                // Nombre
                nombre_field.placeholder = "Nombre del quiz"
                nombre_field.borderStyle = .roundedRect
                nombre_field.font = UIFont.systemFont(ofSize: 16)
                nombre_field.returnKeyType = .next
                nombre_field.translatesAutoresizingMaskIntoConstraints = false

                // Categoría
                cat_field.placeholder = "Categoría (ej: Matemáticas, Historia)"
                cat_field.borderStyle = .roundedRect
                cat_field.font = UIFont.systemFont(ofSize: 16)
                cat_field.returnKeyType = .done
                cat_field.translatesAutoresizingMaskIntoConstraints = false

                // Botón guardar
                save_btn.setTitle("Crear y Agregar Preguntas →", for: .normal)
                save_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                save_btn.backgroundColor = .systemPurple
                save_btn.setTitleColor(.white, for: .normal)
                save_btn.layer.cornerRadius = 12
                save_btn.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
                save_btn.translatesAutoresizingMaskIntoConstraints = false

                view.addSubview(header_lbl)
                view.addSubview(nombre_field)
                view.addSubview(cat_field)
                view.addSubview(save_btn)

                NSLayoutConstraint.activate([
                        header_lbl.topAnchor.constraint(
                                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
                        header_lbl.centerXAnchor.constraint(
                                equalTo: view.centerXAnchor),

                        nombre_field.topAnchor.constraint(
                                equalTo: header_lbl.bottomAnchor, constant: 32),
                        nombre_field.leadingAnchor.constraint(
                                equalTo: view.leadingAnchor, constant: 24),
                        nombre_field.trailingAnchor.constraint(
                                equalTo: view.trailingAnchor, constant: -24),
                        nombre_field.heightAnchor.constraint(equalToConstant: 48),

                        cat_field.topAnchor.constraint(
                                equalTo: nombre_field.bottomAnchor, constant: 16),
                        cat_field.leadingAnchor.constraint(
                                equalTo: view.leadingAnchor, constant: 24),
                        cat_field.trailingAnchor.constraint(
                                equalTo: view.trailingAnchor, constant: -24),
                        cat_field.heightAnchor.constraint(equalToConstant: 48),

                        save_btn.topAnchor.constraint(
                                equalTo: cat_field.bottomAnchor, constant: 32),
                        save_btn.leadingAnchor.constraint(
                                equalTo: view.leadingAnchor, constant: 24),
                        save_btn.trailingAnchor.constraint(
                                equalTo: view.trailingAnchor, constant: -24),
                        save_btn.heightAnchor.constraint(equalToConstant: 52)
                ])
        }

        // MARK: - Actions

        /*
         * Función:    didTapSave
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Tap del usuario en save_btn
         * Salidas:    Quiz insertado en BD, navegación a AgregarPregunta
         * Retorno:    Void
         * Variables:  nombre, cat, quiz, id, add_vc
         * Rutinas:    SQLiteManager.insertQuiz, navigationController.push
         * Descripción: Valida campos, guarda el quiz y navega al siguiente paso
         */
        @objc private func didTapSave() {
                guard let nombre = nombre_field.text, !nombre.trimmingCharacters(
                        in: .whitespaces).isEmpty else {
                        showAlert("Campo requerido", "El nombre del quiz no puede estar vacío.")
                        return
                }
                guard let cat = cat_field.text, !cat.trimmingCharacters(
                        in: .whitespaces).isEmpty else {
                        showAlert("Campo requerido", "La categoría no puede estar vacía.")
                        return
                }

                let quiz = Quiz(nombre: nombre.trimmingCharacters(in: .whitespaces),
                                categoria: cat.trimmingCharacters(in: .whitespaces))
                let id = SQLiteManager.shared.insertQuiz(quiz)

                guard id > 0 else {
                        showAlert("Error", "No se pudo guardar el quiz. Intenta de nuevo.")
                        return
                }

                let saved_quiz = Quiz(id_quiz: id, nombre: quiz.nombre,
                                     categoria: quiz.categoria,
                                     fecha_creacion: quiz.fecha_creacion)
                let add_vc = AgregarPreguntaViewController(quiz: saved_quiz)
                navigationController?.pushViewController(add_vc, animated: true)
        }

        /*
         * Función:    showAlert
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   title: String, msg: String
         * Salidas:    Alerta modal presentada
         * Retorno:    Void
         * Variables:  alert
         * Rutinas:    UIAlertController, present
         * Descripción: Presenta un diálogo de alerta con título y mensaje
         */
        private func showAlert(_ title: String, _ msg: String) {
                let alert = UIAlertController(
                        title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }
}

