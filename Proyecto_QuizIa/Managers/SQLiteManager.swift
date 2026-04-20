//
//  SQLiteManager.swift
//  Proyecto_QuizIa
//
//  Created by macbook pro on 4/19/26.
//

import Foundation
import SQLite3

class SQLiteManager {
    static let shared = SQLiteManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("quizia_db.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Error al abrir la base de datos")
            db = nil
        } else {
            print("✅ Base de datos abierta en \(fileURL.path)")
        }
    }

    private func createTables() {
        let createQuizTable = """
        CREATE TABLE IF NOT EXISTS quiz (
            id_quiz INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            categoria TEXT NOT NULL,
            fecha_creacion TEXT NOT NULL
        );
        """

        let createPreguntaTable = """
        CREATE TABLE IF NOT EXISTS pregunta (
            id_pregunta INTEGER PRIMARY KEY AUTOINCREMENT,
            id_quiz INTEGER NOT NULL,
            tipo_pregunta TEXT NOT NULL,
            texto_pregunta TEXT NOT NULL,
            opcion_a TEXT NOT NULL,
            opcion_b TEXT NOT NULL,
            opcion_c TEXT,
            opcion_d TEXT,
            respuesta_correcta TEXT NOT NULL,
            FOREIGN KEY (id_quiz) REFERENCES quiz(id_quiz) ON DELETE CASCADE
        );
        """

        execute(statement: createQuizTable)
        execute(statement: createPreguntaTable)
    }

    private func execute(statement: String) {
        guard db != nil else { return }
        var errMsg: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, statement, nil, nil, &errMsg) != SQLITE_OK {
            let msg = String(cString: errMsg!)
            print("❌ Error SQL: \(msg)")
            sqlite3_free(errMsg)
        }
    }

    // MARK: - Insertar Quiz

    func insertarQuiz(nombre: String, categoria: String) -> Int64? {
        guard db != nil else { return nil }
        let fecha = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let insertSQL = "INSERT INTO quiz (nombre, categoria, fecha_creacion) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (categoria as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (fecha as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                let newId = sqlite3_last_insert_rowid(db)
                sqlite3_finalize(stmt)
                return newId
            }
        }
        sqlite3_finalize(stmt)
        return nil
    }

    // MARK: - Insertar Pregunta

    func insertarPregunta(idQuiz: Int64, tipo: String, texto: String,
                          opA: String, opB: String, opC: String?, opD: String?,
                          respuesta: String) -> Bool {
        guard db != nil else { return false }
        let insertSQL = """
        INSERT INTO pregunta
        (id_quiz, tipo_pregunta, texto_pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int64(stmt, 1, idQuiz)
            sqlite3_bind_text(stmt, 2, (tipo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (texto as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (opA as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (opB as NSString).utf8String, -1, nil)
            if let opC = opC {
                sqlite3_bind_text(stmt, 6, (opC as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(stmt, 6)
            }
            if let opD = opD {
                sqlite3_bind_text(stmt, 7, (opD as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(stmt, 7)
            }
            sqlite3_bind_text(stmt, 8, (respuesta as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                return true
            }
        }
        sqlite3_finalize(stmt)
        return false
    }

    // MARK: - Obtener todos los quizzes (sin preguntas, solo para lista)

    func obtenerQuizzes() -> [(id: Int64, nombre: String, categoria: String, fecha: String)] {
        guard db != nil else { return [] }
        var resultado: [(Int64, String, String, String)] = []
        let query = "SELECT id_quiz, nombre, categoria, fecha_creacion FROM quiz ORDER BY fecha_creacion DESC;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let categoria = String(cString: sqlite3_column_text(stmt, 2))
                let fecha = String(cString: sqlite3_column_text(stmt, 3))
                resultado.append((id, nombre, categoria, fecha))
            }
        }
        sqlite3_finalize(stmt)
        return resultado
    }

    // Cerrar la BD cuando se destruye la instancia (buena práctica)
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
}
