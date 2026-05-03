//
//  MisQuizzesViewController.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import UIKit

// MARK: - MisQuizzesViewController

/*
 * Función:    MisQuizzesViewController (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   Ninguna
 * Salidas:    Lista de quizzes en UITableView
 * Retorno:    MisQuizzesViewController
 * Variables:  quizzes, table_view, cell_id
 * Rutinas:    setupUI, loadQuizzes, tableView delegate/dataSource
 * Descripción: Pantalla principal que lista todos los quizzes guardados.
 *              Tocar uno inicia el Modo Estudio; swipe elimina.
 */
class MisQuizzesViewController: UIViewController {

        private var quizzes  = [Quiz]()
        private let table_view = UITableView(frame: .zero, style: .plain)
        private let cell_id    = "quiz_cell"
        private let empty_label = UILabel()

        override func viewDidLoad() {
                super.viewDidLoad()
                setupUI()
        }

        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                loadQuizzes()
        }

        // MARK: - Setup

        /*
         * Función:    setupUI
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Interfaz de lista configurada
         * Retorno:    Void
         * Variables:  table_view, empty_label
         * Rutinas:    NSLayoutConstraint.activate
         * Descripción: Configura el UITableView y el label de estado vacío
         */
        private func setupUI() {
                title = "Mis Quizzes"
                view.backgroundColor = .systemBackground

                // Empty state label
                empty_label.text = "No tienes quizzes aún.\nCrea uno en las pestañas ✏️ o 🤖"
                empty_label.font = UIFont.systemFont(ofSize: 16)
                empty_label.textColor = .systemGray
                empty_label.numberOfLines = 0
                empty_label.textAlignment = .center
                empty_label.isHidden = true
                empty_label.translatesAutoresizingMaskIntoConstraints = false

                // Table view
                table_view.delegate   = self
                table_view.dataSource = self
                table_view.register(QuizCell.self, forCellReuseIdentifier: cell_id)
                table_view.rowHeight = 80
                table_view.translatesAutoresizingMaskIntoConstraints = false

                view.addSubview(table_view)
                view.addSubview(empty_label)

                NSLayoutConstraint.activate([
                        table_view.topAnchor.constraint(
                                equalTo: view.safeAreaLayoutGuide.topAnchor),
                        table_view.leadingAnchor.constraint(
                                equalTo: view.leadingAnchor),
                        table_view.trailingAnchor.constraint(
                                equalTo: view.trailingAnchor),
                        table_view.bottomAnchor.constraint(
                                equalTo: view.bottomAnchor),

                        empty_label.centerXAnchor.constraint(
                                equalTo: view.centerXAnchor),
                        empty_label.centerYAnchor.constraint(
                                equalTo: view.centerYAnchor),
                        empty_label.leadingAnchor.constraint(
                                equalTo: view.leadingAnchor, constant: 40),
                        empty_label.trailingAnchor.constraint(
                                equalTo: view.trailingAnchor, constant: -40)
                ])
        }

        /*
         * Función:    loadQuizzes
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    quizzes actualizado, tabla recargada
         * Retorno:    Void
         * Variables:  quizzes
         * Rutinas:    SQLiteManager.getAllQuizzes, tableView.reloadData
         * Descripción: Carga quizzes desde SQLite y actualiza la vista
         */
        private func loadQuizzes() {
                quizzes = SQLiteManager.shared.getAllQuizzes()
                table_view.reloadData()
                empty_label.isHidden = !quizzes.isEmpty
                table_view.isHidden  = quizzes.isEmpty
        }

        /*
         * Función:    showAlert
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   title: String, msg: String
         * Salidas:    Alerta presentada
         * Retorno:    Void
         * Variables:  alert
         * Rutinas:    UIAlertController, present
         * Descripción: Muestra un UIAlertController con mensaje informativo
         */
        private func showAlert(_ title: String, _ msg: String) {
                let alert = UIAlertController(
                        title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }
}

// MARK: - UITableViewDelegate & DataSource

extension MisQuizzesViewController: UITableViewDelegate, UITableViewDataSource {

