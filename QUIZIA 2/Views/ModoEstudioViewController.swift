//
//  ModoEstudioViewController.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import UIKit

/*
 * Función:    ModoEstudioViewController (class)
 * Autor:      QuizIA Team
 * Fecha:      01/05/2026
 * Entradas:   quiz: Quiz, preguntas: [Pregunta]
 * Salidas:    Sesión de estudio con feedback visual y scroll
 * Retorno:    ModoEstudioViewController
 * Variables:  scroll_view, content_view, y demás controles
 * Rutinas:    setupUI, showQuestion, didTapOption,
 *             didTapNext, showResults, textoRespuestaCorrecta
 * Descripción: Muestra el quiz en modo estudio con scroll.
 *              Evalúa respuestas y muestra feedback claro.
 *              Si la respuesta guardada es una sola letra,
 *              la reemplaza por el texto real de la opción.
 */
class ModoEstudioViewController: UIViewController {

    private let quiz: Quiz
    private var preguntas: [Pregunta]
    private var current_idx = 0
    private var score       = 0

    // Scroll
    private let scroll_view  = UIScrollView()
    private let content_view = UIView()

    // UI
    private let progress_lbl  = UILabel()
    private let question_lbl  = UILabel()
    private let btn_a         = UIButton(type: .system)
    private let btn_b         = UIButton(type: .system)
    private let btn_c         = UIButton(type: .system)
    private let btn_d         = UIButton(type: .system)
    private var opt_btns      = [UIButton]()
    private let feedback_lbl  = UILabel()
    private let next_btn      = UIButton(type: .system)

    init(quiz: Quiz, preguntas: [Pregunta]) {
        self.quiz = quiz
        self.preguntas = preguntas.shuffled()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("No storyboard") }

    override func viewDidLoad() {
        super.viewDidLoad()
        opt_btns = [btn_a, btn_b, btn_c, btn_d]
        setupUI()
        showQuestion()
    }

    // MARK: - Setup con scroll

    private func setupUI() {
        title = quiz.nombre
        view.backgroundColor = .systemBackground

        // Scroll
        scroll_view.translatesAutoresizingMaskIntoConstraints = false
        content_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll_view)
        scroll_view.addSubview(content_view)

