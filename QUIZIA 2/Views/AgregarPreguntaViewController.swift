//
//  AgregarPreguntaViewController.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import UIKit

/*
 * Función:    AgregarPreguntaViewController (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   quiz: Quiz (quiz al que se agregan preguntas)
 * Salidas:    Preguntas guardadas en SQLite
 * Retorno:    AgregarPreguntaViewController
 * Variables:  quiz, preguntas_temp, scroll_view, content_view,
 *             tipo_seg, pregunta_tv, op_a/b/c/d_field,
 *             resp_field, add_btn, finish_btn, count_lbl
 * Rutinas:    setupUI, setupConstraints, updateTipo,
 *             didTapAdd, didTapFinish, keyboardWillShow/Hide
 * Descripción: Pantalla para agregar preguntas manualmente a un quiz.
 *              Soporta opción múltiple y verdadero/falso.
 */
class AgregarPreguntaViewController: UIViewController {

        private let quiz: Quiz
        private var preguntas_temp = [Pregunta]()

        // UI
        private let scroll_view  = UIScrollView()
        private let content_view = UIView()
        private let count_lbl    = UILabel()
        private let tipo_seg     = UISegmentedControl(
                items: ["Opción Múltiple", "Verdadero/Falso"])
        private let pregunta_tv  = UITextView()
        private let op_a_field   = UITextField()
        private let op_b_field   = UITextField()
        private let op_c_field   = UITextField()
        private let op_d_field   = UITextField()
        private let resp_field   = UITextField()
        private let add_btn      = UIButton(type: .system)
        private let finish_btn   = UIButton(type: .system)

        init(quiz: Quiz) {
                self.quiz = quiz
                super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError("No storyboard") }

        override func viewDidLoad() {
                super.viewDidLoad()
                setupUI()
                updateTipo()
        }

        deinit {
                NotificationCenter.default.removeObserver(self)
        }

        // MARK: - Setup

