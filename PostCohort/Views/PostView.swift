//
//  PostView.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import SwiftUI

struct PostView: View {
    @StateObject private var viewModel: PostViewModel = PostViewModel()
    @State private var postIdText: String = ""
    
    var body: some View {
       NavigationStack {
            VStack {
                HStack {
                    TextField("Enter post ID", text: $postIdText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit {
                            searchPost()
                        }
                        .onChange(of: postIdText) { _, newValue in
                            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                viewModel.selectedPost = nil
                                viewModel.errorMessage = ""
                            }
                        }
                    
                    Button {
                        searchPost()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSearch)
                }
                .padding([.top, .horizontal])
                
               if !viewModel.errorMessage.isEmpty {
                   Text(viewModel.errorMessage)
                       .foregroundColor(.red)
                       .padding()
                   
                   Button("Retry") {
                       Task {
                           await viewModel.loadAllPosts()
                       }
                   }
                    
                }
                
                if let selectedPost = viewModel.selectedPost {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Single Post #\(selectedPost.id)")
                            .font(.headline)
                        Text(selectedPost.title)
                            .font(.subheadline)
                            .bold()
                        Text(selectedPost.body)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                List(viewModel.post) { post in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(post.id)")
                            .font(.headline)
                            .frame(width: 32, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.body)
                                .font(.body)
                        }
                    }
                }
            }.navigationTitle("Posts").navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadAllPosts()
            }
        }
    }
    
    private var canSearch: Bool {
        Int(postIdText.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }
    
    private func searchPost() {
        let trimmedPostId = postIdText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let postId = Int(trimmedPostId) else {
            viewModel.errorMessage = "Please enter a valid post ID."
            return
        }
        
        Task {
            await viewModel.loadPost(id: postId)
        }
    }
}

#Preview {
    NavigationStack {
        PostView()
    }
}
