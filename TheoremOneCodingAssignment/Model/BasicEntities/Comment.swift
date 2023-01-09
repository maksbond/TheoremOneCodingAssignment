//
//  Comment.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

/**
 Comment entity
 
 *Values*
 - postId: Unique post identifier
 - id: Unique comment identifier
 - title: Post's title
 - body: Post's body
 
 - Author: Maksym Bondar
 - version: 1.0.0
 */
struct Comment: Decodable, Equatable {
    let postId: UInt64
    let id: UInt64
    let name: String
    let email: String
    let body: String
}
