//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by user on 29.05.2023.
//

import Foundation
final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame < newGame {
            bestGame = newGame
        }
        if gamesCount != 0 {
            totalAccuracy = (Double(totalAccuracy) * Double(gamesCount) + (Double(newGame.correct) / Double(newGame.total))) / Double(gamesCount + 1)
        } else {
            totalAccuracy = (Double(newGame.correct) / Double(newGame.total))
        }
        gamesCount += 1
    }
    
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно получить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}
