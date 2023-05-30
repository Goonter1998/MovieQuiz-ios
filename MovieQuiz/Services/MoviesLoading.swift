//
//  MoviesLoading.swift
//  MovieQuiz
//
//  Created by user on 30.05.2023.
//

import Foundation
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
