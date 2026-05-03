//
//  GeneracionIAViewController.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import UIKit
import PDFKit

/*
 * Función:    GeneracionIAViewController (class)
 * Autor:      QuizIA Team
 * Fecha:      01/05/2026
 * Entradas:   PDF seleccionado por el usuario
 * Salidas:    Quiz guardado en SQLite con preguntas generadas por IA
 * Retorno:    GeneracionIAViewController
 * Variables:  extracted_text, generated_questions, etc.
 * Rutinas:    setupUI, updateLimit, didTapPickPDF, didTapGenerate,
 *             showPreview, didTapSave, extractPDFText, todayKey
 * Descripción: Permite cargar un PDF, extraer su texto, llamar a Groq
 *              para generar preguntas y guardar el quiz.
 *              Implementa límite diario de 3 generaciones (Freemium).
 */
class GeneracionIAViewController: UIViewController {

    private var extracted_text     = ""
    private var generated_questions = [Pregunta]()

    // UI
    private let scroll_view  = UIScrollView()
    private let content_view = UIView()
    private let info_lbl     = UILabel()
    private let pick_btn     = UIButton(type: .system)
    private let pdf_lbl      = UILabel()
    private let name_field   = UITextField()
    private let cat_field    = UITextField()
    private let count_title  = UILabel()
    private let count_seg    = UISegmentedControl(items: ["3", "5", "8", "10"])
    private let limit_lbl    = UILabel()
    private let gen_btn      = UIButton(type: .system)
    private let activity     = UIActivityIndicatorView(style: .large)
    private let preview_lbl  = UILabel()
    private let save_btn     = UIButton(type: .system)

    // Límite diario freemium
    private let max_daily = 3
    private var used_today: Int {
        get { UserDefaults.standard.integer(forKey: "ia_used_\(todayKey())") }
        set { UserDefaults.standard.set(newValue, forKey: "ia_used_\(todayKey())") }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLimit()
    }

    // MARK: - Setup (sin cambios)

    private func setupUI() {
        title = "Generar con IA"
        view.backgroundColor = .systemBackground

        scroll_view.translatesAutoresizingMaskIntoConstraints = false
        content_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll_view)
        scroll_view.addSubview(content_view)

