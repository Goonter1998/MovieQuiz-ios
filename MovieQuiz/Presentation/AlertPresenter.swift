//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by user on 28.05.2023.
//

import Foundation
import UIKit
final class AlertPresenter {
    
    func present(view controller: UIViewController, alert model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
