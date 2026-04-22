//
//  MisQuizzesViewController.swift
//  Proyecto_QuizIa
//
//  Created by Miguel on 22/4/26.
//
import UIKit

class MisQuizzesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

        @IBOutlet weak var tablaQuizzes: UITableView!
        
        var listaQuizzes: [String] = []

        override func viewDidLoad() {
                super.viewDidLoad()
                configurarTabla()
        }

        /**
         * Entradas: Ninguna
         * Salidas: Configuración visual de la tabla
         * Valor de retorno: Ninguno
         * Función: Asigna los delegados y datos simulados a la tabla
         * Variables: tablaQuizzes, listaQuizzes
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: Ninguna
         */
        func configurarTabla() {
                tablaQuizzes.delegate = self
                tablaQuizzes.dataSource = self
                listaQuizzes = ["Redes 5G", "Auditoría", "SwiftUI"]
        }

        // MARK: - Métodos obligatorios de la tabla
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return listaQuizzes.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let celda = tableView.dequeueReusableCell(withIdentifier: "CeldaQuiz", for: indexPath)
                celda.textLabel?.text = listaQuizzes[indexPath.row]
                return celda
        }
}
