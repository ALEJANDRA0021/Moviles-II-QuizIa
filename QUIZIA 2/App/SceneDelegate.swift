//
//  SceneDelegate.swift
//  QUIZIA 2
//
//  Created by macbook pro on 3/22/26.
//

import UIKit
 
/*
 * Función:    SceneDelegate (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   UIScene del sistema
 * Salidas:    Ventana principal configurada
 * Retorno:    SceneDelegate
 * Variables:  window
 * Rutinas:    scene(_:willConnectTo:options:)
 * Descripción: Configura la ventana principal con el TabBarController
 *              de forma programática, sin Storyboard
 */
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
 
        var window: UIWindow?
 
        func scene(
                _ scene: UIScene,
                willConnectTo session: UISceneSession,
                options connectionOptions: UIScene.ConnectionOptions
        ) {
                guard let win_scene = (scene as? UIWindowScene) else { return }
                window = UIWindow(windowScene: win_scene)
                window?.rootViewController = MainTabBarController()
                window?.makeKeyAndVisible()
        }
}
