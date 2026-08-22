//
//  PostViewModel.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//
import Foundation
import Combine

@MainActor
class PostViewModel: ObservableObject {
    @Published var post: [Post] = []
    @Published var selectedPost: Post?
    @Published var errorMessage: String = ""
    
    let apiService: PostService = PostService()
    
    func loadAllPosts() async {
        do {
            post = try await apiService.fetchAllPosts()
            errorMessage = ""
        } catch let error as PostService.NetworkError {
            let message: String
            
            switch error {
            case .invalidURL:
                message = "The post URL is invalid."
            case .invalidResponse:
                message = "The server returned an invalid response."
            case .invalidStatusCode(let code):
                message = "The server returned status code \(code)."
            case .decodingError:
                message = "The posts could not be decoded."
            }
            
            errorMessage = message
        } catch {
            let message = "Something went wrong. Please try again."
            errorMessage = message
        }
    }
    
    func loadPost(id: Int) async {
        do {
            let fetchedPost = try await apiService.fetchPost(id: id)
            selectedPost = fetchedPost
            errorMessage = ""
            print(fetchedPost)
        } catch let error as PostService.NetworkError {
            let message: String
            
            switch error {
            case .invalidURL:
                message = "The post URL is invalid."
            case .invalidResponse:
                message = "The server returned an invalid response."
            case .invalidStatusCode(let code):
                message = "The server returned status code \(code)."
            case .decodingError:
                message = "The post could not be decoded."
            }
            
            errorMessage = message
        } catch {
            let message = "Something went wrong. Please try again."
            errorMessage = message
        }
    }
}
