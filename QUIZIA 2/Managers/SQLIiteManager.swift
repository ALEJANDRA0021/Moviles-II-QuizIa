//
//  SQLIiteManager.swift
//  QUIZIA 2
//
//  Created by macbook pro on 5/3/26.
//

import Foundation
import SQLite3

/*
 * Función:    SQLiteManager (class)
 * Autor:      QuizIA Team
 * Fecha:      30/04/2026
 * Entradas:   Ninguna (singleton)
 * Salidas:    Acceso a operaciones CRUD
 * Retorno:    SQLiteManager
 * Variables:  db, shared
 * Rutinas:    openDB, createTables, insertQuiz, getAllQuizzes,
 *             deleteQuiz, insertPregunta, getPreguntas, countPreguntas
 * Descripción: Gestor de base de datos SQLite local para Quiz y Pregunta
 */
class SQLiteManager {

        static let shared = SQLiteManager()
        private var db: OpaquePointer?

        private init() {
                openDB()
                createTables()
        }

        // MARK: - Configuración

        /*
         * Función:    openDB
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Ninguna (abre conexión interna)
         * Retorno:    Void
         * Variables:  path, db
         * Rutinas:    sqlite3_open
         * Descripción: Abre o crea el archivo quizia.db en Documents
         */
        private func openDB() {
                let doc_url = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask)[0]
                let db_path = doc_url.appendingPathComponent("quizia.db").path
                if sqlite3_open(db_path, &db) != SQLITE_OK {
                        print("QuizIA - Error al abrir BD: \(String(cString: sqlite3_errmsg(db)))")
                }
        }

        /*
         * Función:    createTables
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Ninguna
         * Retorno:    Void
         * Variables:  quiz_sql, pregunta_sql
         * Rutinas:    sqlite3_exec
         * Descripción: Crea tablas QUIZ y PREGUNTA si no existen
         */
        private func createTables() {
                let quiz_sql = """
                CREATE TABLE IF NOT EXISTS QUIZ (
                        id_quiz         INTEGER PRIMARY KEY AUTOINCREMENT,
                        nombre          TEXT    NOT NULL,
                        categoria       TEXT    NOT NULL,
                        fecha_creacion  TEXT    NOT NULL
                );
                """
                let pregunta_sql = """
                CREATE TABLE IF NOT EXISTS PREGUNTA (
                        id_pregunta       INTEGER PRIMARY KEY AUTOINCREMENT,
                        id_quiz           INTEGER NOT NULL,
                        tipo_pregunta     TEXT    NOT NULL,
                        texto_pregunta    TEXT    NOT NULL,
                        opcion_a          TEXT    NOT NULL,
                        opcion_b          TEXT    NOT NULL,
                        opcion_c          TEXT,
                        opcion_d          TEXT,
                        respuesta_correcta TEXT   NOT NULL,
                        FOREIGN KEY (id_quiz) REFERENCES QUIZ(id_quiz)
                );
                """
                sqlite3_exec(db, quiz_sql, nil, nil, nil)
                sqlite3_exec(db, pregunta_sql, nil, nil, nil)
        }

        // MARK: - CRUD Quiz

        /*
         * Función:    insertQuiz
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   quiz: Quiz
         * Salidas:    ID del quiz insertado o -1 si falla
         * Retorno:    Int
         * Variables:  sql, stmt, last_id
         * Rutinas:    sqlite3_prepare_v2, sqlite3_bind_text, sqlite3_step,
         *             sqlite3_last_insert_rowid, sqlite3_finalize
         * Descripción: Inserta un nuevo quiz en la tabla QUIZ
         */
        func insertQuiz(_ quiz: Quiz) -> Int {
                let sql = """
                INSERT INTO QUIZ (nombre, categoria, fecha_creacion)
                VALUES (?, ?, ?);
                """
                var stmt: OpaquePointer?
                var last_id = -1
                if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                        sqlite3_bind_text(stmt, 1, (quiz.nombre as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 2, (quiz.categoria as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 3, (quiz.fecha_creacion as NSString).utf8String, -1, nil)
                        if sqlite3_step(stmt) == SQLITE_DONE {
                                last_id = Int(sqlite3_last_insert_rowid(db))
                        }
                }
                sqlite3_finalize(stmt)
                return last_id
        }

        /*
         * Función:    getAllQuizzes
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   Ninguna
         * Salidas:    Array de Quiz ordenados por ID descendente
         * Retorno:    [Quiz]
         * Variables:  sql, stmt, quizzes
         * Rutinas:    sqlite3_prepare_v2, sqlite3_step, sqlite3_column_*
         * Descripción: Recupera todos los quizzes almacenados en la BD
         */
        func getAllQuizzes() -> [Quiz] {
                var quizzes = [Quiz]()
                let sql = """
                SELECT id_quiz, nombre, categoria, fecha_creacion
                FROM QUIZ ORDER BY id_quiz DESC;
                """
                var stmt: OpaquePointer?
                if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                        while sqlite3_step(stmt) == SQLITE_ROW {
                                let id    = Int(sqlite3_column_int(stmt, 0))
                                let nom   = String(cString: sqlite3_column_text(stmt, 1))
                                let cat   = String(cString: sqlite3_column_text(stmt, 2))
                                let fecha = String(cString: sqlite3_column_text(stmt, 3))
                                quizzes.append(
                                        Quiz(id_quiz: id, nombre: nom,
                                             categoria: cat, fecha_creacion: fecha)
                                )
                        }
                }
                sqlite3_finalize(stmt)
                return quizzes
        }

        /*
         * Función:    deleteQuiz
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   id: Int
         * Salidas:    Ninguna
         * Retorno:    Void
         * Variables:  sql_preg, sql_quiz, stmt
         * Rutinas:    sqlite3_prepare_v2, sqlite3_bind_int, sqlite3_step
         * Descripción: Elimina un quiz y todas sus preguntas asociadas
         */
        func deleteQuiz(id: Int) {
                var stmt: OpaquePointer?
                let sql_preg = "DELETE FROM PREGUNTA WHERE id_quiz = ?;"
                if sqlite3_prepare_v2(db, sql_preg, -1, &stmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(stmt, 1, Int32(id))
                        sqlite3_step(stmt)
                }
                sqlite3_finalize(stmt)

                let sql_quiz = "DELETE FROM QUIZ WHERE id_quiz = ?;"
                if sqlite3_prepare_v2(db, sql_quiz, -1, &stmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(stmt, 1, Int32(id))
                        sqlite3_step(stmt)
                }
                sqlite3_finalize(stmt)
        }

        // MARK: - CRUD Pregunta

        /*
         * Función:    insertPregunta
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   pregunta: Pregunta
         * Salidas:    Ninguna
         * Retorno:    Void
         * Variables:  sql, stmt
         * Rutinas:    sqlite3_prepare_v2, sqlite3_bind_*, sqlite3_step
         * Descripción: Inserta una pregunta asociada a un quiz en la BD
         */
        func insertPregunta(_ pregunta: Pregunta) {
                let sql = """
                INSERT INTO PREGUNTA
                (id_quiz, tipo_pregunta, texto_pregunta,
                 opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?);
                """
                var stmt: OpaquePointer?
                if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(stmt,  1, Int32(pregunta.id_quiz))
                        sqlite3_bind_text(stmt, 2, (pregunta.tipo_pregunta as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 3, (pregunta.texto_pregunta as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 4, (pregunta.opcion_a as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 5, (pregunta.opcion_b as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 6, (pregunta.opcion_c as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 7, (pregunta.opcion_d as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(stmt, 8, (pregunta.respuesta_correcta as NSString).utf8String, -1, nil)
                        sqlite3_step(stmt)
                }
                sqlite3_finalize(stmt)
        }

        /*
         * Función:    getPreguntas
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   quiz_id: Int
         * Salidas:    Array de Pregunta del quiz indicado
         * Retorno:    [Pregunta]
         * Variables:  sql, stmt, preguntas
         * Rutinas:    sqlite3_prepare_v2, sqlite3_step, sqlite3_column_*
         * Descripción: Recupera todas las preguntas de un quiz específico
         */
        func getPreguntas(quiz_id: Int) -> [Pregunta] {
                var preguntas = [Pregunta]()
                let sql = "SELECT * FROM PREGUNTA WHERE id_quiz = ?;"
                var stmt: OpaquePointer?
                if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(stmt, 1, Int32(quiz_id))
                        while sqlite3_step(stmt) == SQLITE_ROW {
                                let id_p  = Int(sqlite3_column_int(stmt, 0))
                                let id_q  = Int(sqlite3_column_int(stmt, 1))
                                let tipo  = String(cString: sqlite3_column_text(stmt, 2))
                                let texto = String(cString: sqlite3_column_text(stmt, 3))
                                let a     = String(cString: sqlite3_column_text(stmt, 4))
                                let b     = String(cString: sqlite3_column_text(stmt, 5))
                                let c     = sqlite3_column_text(stmt, 6).map { String(cString: $0) } ?? ""
                                let d     = sqlite3_column_text(stmt, 7).map { String(cString: $0) } ?? ""
                                let resp  = String(cString: sqlite3_column_text(stmt, 8))
                                preguntas.append(
                                        Pregunta(
                                                id_pregunta: id_p, id_quiz: id_q,
                                                tipo_pregunta: tipo, texto_pregunta: texto,
                                                opcion_a: a, opcion_b: b,
                                                opcion_c: c, opcion_d: d,
                                                respuesta_correcta: resp
                                        )
                                )
                        }
                }
                sqlite3_finalize(stmt)
                return preguntas
        }

        /*
         * Función:    countPreguntas
         * Autor:      QuizIA Team
         * Fecha:      30/04/2026
         * Entradas:   quiz_id: Int
         * Salidas:    Número de preguntas del quiz
         * Retorno:    Int
         * Variables:  sql, stmt, count
         * Rutinas:    sqlite3_prepare_v2, sqlite3_column_int
         * Descripción: Cuenta las preguntas asociadas a un quiz específico
         */
        func countPreguntas(quiz_id: Int) -> Int {
                let sql = "SELECT COUNT(*) FROM PREGUNTA WHERE id_quiz = ?;"
                var stmt: OpaquePointer?
                var count = 0
                if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(stmt, 1, Int32(quiz_id))
                        if sqlite3_step(stmt) == SQLITE_ROW {
                                count = Int(sqlite3_column_int(stmt, 0))
                        }
                }
                sqlite3_finalize(stmt)
                return count
        }
}

