//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by user on 28.05.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
