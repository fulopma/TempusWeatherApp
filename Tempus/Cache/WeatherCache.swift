//
//  Cache.swift
//  Tempus
//
//  Created by Marcell Fulop on 7/16/25.
//
import SQLite
import Foundation

/// Custom built cache for weather data
class WeatherCache {
    static let shared = WeatherCache()
    private static var database: Connection?
    private let fileManager = FileManager.default
    private init() {
        do {
            guard let bundleID = Bundle.main.bundleIdentifier else {
                return
            }
            if let appSupportDirectory = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first {
                let folderURL = appSupportDirectory.appendingPathComponent(bundleID)
                // create a folders; if the folder already exists,
                // does nothing and does not throw an error
                try fileManager.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: true
                )
                // similar; connects to database, creates it if it doesn't already exist
                WeatherCache.database = try Connection("\(folderURL)/weather.sqlite")
                let temperatures = Table("temperatures")
                let id = SQLite.Expression<Int64>("id")
                let lat = SQLite.Expression<Double>("lat")
                let long = SQLite.Expression<Double>("long")
                let temp = SQLite.Expression<Double>("temp")
//                try WeatherCache.database?.run(
//                    temperatures.create{ table in
//                        table.column(id, primaryKey: true)
//                        table.column(lat)
//                        table.column(long)
//                        table.column(temp)
//                })
                // I am a backend developer in denial

                #if DEBUG
                // I am going to add a lot of garbage data
                let dropStmt = try WeatherCache.database?.prepare("DROP TABLE IF EXISTS temperatures")
                try dropStmt?.run()
                #endif

                let createStmt = try WeatherCache.database?.prepare(
                """
                CREATE TABLE IF NOT EXISTS temperatures (
                    id INTEGER PRIMARY KEY NOT NULL,
                    lat REAL NOT NULL,
                    long REAL NOT NULL,
                    seconds
                    temp REAL NOT NULL
                )
                """)
                try createStmt?.run()

                #if DEBUG
                let insert = temperatures.insert(lat <- 37.0, long <- -122.5, temp <- 15.0)
                let rowID = try WeatherCache.database?.run(insert) ?? -1
                print("Row ID: \(rowID)")
                if let unwrappedDatabase = WeatherCache.database {
                    for record in try unwrappedDatabase.prepare(temperatures) {
                        print("\(record[id]), \(record[lat]), \(record[long]), \(record[temp])")
                    }
                }
                #endif

                print(WeatherCache.database?.description ?? "Optional Empty")
            }
        } catch {
            print("Database creation failed\n\(error)")
            WeatherCache.database = nil
        }
    }
}
