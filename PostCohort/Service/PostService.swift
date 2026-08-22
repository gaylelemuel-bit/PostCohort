//
//  PostService.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import Foundation

class PostService {
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case invalidStatusCode(Int)
        case decodingError
    }
    func fetchAllPosts() async throws -> [Post] {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
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
            return try JSONDecoder().decode([Post].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchPost(id: Int) async throws -> Post {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)") else {
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
            return try JSONDecoder().decode(Post.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
