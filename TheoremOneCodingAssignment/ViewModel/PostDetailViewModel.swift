//
//  PostViewModel.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 08.01.2023.
//

import Foundation

struct PostDetailViewModel {
    let post: Post
    var user: User?
    var comments: [Comment]?
    
    init(post: Post, user: User? = nil, comments: [Comment]? = nil) {
        self.post = post
        self.user = user
        self.comments = comments
    }
    
    mutating func update(user: User, comments: [Comment]) {
        self.user = user
        self.comments = comments
    }
    
    var numberOfSections: Int {
        var sections = 1
        if user != nil {
            sections += 1
        }
        if comments != nil {
            sections += 1
        }
        return sections
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        case 2:
            return postCommentsCount
        default:
            return 0
        }
    }
    
    func viewModel(at index: IndexPath) -> ViewModel {
        switch index.section {
        case 0:
            return .post(
                title: postTitle,
                description: postDescription
            )
        case 1:
            return .author(
                name: postAuthorName,
                email: postAuthorEmail
            )
        case 2:
            return .comment(
                authorName: postCommentAuthor(at: index.row),
                description: postCommentText(at: index.row)
            )
        default:
            return .none
        }
    }
    
    func sectionTitle(for section: Int) -> String {
        switch section {
        case 0:
            return "Post"
        case 1:
            return "Author"
        case 2:
            return "Comments"
        default:
            return ""
        }
    }
}

extension PostDetailViewModel {
    enum ViewModel: CaseIterable {
        case post(title: String, description: String)
        case author(name: String, email: String)
        case comment(authorName: String, description: String)
        case none

        static var allCases: [PostDetailViewModel.ViewModel] {
            [
                .post(title: "", description: ""),
                .author(name: "", email: ""),
                .comment(authorName: "", description: "")
            ]
        }
        
        var identifier: String {
            switch self {
            case .post:
                return "PostDetailCellIdentifier"
            case .author:
                return "PostDetailAuthorCellIdentifier"
            case .comment:
                return "PostDetailCommentCellIdentifier"
            case .none:
                return ""
            }
        }
    }
}

private extension PostDetailViewModel {
    var postTitle: String {
        post.title
    }

    var postDescription: String {
        post.body
    }

    var postAuthorName: String {
        user?.username ?? ""
    }

    var postAuthorEmail: String {
        user?.email ?? ""
    }

    var postCommentsCount: Int {
        comments?.count ?? 0
    }

    func postCommentAuthor(at index: Int) -> String {
        comments?[index].name ?? ""
    }

    func postCommentText(at index: Int) -> String {
        comments?[index].body ?? ""
    }
}
