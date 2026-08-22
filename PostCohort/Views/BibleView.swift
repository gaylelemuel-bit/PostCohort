//
//  BibleView.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import SwiftUI

struct BibleView: View {
    @StateObject private var viewModel: BibleViewModel = BibleViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    verseOfTheDayCard
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                booksSections
            }
            .navigationTitle("Bible")
            .task {
                if case .idle = viewModel.verseOfTheDayState {
                    await viewModel.loadVerseOfTheDay()
                }
            }
            .task {
                if case .idle = viewModel.booksState {
                    await viewModel.loadBooks()
                }
            }
        }
    }

    // MARK: - Verse of the Day

    private var verseOfTheDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Verse of the Day", systemImage: "sun.max.fill")
                    .font(.subheadline)
                    .bold()

                Spacer()

                Button {
                    Task {
                        await viewModel.loadVerseOfTheDay()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }

            switch viewModel.verseOfTheDayState {
            case .idle, .loading:
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text("Loading verse…")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            case .loaded(let verse):
                Text("“\(verse.cleanText)”")
                    .font(.system(.body, design: .serif))
                    .italic()

                Text("\(verse.book) \(verse.chapter):\(verse.verse)")
                    .font(.caption)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            case .failed(let message):
                Text("\(message) Tap the refresh button to try again.")
                    .font(.subheadline)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            LinearGradient(colors: [.indigo, .purple],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Books

    @ViewBuilder
    private var booksSections: some View {
        switch viewModel.booksState {
        case .idle, .loading:
            Section("Books") {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading books…")
                        .foregroundStyle(.secondary)
                }
            }
        case .loaded(let books):
            // The API returns the 39 Old Testament books first.
            let oldTestament = Array(books.prefix(39))
            let newTestament = Array(books.dropFirst(39))

            Section("Old Testament") {
                ForEach(oldTestament) { book in
                    bookRow(book)
                }
            }

            if !newTestament.isEmpty {
                Section("New Testament") {
                    ForEach(newTestament) { book in
                        bookRow(book)
                    }
                }
            }
        case .failed(let message):
            Section("Books") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(message)
                        .foregroundColor(.red)

                    Button("Retry") {
                        Task {
                            await viewModel.loadBooks()
                        }
                    }
                }
            }
        }
    }

    private func bookRow(_ book: BibleBook) -> some View {
        NavigationLink {
            BibleChapterView(book: book)
        } label: {
            HStack {
                Image(systemName: "book.closed")
                    .foregroundStyle(.indigo)
                Text(book.name)
            }
        }
    }
}

#Preview {
    BibleView()
}
