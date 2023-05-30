//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by user on 30.05.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
