import Foundation
//
//  Cache.swift
//  Tempus
//
//  Created by Marcell Fulop on 7/16/25.
//
import SQLite

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
            if let cacheDirectory = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first {
                let folderURL = cacheDirectory.appendingPathComponent(
                    bundleID
                )
                // create a folders; if the folder already exists,
                // does nothing and does not throw an error
                try fileManager.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: true
                )
                // similar; connects to database, creates it if it doesn't already exist
                WeatherCache.database = try Connection(
                    "\(folderURL)/weather.sqlite"
                )
                // I am a backend developer in denial
                #if DEBUG
                    // I am going to add a lot of garbage data
                    let dropStmt = try WeatherCache.database?.prepare(
                        "DROP TABLE IF EXISTS weather;"
                    )
                    try dropStmt?.run()
                #endif
                // Seconds is seconds since unix epoch; negative seconds indicate time before Epoch
                let createStmt = try WeatherCache.database?.prepare(
                    """
                    CREATE TABLE IF NOT EXISTS weather (
                        id INTEGER PRIMARY KEY NOT NULL,
                        lat REAL NOT NULL,
                        long REAL NOT NULL,
                        seconds REAL NOT NULL,
                        temp REAL NOT NULL,
                        precip REAL NOT NULL
                    );
                    """
                )
                // Yes, they are basically identical, but since the API uses two different services
                try createStmt?.run()
                print(WeatherCache.database?.description ?? "Optional Empty")
            }
        } catch {
            print("Database creation failed\n\(error)")
            WeatherCache.database = nil
        }
    }
    func fetchRecord(at lat: Double, _ long: Double, during: TimeInterval)
    -> (temp: Double, precip: Double)? {
        do {
            let fetchStmt = try WeatherCache.database?.prepare(
                """
                SELECT temp, precip FROM weather WHERE lat = ? AND long = ? AND seconds = ?;
                """
            )
            if let stmt = fetchStmt {
                for row in try stmt.run(lat, long, during) {
                    // row[0] = temp, row[1] = precip
                    if let temp = row[0] as? Double, let precip = row[1] as? Double {
                        return (temp, precip)
                    }
                }
            }
        } catch {
            print("Fetch failed\n\(error)")
        }
        return nil
    }
    func insertRecord(_ record: WeatherRecord) {
        do {
            guard let database = WeatherCache.database else {
                print("Database not open. No record added.")
                return
            }
            // Sanitized Input
            let insertStmt = try database.prepare(
                """
                INSERT INTO weather (lat, long, seconds, temp, precip) VALUES
                (?, ?, ?, ?, ?);
                """
            )
            try insertStmt.run(
                record.latitude,
                record.longitude,
                record.secondsSinceUnixEpoch,
                record.temperature,
                record.precipitationWeekSum
            )
        } catch {
            print("Record not added. Error: \(error)")
        }
    }
}

struct WeatherRecord {
    let latitude: Double
    let longitude: Double
    let secondsSinceUnixEpoch: Double
    let temperature: Double
    let precipitationWeekSum: Double
    init(_ latitude: Double,
         _ longitude: Double,
         _ secondsSinceUnixEpoch: Double,
         _ temperature: Double,
         _ precipitationWeekSum: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.secondsSinceUnixEpoch = secondsSinceUnixEpoch
        self.temperature = temperature
        self.precipitationWeekSum = precipitationWeekSum
    }
}
