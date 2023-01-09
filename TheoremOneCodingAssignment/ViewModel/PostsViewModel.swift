//
//  PostsViewModel.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 08.01.2023.
//

import Foundation
import UIKit

struct PostsViewModel {
    private var posts: [ViewModel]
    private var lastFavoriteIndex = -1
    
    init(posts: [Post]) {
        self.posts = posts.compactMap { ViewModel(post: $0, isFavorite: false) }
    }
    
    // MARK: - Methods for data source
    
    var numberOfRows: Int {
        posts.count
    }
    
    // MARK: - View Model Methods
    
    func viewModel(at index: IndexPath) -> ViewModel {
        posts[index.row]
    }
    
    func post(at index: IndexPath) -> Post? {
        posts[index.row].post
    }

    func postIndex(with tag: Int) -> IndexPath {
        guard let index = posts.firstIndex(where: { $0.post.id == tag }) else {
            return IndexPath(row: posts.count, section: 0)
        }
        return IndexPath(row: index, section: 0)
    }
    
    mutating func toggleFavoriteElement(at index: IndexPath) -> IndexPath {
        let post = posts[index.row]
        let isFavorite: Bool
        let updateLastIndex: Int
        let newIndex: Int
        switch post.isFavorite {
        case true:
            isFavorite = false
            updateLastIndex = -1
            newIndex = findUnfavoriteInsertIndex(for: post)
        case false:
            isFavorite = true
            updateLastIndex = 1
            newIndex = findFavoriteInsertIndex(for: post)
        }
        posts[index.row].isFavorite = isFavorite
        lastFavoriteIndex += updateLastIndex
        return IndexPath(row: newIndex, section: 0)
    }
    
    mutating func move(from index: IndexPath, to moveIndex: IndexPath) {
        guard index != moveIndex else {
            return
        }
        let post = posts.remove(at: index.row)
        posts.insert(post, at: moveIndex.row)
    }
    
    mutating func deletePost(at index: IndexPath) -> Post {
        if posts[index.row].isFavorite {
            lastFavoriteIndex -= 1
        }
        return posts.remove(at: index.row).post
    }
    
    mutating func deleteUnfavoritePosts() -> [Post] {
        if lastFavoriteIndex == -1 {
            let postsToDelete = posts.compactMap { $0.post }
            posts = []
            return postsToDelete
        }
        let slice = posts.suffix(from: lastFavoriteIndex + 1).compactMap { $0.post }
        var elementsForDelete = posts.count - lastFavoriteIndex - 1
        while elementsForDelete > 0 {
            let _ = posts.popLast()
            elementsForDelete -= 1
        }
        return slice
    }
}

private extension PostsViewModel {
    func findUnfavoriteInsertIndex(for model: ViewModel) -> Int {
        guard let index = posts.firstIndex(where: { $0.isFavorite == false && $0.post.id > model.post.id }) else {
            return posts.count - 1
        }
        return index - 1
    }

    func findFavoriteInsertIndex(for model: ViewModel) -> Int {
        guard let index = posts.firstIndex(where: { $0.isFavorite && $0.post.id > model.post.id }) else {
            return lastFavoriteIndex + 1
        }
        return index
    }
}

// MARK: - View Model Elements

extension PostsViewModel {
    struct ViewModel {
        fileprivate let post: Post
        var isFavorite: Bool
        
        init(post: Post, isFavorite: Bool) {
            self.post = post
            self.isFavorite = isFavorite
        }
        
        var postTitle: String {
            post.title
        }
        
        var favoriteIcon: String {
            "star.fill"
        }
        
        var tintColor: UIColor {
            isFavorite ? .systemBlue : .systemGray
        }
        
        var tag: Int {
            Int(post.id)
        }
    }
}
