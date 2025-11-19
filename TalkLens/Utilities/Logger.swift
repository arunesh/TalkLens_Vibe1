//
//  Logger.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import os.log

/// Logging utility for the app
class AppLogger {
    static let shared = AppLogger()

    private let logger: os.Logger

    private init() {
        logger = os.Logger(subsystem: "com.talklens.app", category: "general")
    }

    enum LogLevel {
        case debug
        case info
        case warning
        case error
    }

    static func log(_ message: String, level: LogLevel = .info) {
        let timestamp = Date()
        let formattedMessage = "[\(timestamp)] \(message)"

        switch level {
        case .debug:
            shared.logger.debug("\(formattedMessage)")
        case .info:
            shared.logger.info("\(formattedMessage)")
        case .warning:
            shared.logger.warning("\(formattedMessage)")
        case .error:
            shared.logger.error("\(formattedMessage)")
        }

        #if DEBUG
        print(formattedMessage)
        #endif
    }

    static func logError(_ error: Error) {
        log("Error: \(error.localizedDescription)", level: .error)
    }

    static func debug(_ message: String) {
        log(message, level: .debug)
    }

    static func info(_ message: String) {
        log(message, level: .info)
    }

    static func warning(_ message: String) {
        log(message, level: .warning)
    }

    static func error(_ message: String) {
        log(message, level: .error)
    }
}
