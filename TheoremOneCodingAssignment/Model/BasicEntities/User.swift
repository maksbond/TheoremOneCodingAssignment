//
//  User.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

/**
 User entity
 
 *Values*
 - id: Unique user identifier
 - name: User's name
 - username: User's username
 - email: User's e-mail
 - website: User's vebsite
 
 - important: Not all parameters was unwrapped from repsonse.
 - Author: Maksym Bondar
 - version: 1.0.0
 */
struct User: Decodable, Equatable {
    let id: UInt64
    let name: String
    let username: String
    let email: String
    let website: String
}
