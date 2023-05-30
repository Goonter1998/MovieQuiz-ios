import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Public Properties
    //MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak private var noButton: UIButton!
    
    @IBOutlet weak private var yesButton: UIButton!
    //MARK: - Private Properties
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticService?
        // MARK: - Pubblic Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - IBAciton
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    //MARK: - Private Methods
    private func setButtonsEnabled(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
                    image: UIImage(named: model.image) ?? UIImage(),
                    question: model.text,
                    questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        setButtonsEnabled(isEnabled: false)
        if (isCorrect == true) {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        }else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.setButtonsEnabled(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else {return}
            statisticService.store(correct: correctAnswers, total: questionsAmount)
                let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy * 100))%"
                let bestGameTime = statisticService.bestGame.date.dateTimeString
                let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
                let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(statisticService.gamesCount)
                            Рекорд: \(bestGameStats) (\(bestGameTime))
                            Средняя точность: \(totalAccuracy)
                           """
            let alert = AlertModel (
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз") { [weak self] _ in
                                       
            guard let self = self else { return }
                self.currentQuestionIndex = 0
                //сбрасываем переменную с количеством правильных ответов
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            alertPresenter?.show(alert)
        }
        else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