        // Info
        info_lbl.text = "🤖 Selecciona un PDF y QuizIA generará\npreguntas automáticamente con IA"
        info_lbl.font = UIFont.systemFont(ofSize: 15)
        info_lbl.textColor = .systemGray
        info_lbl.numberOfLines = 0
        info_lbl.textAlignment = .center
        info_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Pick PDF
        pick_btn.setTitle("📄 Seleccionar PDF", for: .normal)
        pick_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        pick_btn.backgroundColor = .systemBlue
        pick_btn.setTitleColor(.white, for: .normal)
        pick_btn.layer.cornerRadius = 12
        pick_btn.addTarget(self, action: #selector(didTapPickPDF), for: .touchUpInside)
        pick_btn.translatesAutoresizingMaskIntoConstraints = false

        // PDF name
        pdf_lbl.text = "Ningún archivo seleccionado"
        pdf_lbl.font = UIFont.italicSystemFont(ofSize: 13)
        pdf_lbl.textColor = .systemGray
        pdf_lbl.textAlignment = .center
        pdf_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Quiz name
        name_field.placeholder = "Nombre del quiz (ej: Biología Cap.3)"
        name_field.borderStyle = .roundedRect
        name_field.font = UIFont.systemFont(ofSize: 15)
        name_field.translatesAutoresizingMaskIntoConstraints = false

        // Categoria
        cat_field.placeholder = "Categoría (opcional)"
        cat_field.borderStyle = .roundedRect
        cat_field.font = UIFont.systemFont(ofSize: 15)
        cat_field.translatesAutoresizingMaskIntoConstraints = false

        // Count title
        count_title.text = "Cantidad de preguntas a generar:"
        count_title.font = UIFont.systemFont(ofSize: 14)
        count_title.textColor = .secondaryLabel
        count_title.translatesAutoresizingMaskIntoConstraints = false

        // Count seg
        count_seg.selectedSegmentIndex = 1
        count_seg.translatesAutoresizingMaskIntoConstraints = false

        // Limit label
        limit_lbl.font = UIFont.systemFont(ofSize: 13)
        limit_lbl.textAlignment = .center
        limit_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Generate button
        gen_btn.setTitle("🤖 Generar Preguntas", for: .normal)
        gen_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        gen_btn.backgroundColor = .systemPurple
        gen_btn.setTitleColor(.white, for: .normal)
        gen_btn.layer.cornerRadius = 12
        gen_btn.addTarget(self, action: #selector(didTapGenerate), for: .touchUpInside)
        gen_btn.translatesAutoresizingMaskIntoConstraints = false

        // Activity
        activity.hidesWhenStopped = true
        activity.color = .systemPurple
        activity.translatesAutoresizingMaskIntoConstraints = false

        // Preview
        preview_lbl.font = UIFont.systemFont(ofSize: 13)
        preview_lbl.numberOfLines = 0
        preview_lbl.textColor = .label
        preview_lbl.backgroundColor = UIColor.systemGray6
        preview_lbl.layer.cornerRadius = 10
        preview_lbl.layer.masksToBounds = true
        preview_lbl.isHidden = true
        preview_lbl.translatesAutoresizingMaskIntoConstraints = false

        // Save button
        save_btn.setTitle("💾 Guardar Quiz", for: .normal)
        save_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        save_btn.backgroundColor = .systemGreen
        save_btn.setTitleColor(.white, for: .normal)
        save_btn.layer.cornerRadius = 12
        save_btn.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        save_btn.translatesAutoresizingMaskIntoConstraints = false
        save_btn.isHidden = true

        [info_lbl, pick_btn, pdf_lbl, name_field, cat_field,
         count_title, count_seg, limit_lbl, gen_btn,
         activity, preview_lbl, save_btn].forEach {
            content_view.addSubview($0)
        }

        setupConstraints()
    }

    private func setupConstraints() {
        let m: CGFloat  = 24
        let sp: CGFloat = 14

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

            info_lbl.topAnchor.constraint(equalTo: content_view.topAnchor, constant: 24),
            info_lbl.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            info_lbl.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),

            pick_btn.topAnchor.constraint(equalTo: info_lbl.bottomAnchor, constant: sp),
            pick_btn.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            pick_btn.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            pick_btn.heightAnchor.constraint(equalToConstant: 50),

            pdf_lbl.topAnchor.constraint(equalTo: pick_btn.bottomAnchor, constant: 8),
            pdf_lbl.centerXAnchor.constraint(equalTo: content_view.centerXAnchor),

            name_field.topAnchor.constraint(equalTo: pdf_lbl.bottomAnchor, constant: sp),
            name_field.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            name_field.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            name_field.heightAnchor.constraint(equalToConstant: 44),

            cat_field.topAnchor.constraint(equalTo: name_field.bottomAnchor, constant: sp),
            cat_field.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            cat_field.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            cat_field.heightAnchor.constraint(equalToConstant: 44),

            count_title.topAnchor.constraint(equalTo: cat_field.bottomAnchor, constant: sp),
            count_title.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),

