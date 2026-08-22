//
//  ContentView.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BibleView()
                .tabItem {
                    Label("Bible", systemImage: "book.fill")
                }

            PostView()
                .tabItem {
                    Label("Posts", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
