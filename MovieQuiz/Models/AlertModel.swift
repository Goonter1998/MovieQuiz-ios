//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by user on 30.05.2023.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}