        /*
         * Función:    setupUI
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Interfaz de formulario construida en scroll
         * Retorno:    Void
         * Variables:  todos los controles del formulario
         * Rutinas:    setupConstraints, addObserver
         * Descripción: Configura el scroll view y todos los controles del
         *              formulario de preguntas
         */
        private func setupUI() {
                title = "Agregar Preguntas"
                view.backgroundColor = .systemBackground

                scroll_view.translatesAutoresizingMaskIntoConstraints = false
                content_view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(scroll_view)
                scroll_view.addSubview(content_view)

                // Contador de preguntas
                count_lbl.text = "'\(quiz.nombre)' — preguntas: 0"
                count_lbl.font = UIFont.systemFont(ofSize: 14)
                count_lbl.textColor = .systemPurple
                count_lbl.textAlignment = .center
                count_lbl.translatesAutoresizingMaskIntoConstraints = false

                // Segmented tipo
                tipo_seg.selectedSegmentIndex = 0
                tipo_seg.addTarget(self, action: #selector(tipoChanged), for: .valueChanged)
                tipo_seg.translatesAutoresizingMaskIntoConstraints = false

                // TextView pregunta
                pregunta_tv.font = UIFont.systemFont(ofSize: 15)
                pregunta_tv.layer.borderColor = UIColor.systemGray4.cgColor
                pregunta_tv.layer.borderWidth = 1
                pregunta_tv.layer.cornerRadius = 8
                pregunta_tv.isScrollEnabled = false
                pregunta_tv.textContainerInset = UIEdgeInsets(
                        top: 10, left: 8, bottom: 10, right: 8)
                pregunta_tv.translatesAutoresizingMaskIntoConstraints = false

                // Placeholder manual para el TextView
                pregunta_tv.text = "Escribe la pregunta aquí..."
                pregunta_tv.textColor = .systemGray3
                pregunta_tv.delegate = self

                // Campos de opciones
                configField(op_a_field, placeholder: "Opción A")
                configField(op_b_field, placeholder: "Opción B")
                configField(op_c_field, placeholder: "Opción C")
                configField(op_d_field, placeholder: "Opción D")
                configField(resp_field,
                            placeholder: "Respuesta correcta (igual que la opción)")

                // Botón agregar
                add_btn.setTitle("+ Agregar Pregunta", for: .normal)
                add_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                add_btn.backgroundColor = .systemBlue
                add_btn.setTitleColor(.white, for: .normal)
                add_btn.layer.cornerRadius = 12
                add_btn.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
                add_btn.translatesAutoresizingMaskIntoConstraints = false

                // Botón terminar
                finish_btn.setTitle("✓ Terminar Quiz", for: .normal)
                finish_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                finish_btn.backgroundColor = .systemGreen
                finish_btn.setTitleColor(.white, for: .normal)
                finish_btn.layer.cornerRadius = 12
                finish_btn.addTarget(self, action: #selector(didTapFinish), for: .touchUpInside)
                finish_btn.translatesAutoresizingMaskIntoConstraints = false

                [count_lbl, tipo_seg, pregunta_tv,
                 op_a_field, op_b_field, op_c_field, op_d_field,
                 resp_field, add_btn, finish_btn].forEach {
                        content_view.addSubview($0)
                }

                setupConstraints()

                // Teclado
                NotificationCenter.default.addObserver(
                        self, selector: #selector(keyboardWillShow(_:)),
                        name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(
                        self, selector: #selector(keyboardWillHide(_:)),
                        name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        /*
         * Función:    configField
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   field: UITextField, placeholder: String
         * Salidas:    Campo configurado con estilo
         * Retorno:    Void
         * Variables:  field
         * Rutinas:    UITextField properties
         * Descripción: Aplica estilo y placeholder a un UITextField
         */
        private func configField(_ field: UITextField, placeholder: String) {
                field.placeholder = placeholder
                field.borderStyle = .roundedRect
                field.font = UIFont.systemFont(ofSize: 15)
                field.translatesAutoresizingMaskIntoConstraints = false
        }

        /*
         * Función:    setupConstraints
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Constraints activados para todos los elementos
         * Retorno:    Void
         * Variables:  m (margin), sp (spacing), h44
         * Rutinas:    NSLayoutConstraint.activate
         * Descripción: Configura el layout de todos los elementos del formulario
         */
        private func setupConstraints() {
                let m: CGFloat  = 24
                let sp: CGFloat = 12
                let h44: CGFloat = 44

                NSLayoutConstraint.activate([
                        // Scroll
                        scroll_view.topAnchor.constraint(
                                equalTo: view.safeAreaLayoutGuide.topAnchor),
                        scroll_view.leadingAnchor.constraint(
                                equalTo: view.leadingAnchor),
                        scroll_view.trailingAnchor.constraint(
                                equalTo: view.trailingAnchor),
                        scroll_view.bottomAnchor.constraint(
                                equalTo: view.bottomAnchor),

                        // Content
                        content_view.topAnchor.constraint(
                                equalTo: scroll_view.topAnchor),
                        content_view.leadingAnchor.constraint(
                                equalTo: scroll_view.leadingAnchor),
                        content_view.trailingAnchor.constraint(
                                equalTo: scroll_view.trailingAnchor),
                        content_view.bottomAnchor.constraint(
                                equalTo: scroll_view.bottomAnchor),
                        content_view.widthAnchor.constraint(
                                equalTo: scroll_view.widthAnchor),

                        // count_lbl
                        count_lbl.topAnchor.constraint(
                                equalTo: content_view.topAnchor, constant: 16),
                        count_lbl.centerXAnchor.constraint(
                                equalTo: content_view.centerXAnchor),

                        // tipo_seg
                        tipo_seg.topAnchor.constraint(
                                equalTo: count_lbl.bottomAnchor, constant: sp),
                        tipo_seg.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        tipo_seg.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),

                        // pregunta_tv
                        pregunta_tv.topAnchor.constraint(
                                equalTo: tipo_seg.bottomAnchor, constant: sp),
                        pregunta_tv.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        pregunta_tv.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        pregunta_tv.heightAnchor.constraint(
                                greaterThanOrEqualToConstant: 80),

                        // op_a
                        op_a_field.topAnchor.constraint(
                                equalTo: pregunta_tv.bottomAnchor, constant: sp),
                        op_a_field.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        op_a_field.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        op_a_field.heightAnchor.constraint(equalToConstant: h44),

                        // op_b
                        op_b_field.topAnchor.constraint(
                                equalTo: op_a_field.bottomAnchor, constant: sp),
                        op_b_field.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        op_b_field.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        op_b_field.heightAnchor.constraint(equalToConstant: h44),

                        // op_c
                        op_c_field.topAnchor.constraint(
                                equalTo: op_b_field.bottomAnchor, constant: sp),
                        op_c_field.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        op_c_field.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        op_c_field.heightAnchor.constraint(equalToConstant: h44),

                        // op_d
                        op_d_field.topAnchor.constraint(
                                equalTo: op_c_field.bottomAnchor, constant: sp),
                        op_d_field.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        op_d_field.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        op_d_field.heightAnchor.constraint(equalToConstant: h44),

                        // resp
                        resp_field.topAnchor.constraint(
                                equalTo: op_d_field.bottomAnchor, constant: sp),
                        resp_field.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        resp_field.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        resp_field.heightAnchor.constraint(equalToConstant: h44),

                        // add_btn
                        add_btn.topAnchor.constraint(
                                equalTo: resp_field.bottomAnchor, constant: 24),
                        add_btn.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        add_btn.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        add_btn.heightAnchor.constraint(equalToConstant: 50),

                        // finish_btn
                        finish_btn.topAnchor.constraint(
                                equalTo: add_btn.bottomAnchor, constant: 12),
                        finish_btn.leadingAnchor.constraint(
                                equalTo: content_view.leadingAnchor, constant: m),
                        finish_btn.trailingAnchor.constraint(
                                equalTo: content_view.trailingAnchor, constant: -m),
                        finish_btn.heightAnchor.constraint(equalToConstant: 50),
                        finish_btn.bottomAnchor.constraint(
                                equalTo: content_view.bottomAnchor, constant: -32)
                ])
        }

        // MARK: - Actions

        /*
         * Función:    tipoChanged
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Cambio en tipo_seg
         * Salidas:    Vista actualizada según tipo seleccionado
         * Retorno:    Void
         * Variables:  Ninguna
         * Rutinas:    updateTipo
         * Descripción: Responde al cambio del segmented control de tipo
         */
        @objc private func tipoChanged() {
                updateTipo()
        }

        /*
         * Función:    updateTipo
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Campos C y D ocultados o mostrados
         * Retorno:    Void
         * Variables:  is_multiple
         * Rutinas:    isHidden, text, placeholder
         * Descripción: Muestra/oculta los campos C/D y ajusta placeholders
         *              según sea opción múltiple o verdadero/falso
         */
        private func updateTipo() {
                let is_multiple = tipo_seg.selectedSegmentIndex == 0
                op_c_field.isHidden = !is_multiple
                op_d_field.isHidden = !is_multiple

                if !is_multiple {
                        op_a_field.text = "Verdadero"
                        op_b_field.text = "Falso"
                        op_a_field.isUserInteractionEnabled = false
                        op_b_field.isUserInteractionEnabled = false
                } else {
                        if op_a_field.text == "Verdadero" { op_a_field.text = "" }
                        if op_b_field.text == "Falso"     { op_b_field.text = "" }
                        op_a_field.isUserInteractionEnabled = true
                        op_b_field.isUserInteractionEnabled = true
                }
        }

        /*
         * Función:    didTapAdd
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Tap en add_btn
         * Salidas:    Pregunta guardada en BD, formulario limpiado
         * Retorno:    Void
         * Variables:  texto, a, b, c, d, resp, tipo, p
         * Rutinas:    SQLiteManager.insertPregunta, showMiniAlert
         * Descripción: Valida los campos, crea la pregunta y la guarda en BD
         */
        @objc private func didTapAdd() {
                let texto = pregunta_tv.textColor == .systemGray3 ? "" : pregunta_tv.text ?? ""
                guard !texto.trimmingCharacters(in: .whitespaces).isEmpty else {
                        showAlert("Falta la pregunta", "Escribe el enunciado de la pregunta.")
                        return
                }
                guard let a = op_a_field.text, !a.isEmpty,
                      let b = op_b_field.text, !b.isEmpty else {
                        showAlert("Faltan opciones", "Las opciones A y B son obligatorias.")
                        return
                }
                guard let resp = resp_field.text, !resp.isEmpty else {
                        showAlert("Falta la respuesta", "Indica cuál es la respuesta correcta.")
                        return
                }

                let tipo = tipo_seg.selectedSegmentIndex == 0 ? "multiple" : "verdadero_falso"
                let c    = op_c_field.text ?? ""
                let d    = op_d_field.text ?? ""

                let p = Pregunta(
                        id_quiz: quiz.id_quiz,
                        tipo_pregunta: tipo,
                        texto_pregunta: texto,
                        opcion_a: a, opcion_b: b,
                        opcion_c: c, opcion_d: d,
                        respuesta_correcta: resp
                )
                SQLiteManager.shared.insertPregunta(p)
                preguntas_temp.append(p)

                clearForm()
                count_lbl.text = "'\(quiz.nombre)' — preguntas: \(preguntas_temp.count)"
                view.endEditing(true)
                showMiniAlert("✓ Pregunta \(preguntas_temp.count) agregada")
        }

        /*
         * Función:    didTapFinish
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Tap en finish_btn
         * Salidas:    Navegación de vuelta a raíz
         * Retorno:    Void
         * Variables:  alert
         * Rutinas:    popToRootViewController
         * Descripción: Confirma el fin de la creación y vuelve a Mis Quizzes
         */
        @objc private func didTapFinish() {
                guard !preguntas_temp.isEmpty else {
                        showAlert(
                                "Sin preguntas",
                                "Agrega al menos una pregunta antes de terminar.")
                        return
                }
                let alert = UIAlertController(
                        title: "¡Quiz listo!",
                        message: "'\(quiz.nombre)' tiene \(preguntas_temp.count) pregunta(s). ¡Puedes estudiarlo en Mis Quizzes!",
                        preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: true)
                })
                present(alert, animated: true)
        }

        // MARK: - Helpers

        /*
         * Función:    clearForm
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Formulario limpiado y listo para nueva pregunta
         * Retorno:    Void
         * Variables:  Ninguna
         * Rutinas:    updateTipo
         * Descripción: Limpia todos los campos del formulario de pregunta
         */
        private func clearForm() {
                pregunta_tv.text = "Escribe la pregunta aquí..."
                pregunta_tv.textColor = .systemGray3
                resp_field.text = ""
                if tipo_seg.selectedSegmentIndex == 0 {
                        op_a_field.text = ""
                        op_b_field.text = ""
                        op_c_field.text = ""
                        op_d_field.text = ""
                }
        }

        /*
         * Función:    showMiniAlert
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   msg: String
         * Salidas:    Alerta auto-dismissible tras 0.8s
         * Retorno:    Void
         * Variables:  mini
         * Rutinas:    asyncAfter, dismiss
         * Descripción: Muestra un alert que se cierra solo para confirmar acción
         */
        private func showMiniAlert(_ msg: String) {
                let mini = UIAlertController(title: msg, message: nil,
                                             preferredStyle: .alert)
                present(mini, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        mini.dismiss(animated: true)
                }
        }

        private func showAlert(_ title: String, _ msg: String) {
                let alert = UIAlertController(
                        title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }

        @objc private func keyboardWillShow(_ notif: Notification) {
                if let info = notif.userInfo,
                   let kb = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        scroll_view.contentInset.bottom = kb.height
                }
        }

        @objc private func keyboardWillHide(_ notif: Notification) {
                scroll_view.contentInset.bottom = 0
        }
}

// MARK: - UITextViewDelegate (placeholder behavior)

extension AgregarPreguntaViewController: UITextViewDelegate {

        func textViewDidBeginEditing(_ textView: UITextView) {
                if textView.textColor == .systemGray3 {
                        textView.text = ""
                        textView.textColor = .label
                }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
                if textView.text.isEmpty {
                        textView.text = "Escribe la pregunta aquí..."
                        textView.textColor = .systemGray3
                }
        }
}
