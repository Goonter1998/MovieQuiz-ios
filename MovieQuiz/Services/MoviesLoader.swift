//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by user on 30.05.2023.
//

import Foundation
struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_v1l1574t") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
        func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
            networkClient.fetch(url: mostPopularMoviesUrl) { result in
                switch result {
                case .success(let data):
                    do {
                        let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                        handler(.success(mostPopularMovies))
                        } catch {
                        handler(.failure(error))
                                }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
}
