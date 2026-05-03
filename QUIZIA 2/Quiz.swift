//
//  Quiz.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import Foundation

/*
 * Función:    Quiz (struct)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   id_quiz, nombre, categoria, fecha_creacion
 * Salidas:    Instancia de Quiz
 * Retorno:    Quiz
 * Variables:  id_quiz, nombre, categoria, fecha_creacion
 * Rutinas:    today()
 * Descripción: Modelo de datos que representa un cuestionario
 */
struct Quiz {
        var id_quiz: Int
        var nombre: String
        var categoria: String
        var fecha_creacion: String

        init(
                id_quiz: Int = 0,
                nombre: String,
                categoria: String,
                fecha_creacion: String = ""
        ) {
                self.id_quiz = id_quiz
                self.nombre = nombre
                self.categoria = categoria
                self.fecha_creacion = fecha_creacion.isEmpty ? Quiz.today() : fecha_creacion
        }

        /*
         * Función:    today
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Fecha actual como String
         * Retorno:    String
         * Variables:  fmt
         * Rutinas:    DateFormatter
         * Descripción: Retorna la fecha actual en formato dd/MM/yyyy
         */
        static func today() -> String {
                let fmt = DateFormatter()
                fmt.dateFormat = "dd/MM/yyyy"
                return fmt.string(from: Date())
        }
}

