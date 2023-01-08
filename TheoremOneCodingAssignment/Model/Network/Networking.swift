//
//  Networking.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

protocol Networking {
    func fetchPosts() async throws -> [Post]
    func fetchUser(for post: Post) async throws -> User
    func fetchComments(for post: Post) async throws -> [Comment]
    func delete(post: Post) async throws
}
