//
//  BibleViewModel.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import Foundation
import Combine

// One state per screen section so the UI can show a spinner while loading,
// the data once it arrives, or an error message with a retry option.
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

@MainActor
class BibleViewModel: ObservableObject {
    @Published var verseOfTheDayState: LoadState<BibleVerse> = .idle
    @Published var booksState: LoadState<[BibleBook]> = .idle
    @Published var chapterState: LoadState<[BibleVerse]> = .idle

    let apiService: BibleService = BibleService()

    func loadVerseOfTheDay() async {
        verseOfTheDayState = .loading
        do {
            let verse = try await apiService.fetchRandomVerse()
            verseOfTheDayState = .loaded(verse)
        } catch {
            verseOfTheDayState = .failed(Self.message(for: error))
        }
    }

    func loadBooks() async {
        booksState = .loading
        do {
            let books = try await apiService.fetchBooks()
            booksState = .loaded(books)
        } catch {
            booksState = .failed(Self.message(for: error))
        }
    }

    func loadChapter(bookId: String, chapter: Int) async {
        chapterState = .loading
        do {
            let verses = try await apiService.fetchChapter(bookId: bookId, chapter: chapter)
            chapterState = .loaded(verses)
        } catch {
            chapterState = .failed(Self.message(for: error))
        }
    }

    private static func message(for error: Error) -> String {
        guard let networkError = error as? BibleService.NetworkError else {
            return "Something went wrong. Check your connection and try again."
        }

        switch networkError {
        case .invalidURL:
            return "The Bible URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .invalidStatusCode(404):
            return "That passage could not be found."
        case .invalidStatusCode(let code):
            return "The server returned status code \(code)."
        case .decodingError:
            return "The scripture data could not be decoded."
        }
    }
}
