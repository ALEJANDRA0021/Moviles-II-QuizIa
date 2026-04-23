//
//  MisQuizzesViewController.swift
//  Proyecto_QuizIa
//
//  Created by Miguel on 22/4/26.
//

import UIKit

class MisQuizzesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

        @IBOutlet weak var tabla_quizzes: UITableView!
        
        var lista_quizzes: [(id: Int64, nombre: String, categoria: String, fecha: String)] = []
        var id_seleccionado: Int64 = 0

        override func viewDidLoad() {
                super.viewDidLoad()
                configurarTabla()
        }

        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                cargarDatosDesdeBD()
        }

        /**
         * Entradas: Ninguna
         * Salidas: Datos de la base de datos
         * Valor de retorno: Ninguno
         * Función: Obtiene los quizzes reales y refresca la interfaz
         * Variables: lista_quizzes, tabla_quizzes
         * Fecha: 22-04-2026
         * Autor: Miguel Alexander Córdova Torres
         * Rutinas anexas: obtenerQuizzes()
         */
        func cargarDatosDesdeBD() {
                lista_quizzes = SQLiteManager.shared.obtenerQuizzes()
                tabla_quizzes.reloadData()
        }

        func configurarTabla() {
                tabla_quizzes.delegate = self
                tabla_quizzes.dataSource = self
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return lista_quizzes.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let celda = tableView.dequeueReusableCell(withIdentifier: "CeldaQuiz", for: indexPath)
                celda.textLabel?.text = lista_quizzes[indexPath.row].nombre
                return celda
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                // Guardamos el ID real de la base de datos
                id_seleccionado = lista_quizzes[indexPath.row].id
                performSegue(withIdentifier: "irAModoEstudio", sender: nil)
        }

        // MARK: - Paso de Datos (El "Transporte")
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "irAModoEstudio" {
                        let destino_vc = segue.destination as! ModoEstudioViewController
                        // Pasamos el ID real a la siguiente pantalla
                        destino_vc.id_quiz_actual = Int(id_seleccionado)
                }
        }
    /**
             * Entradas: tableView, editingStyle, indexPath
             * Salidas: Fila eliminada visualmente y en BD
             * Valor de retorno: Ninguno
             * Función: Elimina un quiz al deslizar la celda a la izquierda
             * Variables: id_borrar, exito_bd
             * Fecha: 22-04-2026
             * Autor: Miguel Alexander Córdova Torres
             * Rutinas anexas: eliminarQuiz()
             */
            func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                    
                    // Usamos if en lugar de switch para cumplir la rúbrica
                    if editingStyle == .delete {
                            // 1. Identificamos qué quiz quiere borrar el usuario
                            let id_borrar = lista_quizzes[indexPath.row].id
                            
                            // 2. Le pedimos a la BD de Alejandra que lo destruya
                            let exito_bd = SQLiteManager.shared.eliminarQuiz(idQuiz: Int(id_borrar))
                            
                            // 3. Si la BD lo borró con éxito, lo quitamos de la pantalla
                            if exito_bd == true {
                                    lista_quizzes.remove(at: indexPath.row)
                                    tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                    }
            }
    
}
