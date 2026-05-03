//
//  MainTabBarController.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import UIKit

/*
 * Función:    MainTabBarController (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   Ninguna
 * Salidas:    TabBar con 3 pestañas configuradas
 * Retorno:    MainTabBarController
 * Variables:  Ninguna
 * Rutinas:    setupTabs, setupAppearance
 * Descripción: Controlador raíz con navegación por pestañas:
 *              Mis Quizzes, Crear Manual, Generar con IA
 */
class MainTabBarController: UITabBarController {

        override func viewDidLoad() {
                super.viewDidLoad()
                setupTabs()
                setupAppearance()
        }

        /*
         * Función:    setupTabs
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    viewControllers configurados
         * Retorno:    Void
         * Variables:  tab_list, tab_manual, tab_ia
         * Rutinas:    UINavigationController, UITabBarItem
         * Descripción: Crea y asigna los tres NavigationControllers al TabBar
         */
        private func setupTabs() {
                let tab_list = UINavigationController(
                        rootViewController: MisQuizzesViewController()
                )
                tab_list.tabBarItem = UITabBarItem(
                        title: "Mis Quizzes",
                        image: UIImage(systemName: "list.bullet"),
                        tag: 0
                )

                let tab_manual = UINavigationController(
                        rootViewController: CrearQuizViewController()
                )
                tab_manual.tabBarItem = UITabBarItem(
                        title: "Manual",
                        image: UIImage(systemName: "pencil.and.outline"),
                        tag: 1
                )

                let tab_ia = UINavigationController(
                        rootViewController: GeneracionIAViewController()
                )
                tab_ia.tabBarItem = UITabBarItem(
                        title: "IA",
                        image: UIImage(systemName: "wand.and.stars"),
                        tag: 2
                )

                viewControllers = [tab_list, tab_manual, tab_ia]
        }

        /*
         * Función:    setupAppearance
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    TabBar estilizado
         * Retorno:    Void
         * Variables:  Ninguna
         * Rutinas:    UITabBar properties
         * Descripción: Aplica el color morado como tint del TabBar
         */
        private func setupAppearance() {
                tabBar.tintColor = UIColor.systemPurple
                tabBar.backgroundColor = UIColor.systemBackground
        }
}
