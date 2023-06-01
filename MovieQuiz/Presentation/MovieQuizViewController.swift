import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - Public Properties
    //MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak private var noButton: UIButton!
    
    @IBOutlet weak private var yesButton: UIButton!
    //MARK: - Private Properties
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var correctAnswers = 0
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    // MARK: - Pubblic Methods
    override func viewDidLoad() {
        super.viewDidLoad()
            yesButton.layer.cornerRadius = 15
            noButton.layer.cornerRadius = 15
            imageView.layer.cornerRadius = 20
            imageView.layer.masksToBounds = true
            presenter.viewController = self
            alertPresenter = AlertPresenter(delegate: self)
            statisticService = StatisticServiceImplementation()
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            showLoadingIndicator()
    }
    // MARK: - IBAciton
    @IBAction private func noButtonClicked(_ sender: UIButton) {
            presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
            presenter.yesButtonClicked()
        }
    //MARK: - Private Methods
    private func setButtonsEnabled(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    func showAnswerResult(isCorrect: Bool) {
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
        
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else {return}
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy * 100))%"
            let bestGameTime = statisticService.bestGame.date.dateTimeString
            let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let text = """
                            Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)
                            Количество сыгранных квизов: \(statisticService.gamesCount)
                            Рекорд: \(bestGameStats) (\(bestGameTime))
                            Средняя точность: \(totalAccuracy)
                           """
            let alert = AlertModel (
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз") { [weak self] _ in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            alertPresenter?.show(alert)
        }
        else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator() {
            activityIndicator.stopAnimating()
        }
    private func showNetworkError(message: String) {
    hideLoadingIndicator()
    
    let errorModel = AlertModel(title: "Что-то не так!🥲",
                           message: message,
                           buttonText: "Попробовать еще раз") { [weak self] _ in
        guard let self = self else { return }
        
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
        self.questionFactory?.loadData()
        self.showLoadingIndicator()
    }
        alertPresenter?.show(errorModel)
}
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
           questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
 
}
