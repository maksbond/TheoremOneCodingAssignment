//
//  Post.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

/**
 Post entity
 
 *Values*
 - userId: Unique user identifier
 - id: Unique post identifier
 - title: Post's title
 - body: Post's body
 
 - Author: Maksym Bondar
 - version: 1.0.0
 */
struct Post: Decodable, Equatable {
    let userId: UInt64
    let id: UInt64
    let title: String
    let body: String
}
