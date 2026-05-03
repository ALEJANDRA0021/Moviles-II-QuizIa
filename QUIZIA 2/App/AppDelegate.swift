//
//  AppDelegate.swift
//  QUIZIA 2
//
//  Created by macbook pro on 3/22/26.
//

import UIKit
 
/*
 * Función:    AppDelegate (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   Eventos del sistema operativo
 * Salidas:    Configuración de sesiones de escena
 * Retorno:    AppDelegate
 * Variables:  Ninguna
 * Rutinas:    application(_:didFinishLaunching:),
 *             application(_:configurationForConnecting:options:)
 * Descripción: Punto de entrada de la app; delega UI a SceneDelegate
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
        func application(
                _ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
                return true
        }
 
        func application(
                _ application: UIApplication,
                configurationForConnecting connectingSceneSession: UISceneSession,
                options: UIScene.ConnectionOptions
        ) -> UISceneConfiguration {
                return UISceneConfiguration(
                        name: "Default Configuration",
                        sessionRole: connectingSceneSession.role
                )
        }
 
        func application(
                _ application: UIApplication,
                didDiscardSceneSessions sceneSessions: Set<UISceneSession>
        ) {}
}
