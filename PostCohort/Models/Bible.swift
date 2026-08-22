//
//  Bible.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import Foundation

struct BibleTranslation: Codable {
    let identifier: String
    let name: String
}

struct BibleBook: Codable, Identifiable {
    let id: String
    let name: String
}

struct BibleVerse: Codable, Identifiable {
    let bookId: String
    let book: String
    let chapter: Int
    let verse: Int
    let text: String

    // The API has no unique verse ID, so build one from the reference.
    var id: String { "\(bookId)-\(chapter)-\(verse)" }

    // The API returns verse text with trailing newlines.
    var cleanText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum CodingKeys: String, CodingKey {
        case bookId = "book_id"
        case book
        case chapter
        case verse
        case text
    }
}

struct BibleBooksResponse: Codable {
    let translation: BibleTranslation
    let books: [BibleBook]
}

struct BibleChapterResponse: Codable {
    let translation: BibleTranslation
    let verses: [BibleVerse]
}

struct RandomVerseResponse: Codable {
    let translation: BibleTranslation
    let randomVerse: BibleVerse

    enum CodingKeys: String, CodingKey {
        case translation
        case randomVerse = "random_verse"
    }
}
