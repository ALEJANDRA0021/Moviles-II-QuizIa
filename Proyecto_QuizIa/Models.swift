//
//  Models.swift
//  Proyecto_QuizIa
//
//  Created by macbook pro on 4/19/26.
//

import Foundation

struct Quiz {
    let id: Int64
    var nombre: String
    var categoria: String
    var fechaCreacion: String
    var preguntas: [Pregunta]
}

struct Pregunta {
    let id: Int64?
    var idQuiz: Int64
    var tipo: TipoPregunta
    var texto: String
    var opcionA: String
    var opcionB: String
    var opcionC: String?
    var opcionD: String?
    var respuestaCorrecta: String
}

enum TipoPregunta: String {
    case multiple = "multiple"
    case verdaderoFalso = "verdadero_falso"
}