        // Progress
        progress_lbl.font = UIFont.systemFont(ofSize: 14)
        progress_lbl.textColor = .systemGray
        progress_lbl.textAlignment = .center
        progress_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Question card
        question_lbl.font = UIFont.boldSystemFont(ofSize: 18)
        question_lbl.numberOfLines = 0
        question_lbl.textAlignment = .center
        question_lbl.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.1)
        question_lbl.layer.cornerRadius = 14
        question_lbl.layer.masksToBounds = true
        question_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Option buttons
        for (i, btn) in opt_btns.enumerated() {
            btn.backgroundColor = UIColor.systemGray6
            btn.setTitleColor(.label, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            btn.layer.cornerRadius = 12
            btn.tag = i
            btn.addTarget(self, action: #selector(didTapOption(_:)), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
        }

        // Feedback label (multilínea)
        feedback_lbl.font = UIFont.boldSystemFont(ofSize: 20)
        feedback_lbl.numberOfLines = 0
        feedback_lbl.textAlignment = .center
        feedback_lbl.isHidden = true
        feedback_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Next button
        next_btn.setTitle("Siguiente →", for: .normal)
        next_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        next_btn.backgroundColor = .systemPurple
        next_btn.setTitleColor(.white, for: .normal)
        next_btn.layer.cornerRadius = 12
        next_btn.isHidden = true
        next_btn.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        next_btn.translatesAutoresizingMaskIntoConstraints = false

        [progress_lbl, question_lbl,
         btn_a, btn_b, btn_c, btn_d,
         feedback_lbl, next_btn].forEach { content_view.addSubview($0) }

        let m: CGFloat = 20

        NSLayoutConstraint.activate([
            scroll_view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll_view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll_view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content_view.topAnchor.constraint(equalTo: scroll_view.topAnchor),
            content_view.leadingAnchor.constraint(equalTo: scroll_view.leadingAnchor),
            content_view.trailingAnchor.constraint(equalTo: scroll_view.trailingAnchor),
            content_view.bottomAnchor.constraint(equalTo: scroll_view.bottomAnchor),
            content_view.widthAnchor.constraint(equalTo: scroll_view.widthAnchor),

            progress_lbl.topAnchor.constraint(equalTo: content_view.topAnchor, constant: 16),
            progress_lbl.centerXAnchor.constraint(equalTo: content_view.centerXAnchor),

            question_lbl.topAnchor.constraint(equalTo: progress_lbl.bottomAnchor, constant: 16),
            question_lbl.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            question_lbl.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            question_lbl.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),

            btn_a.topAnchor.constraint(equalTo: question_lbl.bottomAnchor, constant: 20),
            btn_a.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            btn_a.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            btn_a.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            btn_b.topAnchor.constraint(equalTo: btn_a.bottomAnchor, constant: 10),
            btn_b.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            btn_b.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            btn_b.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            btn_c.topAnchor.constraint(equalTo: btn_b.bottomAnchor, constant: 10),
            btn_c.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            btn_c.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            btn_c.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            btn_d.topAnchor.constraint(equalTo: btn_c.bottomAnchor, constant: 10),
            btn_d.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            btn_d.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            btn_d.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            feedback_lbl.topAnchor.constraint(equalTo: btn_d.bottomAnchor, constant: 16),
            feedback_lbl.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            feedback_lbl.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),

            next_btn.topAnchor.constraint(equalTo: feedback_lbl.bottomAnchor, constant: 12),
            next_btn.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            next_btn.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            next_btn.heightAnchor.constraint(equalToConstant: 52),
            next_btn.bottomAnchor.constraint(equalTo: content_view.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Lógica de preguntas

    private func showQuestion() {
        guard current_idx < preguntas.count else {
            showResults()
            return
        }

        let p = preguntas[current_idx]

        progress_lbl.text = "Pregunta \(current_idx + 1) / \(preguntas.count)  •  Puntaje: \(score)"
        question_lbl.text = "\n\(p.texto_pregunta)\n"

        let all_opts = [p.opcion_a, p.opcion_b, p.opcion_c, p.opcion_d]
        for (i, btn) in opt_btns.enumerated() {
            let opt = all_opts[i]
            if opt.isEmpty {
                btn.isHidden = true
            } else {
                btn.isHidden = false
                btn.setTitle(opt, for: .normal)
                btn.backgroundColor = UIColor.systemGray6
                btn.isEnabled = true
            }
        }

        feedback_lbl.isHidden = true
        next_btn.isHidden = true

        scroll_view.setContentOffset(.zero, animated: false)
    }

    @objc private func didTapOption(_ sender: UIButton) {
        let p        = preguntas[current_idx]
        let all_opts = [p.opcion_a, p.opcion_b, p.opcion_c, p.opcion_d]

        // Obtener el índice de la respuesta correcta (comparando texto limpio)
        let correcto_limpio = p.respuesta_correcta
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var idx_correcto: Int?
        for (i, opt) in all_opts.enumerated() {
            let opt_limpio = opt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if opt_limpio == correcto_limpio {
                idx_correcto = i
                break
            }
        }

        // Si no encontró coincidencia por texto, intentar mapear por letra (ej: "a")
        if idx_correcto == nil {
            let letras = ["a", "b", "c", "d"]
            if let idx_letra = letras.firstIndex(of: correcto_limpio) {
                // Solo si la letra está dentro de las opciones disponibles
                if idx_letra < all_opts.count && !all_opts[idx_letra].isEmpty {
                    idx_correcto = idx_letra
                }
            }
        }

        let is_correct = (sender.tag == idx_correcto)

        // Deshabilitar todos los botones
        opt_btns.forEach { $0.isEnabled = false }

        // Colorear las opciones correctas
        for (i, btn) in opt_btns.enumerated() {
            let opt_limpio = all_opts[i].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if opt_limpio == correcto_limpio {
                btn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
            }
            // Si estamos usando letra como índice correcto, coloreamos esa opción también
            if let idx = idx_correcto, i == idx {
                btn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
            }
        }

        // Construir el feedback con el texto completo de la respuesta correcta
        let texto_correcto = textoRespuestaCorrecta(pregunta: p, idx_correcto: idx_correcto)

        if is_correct {
            feedback_lbl.text = "✅ ¡Correcto!"
            feedback_lbl.textColor = .systemGreen
            score += 1
        } else {
            sender.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
            feedback_lbl.text = "❌ Incorrecto\nLa respuesta correcta es:\n\"\(texto_correcto)\""
            feedback_lbl.textColor = .systemRed
        }

        feedback_lbl.isHidden = false
        let is_last = current_idx == preguntas.count - 1
        next_btn.setTitle(is_last ? "Ver resultados 🏁" : "Siguiente →", for: .normal)
        next_btn.isHidden = false

        // Scroll automático hacia abajo para ver el feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottomOffset = CGPoint(x: 0, y: self.scroll_view.contentSize.height - self.scroll_view.bounds.height + 20)
            if bottomOffset.y > 0 {
                self.scroll_view.setContentOffset(bottomOffset, animated: true)
            }
        }
    }

    /*
     * Función:    textoRespuestaCorrecta
     * Autor:      QuizIA Team
     * Fecha:      01/05/2026
     * Entradas:   pregunta: Pregunta, idx_correcto: Int?
     * Salidas:    Texto completo de la respuesta correcta
     * Retorno:    String
     * Variables:  all_opts, letras
     * Rutinas:    Ninguna
     * Descripción: Devuelve el texto de la opción correcta.
     *              Si el índice es válido, usa el texto de esa opción;
     *              si no, regresa el campo respuesta_correcta original.
     */
    private func textoRespuestaCorrecta(pregunta: Pregunta, idx_correcto: Int?) -> String {
        if let idx = idx_correcto,
           idx >= 0 && idx < 4 {
            let all_opts = [pregunta.opcion_a, pregunta.opcion_b, pregunta.opcion_c, pregunta.opcion_d]
            if !all_opts[idx].isEmpty {
                return all_opts[idx]
            }
        }
        // Último recurso: devolver el campo respuesta_correcta (aunque sea "a")
        return pregunta.respuesta_correcta
    }

    @objc private func didTapNext() {
        current_idx += 1
        showQuestion()
    }

    private func showResults() {
        let total = preguntas.count
        let pct   = total > 0 ? (score * 100) / total : 0
        let emoji = pct >= 80 ? "🏆" : pct >= 60 ? "👍" : "📖"
        let msg   = "\(emoji) \(score) de \(total) correctas\n(\(pct)%)"

        let alert = UIAlertController(title: "Resultado Final", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Repetir", style: .default) { _ in
            self.current_idx = 0
            self.score = 0
            self.preguntas = self.preguntas.shuffled()
            self.showQuestion()
        })
        alert.addAction(UIAlertAction(title: "Salir", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

