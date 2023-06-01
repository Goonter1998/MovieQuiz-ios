import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    
    
    // MARK: - Public Properties
    //MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    //MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    // MARK: - Pubblic Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
        //presenter.questionFactory?.loadData()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        setButtonsEnabled(true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertViewModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] _ in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.presenter.restartGame()
        })
        
        let alert = AlertPresenter()
        alert.present(view: self, alert: alertViewModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.presenter.restartGame()
        }
        
        let alert = AlertPresenter()
        alert.present(view: self, alert: model)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        setButtonsEnabled(false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        setButtonsEnabled(false)
    }
    func setButtonsEnabled(_ isEnabled: Bool) {
            yesButton.isEnabled = isEnabled
            noButton.isEnabled = isEnabled
        }
}
