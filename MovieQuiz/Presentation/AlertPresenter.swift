//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by user on 28.05.2023.
//

import Foundation
import UIKit
class AlertPresenter {

   private weak var delegate: UIViewController?
    func show(_ alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: alertModel.completion)
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
}

