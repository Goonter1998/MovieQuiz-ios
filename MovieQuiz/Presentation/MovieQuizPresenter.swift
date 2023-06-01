//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by user on 01.06.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
        func show(quiz result: QuizResultsViewModel)
        
        func highlightImageBorder(isCorrectAnswer: Bool)
        func showLoadingIndicator()
        func hideLoadingIndicator()
        func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private let statisticService = StatisticServiceImplementation()
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        return QuizStepViewModel(
            image: image ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        self.proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            statisticService.gamesCount += 1
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" : """
                    Вы ответили на \(correctAnswers) из 10
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
}