        func tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
        ) -> Int {
                return quizzes.count
        }

        func tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: cell_id, for: indexPath) as? QuizCell else {
                        return UITableViewCell()
                }
                cell.configure(with: quizzes[indexPath.row])
                return cell
        }

        func tableView(
                _ tableView: UITableView,
                didSelectRowAt indexPath: IndexPath
        ) {
                tableView.deselectRow(at: indexPath, animated: true)
                let quiz = quizzes[indexPath.row]
                let preguntas = SQLiteManager.shared.getPreguntas(quiz_id: quiz.id_quiz)

                guard !preguntas.isEmpty else {
                        showAlert(
                                "Quiz vacío",
                                "'\(quiz.nombre)' no tiene preguntas. Agrégalas desde Manual.")
                        return
                }

                let study_vc = ModoEstudioViewController(quiz: quiz, preguntas: preguntas)
                navigationController?.pushViewController(study_vc, animated: true)
        }

        func tableView(
                _ tableView: UITableView,
                trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
                let del = UIContextualAction(
                        style: .destructive,
                        title: "Eliminar"
                ) { [weak self] _, _, done in
                        guard let self = self else { return }
                        SQLiteManager.shared.deleteQuiz(
                                id: self.quizzes[indexPath.row].id_quiz)
                        self.quizzes.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.empty_label.isHidden = !self.quizzes.isEmpty
                        self.table_view.isHidden  = self.quizzes.isEmpty
                        done(true)
                }
                return UISwipeActionsConfiguration(actions: [del])
        }
}

// MARK: - QuizCell

/*
 * Función:    QuizCell (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   Quiz a mostrar via configure(with:)
 * Salidas:    Celda con nombre, categoría, fecha y badge de preguntas
 * Retorno:    QuizCell
 * Variables:  title_lbl, cat_lbl, date_lbl, badge_lbl
 * Rutinas:    setupCell, configure
 * Descripción: Celda personalizada para mostrar información de un Quiz
 */
class QuizCell: UITableViewCell {

        private let title_lbl = UILabel()
        private let cat_lbl   = UILabel()
        private let date_lbl  = UILabel()
        private let badge_lbl = UILabel()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                setupCell()
        }

        required init?(coder: NSCoder) { fatalError("No storyboard") }

        private func setupCell() {
                // Título
                title_lbl.font = UIFont.boldSystemFont(ofSize: 16)
                title_lbl.translatesAutoresizingMaskIntoConstraints = false

                // Categoría
                cat_lbl.font = UIFont.systemFont(ofSize: 13)
                cat_lbl.textColor = .systemGray
                cat_lbl.translatesAutoresizingMaskIntoConstraints = false

                // Fecha
                date_lbl.font = UIFont.systemFont(ofSize: 12)
                date_lbl.textColor = .systemGray2
                date_lbl.translatesAutoresizingMaskIntoConstraints = false

                // Badge (número de preguntas)
                badge_lbl.font = UIFont.boldSystemFont(ofSize: 12)
                badge_lbl.textColor = .white
                badge_lbl.backgroundColor = .systemPurple
                badge_lbl.textAlignment = .center
                badge_lbl.layer.cornerRadius = 12
                badge_lbl.layer.masksToBounds = true
                badge_lbl.translatesAutoresizingMaskIntoConstraints = false

                contentView.addSubview(title_lbl)
                contentView.addSubview(cat_lbl)
                contentView.addSubview(date_lbl)
                contentView.addSubview(badge_lbl)

                NSLayoutConstraint.activate([
                        badge_lbl.centerYAnchor.constraint(
                                equalTo: contentView.centerYAnchor),
                        badge_lbl.trailingAnchor.constraint(
                                equalTo: contentView.trailingAnchor, constant: -16),
                        badge_lbl.widthAnchor.constraint(
                                greaterThanOrEqualToConstant: 44),
                        badge_lbl.heightAnchor.constraint(equalToConstant: 24),

                        title_lbl.topAnchor.constraint(
                                equalTo: contentView.topAnchor, constant: 12),
                        title_lbl.leadingAnchor.constraint(
                                equalTo: contentView.leadingAnchor, constant: 16),
                        title_lbl.trailingAnchor.constraint(
                                equalTo: badge_lbl.leadingAnchor, constant: -8),

                        cat_lbl.topAnchor.constraint(
                                equalTo: title_lbl.bottomAnchor, constant: 4),
                        cat_lbl.leadingAnchor.constraint(
                                equalTo: contentView.leadingAnchor, constant: 16),

                        date_lbl.topAnchor.constraint(
                                equalTo: cat_lbl.bottomAnchor, constant: 2),
                        date_lbl.leadingAnchor.constraint(
                                equalTo: contentView.leadingAnchor, constant: 16)
                ])

                accessoryType = .disclosureIndicator
        }

        /*
         * Función:    configure
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   quiz: Quiz
         * Salidas:    Celda actualizada con datos del quiz
         * Retorno:    Void
         * Variables:  count
         * Rutinas:    SQLiteManager.countPreguntas
         * Descripción: Rellena los labels con la información del quiz dado
         */
        func configure(with quiz: Quiz) {
                title_lbl.text = quiz.nombre
                cat_lbl.text   = "📚 \(quiz.categoria)"
                date_lbl.text  = quiz.fecha_creacion
                let count = SQLiteManager.shared.countPreguntas(quiz_id: quiz.id_quiz)
                badge_lbl.text = " \(count)P "
        }
}

