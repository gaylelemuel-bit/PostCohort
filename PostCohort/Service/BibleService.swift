//
//  BibleService.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import Foundation

class BibleService {
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case invalidStatusCode(Int)
        case decodingError
    }

    // World English Bible (public domain) from bible-api.com — free, no API key.
    private let baseURL = "https://bible-api.com/data/web"

    func fetchBooks() async throws -> [BibleBook] {
        let response: BibleBooksResponse = try await fetch(from: baseURL)
        return response.books
    }

    func fetchChapter(bookId: String, chapter: Int) async throws -> [BibleVerse] {
        let response: BibleChapterResponse = try await fetch(from: "\(baseURL)/\(bookId)/\(chapter)")
        return response.verses
    }

    func fetchRandomVerse() async throws -> BibleVerse {
        let response: RandomVerseResponse = try await fetch(from: "\(baseURL)/random")
        return response.randomVerse
    }

    private func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidStatusCode(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
