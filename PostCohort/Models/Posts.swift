//
//  Posts.swift
//  PostCohort
//
//  Created by Lemuel Gayle on 8/18/26.
//

import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}
