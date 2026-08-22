//
//  BibleChapterView.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import SwiftUI

struct BibleChapterView: View {
    let book: BibleBook

    @StateObject private var viewModel: BibleViewModel = BibleViewModel()
    @State private var chapter: Int = 1

    var body: some View {
        VStack(spacing: 0) {
            chapterPicker

            content
        }
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
        // Runs on first appearance and again whenever the chapter changes.
        .task(id: chapter) {
            await viewModel.loadChapter(bookId: book.id, chapter: chapter)
        }
    }

    private var chapterPicker: some View {
        HStack {
            Button {
                chapter -= 1
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
            }
            .disabled(chapter <= 1)

            Spacer()

            Text("Chapter \(chapter)")
                .font(.headline)

            Spacer()

            Button {
                chapter += 1
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
            }
        }
        .tint(.indigo)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.chapterState {
        case .idle, .loading:
            Spacer()
            ProgressView("Loading \(book.name) \(chapter)…")
            Spacer()
        case .loaded(let verses):
            List(verses) { verse in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(verse.verse)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.indigo)
                        .frame(width: 28, alignment: .trailing)

                    Text(verse.cleanText)
                        .font(.system(.body, design: .serif))
                }
                .padding(.vertical, 2)
            }
            .listStyle(.plain)
        case .failed(let message):
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)

                Text(message)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task {
                        await viewModel.loadChapter(bookId: book.id, chapter: chapter)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        BibleChapterView(book: BibleBook(id: "JHN", name: "John"))
    }
}