            count_seg.topAnchor.constraint(equalTo: count_title.bottomAnchor, constant: 8),
            count_seg.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            count_seg.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),

            limit_lbl.topAnchor.constraint(equalTo: count_seg.bottomAnchor, constant: sp),
            limit_lbl.centerXAnchor.constraint(equalTo: content_view.centerXAnchor),

            gen_btn.topAnchor.constraint(equalTo: limit_lbl.bottomAnchor, constant: sp),
            gen_btn.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            gen_btn.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            gen_btn.heightAnchor.constraint(equalToConstant: 52),

            activity.topAnchor.constraint(equalTo: gen_btn.bottomAnchor, constant: 20),
            activity.centerXAnchor.constraint(equalTo: content_view.centerXAnchor),

            preview_lbl.topAnchor.constraint(equalTo: activity.bottomAnchor, constant: 16),
            preview_lbl.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            preview_lbl.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),

            save_btn.topAnchor.constraint(equalTo: preview_lbl.bottomAnchor, constant: 16),
            save_btn.leadingAnchor.constraint(equalTo: content_view.leadingAnchor, constant: m),
            save_btn.trailingAnchor.constraint(equalTo: content_view.trailingAnchor, constant: -m),
            save_btn.heightAnchor.constraint(equalToConstant: 52),
            save_btn.bottomAnchor.constraint(equalTo: content_view.bottomAnchor, constant: -32)
        ])
    }

    // MARK: - Helpers

    private func updateLimit() {
        let remaining = max_daily - used_today
        limit_lbl.text = "Generaciones disponibles hoy: \(remaining)/\(max_daily)"
        limit_lbl.textColor = remaining > 0 ? .systemOrange : .systemRed
        gen_btn.isEnabled = remaining > 0
        gen_btn.alpha = remaining > 0 ? 1.0 : 0.5
    }

    private func todayKey() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd"
        return fmt.string(from: Date())
    }

    // MARK: - Actions

    @objc private func didTapPickPDF() {
        let picker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    @objc private func didTapGenerate() {
        guard !extracted_text.isEmpty else {
            showAlert("Sin PDF", "Primero selecciona un archivo PDF.")
            return
        }
        guard let nombre = name_field.text, !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Nombre requerido", "Escribe un nombre para el quiz.")
            return
        }

        let counts = [3, 5, 8, 10]
        let count  = counts[count_seg.selectedSegmentIndex]

        activity.startAnimating()
        gen_btn.isEnabled = false
        save_btn.isHidden = true
        preview_lbl.isHidden = true

        // ✅ NUEVA LLAMADA con Result
        GroqManager.shared.generateQuestions(from: extracted_text, count: count) { [weak self] result in
            guard let self = self else { return }
            self.activity.stopAnimating()

            switch result {
            case .success(let preguntas):
                guard !preguntas.isEmpty else {
                    self.showAlert("Sin resultados",
                                   "No se generaron preguntas.\n" +
                                   "Verifica tu API key en GroqManager.swift y revisa la consola.")
                    self.gen_btn.isEnabled = true
                    return
                }
                self.generated_questions = preguntas
                self.used_today += 1
                self.updateLimit()
                self.showPreview()

            case .failure(let error):
                self.showAlert("Error de IA", error.localizedDescription)
                self.gen_btn.isEnabled = true
            }
        }
    }

    private func showPreview() {
        var preview = "✅ \(generated_questions.count) preguntas generadas:\n\n"
        for (i, p) in generated_questions.prefix(3).enumerated() {
            preview += "\(i + 1). \(p.texto_pregunta)\n"
            preview += "   A) \(p.opcion_a)\n"
            preview += "   ✓ \(p.respuesta_correcta)\n\n"
        }
        if generated_questions.count > 3 {
            preview += "...y \(generated_questions.count - 3) pregunta(s) más"
        }

        let attrib = NSMutableAttributedString(string: preview)
        let par = NSMutableParagraphStyle()
        par.lineSpacing = 4
        attrib.addAttribute(.paragraphStyle, value: par, range: NSRange(location: 0, length: preview.count))
        preview_lbl.attributedText = attrib

        preview_lbl.isHidden = false
        save_btn.isHidden = false
    }

    @objc private func didTapSave() {
        guard let nombre = name_field.text, !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
              !generated_questions.isEmpty else { return }

        let cat     = cat_field.text?.isEmpty == false ? cat_field.text! : "General"
        let quiz    = Quiz(nombre: nombre.trimmingCharacters(in: .whitespaces), categoria: cat)
        let quiz_id = SQLiteManager.shared.insertQuiz(quiz)

        guard quiz_id > 0 else {
            showAlert("Error", "No se pudo guardar el quiz.")
            return
        }

        for var p in generated_questions {
            p.id_quiz = quiz_id
            SQLiteManager.shared.insertPregunta(p)
        }

        let saved_count = generated_questions.count

        // Limpiar estado
        name_field.text     = ""
        cat_field.text      = ""
        pdf_lbl.text        = "Ningún archivo seleccionado"
        extracted_text      = ""
        generated_questions = []
        preview_lbl.isHidden = true
        save_btn.isHidden   = true
        info_lbl.text       = "🤖 Selecciona un PDF y QuizIA generará\npreguntas automáticamente con IA"
        info_lbl.textColor  = .systemGray

        let alert = UIAlertController(
            title: "¡Quiz guardado!",
            message: "'\(nombre)' con \(saved_count) pregunta(s) listo para estudiar.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ver Mis Quizzes", style: .default) { _ in
            self.tabBarController?.selectedIndex = 0
        })
        alert.addAction(UIAlertAction(title: "Generar otro", style: .cancel))
        present(alert, animated: true)
    }

    private func showAlert(_ title: String, _ msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Extraer texto del PDF (sin cambios, funciona bien)
    private func extractPDFText(url: URL) -> String {
        guard let pdf = PDFDocument(url: url) else { return "" }
        var text = ""
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i) {
                text += (page.string ?? "") + "\n"
            }
        }
        return text
    }
}

// MARK: - UIDocumentPickerDelegate
extension GeneracionIAViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }

        pdf_lbl.text = url.lastPathComponent
        extracted_text = extractPDFText(url: url)

        if extracted_text.isEmpty {
            pdf_lbl.text = "⚠️ No se pudo extraer texto del PDF"
            info_lbl.text = "El PDF puede estar escaneado o protegido."
            info_lbl.textColor = .systemRed
        } else {
            let chars = extracted_text.count
            info_lbl.text = "✅ PDF cargado: \(chars) caracteres extraídos."
            info_lbl.textColor = .systemGreen
        }
    }
}
