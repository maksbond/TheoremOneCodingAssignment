//
//  PostsViewModel.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 08.01.2023.
//

import Foundation
import UIKit

struct PostsViewModel {
    var posts: [ViewModel]
    private var lastFavoriteIndex = -1
    
    init(posts: [Post]) {
        self.posts = posts.compactMap { ViewModel(post: $0, isFavorite: false) }
        checkForFavorites()
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
}

private extension PostsViewModel {
    mutating func checkForFavorites() {
        
    }
    
    func findUnfavoriteInsertIndex(for model: ViewModel) -> Int {
        guard let index = posts.firstIndex(where: { $0.isFavorite == false && $0.post.id > model.post.id }) else {
            return posts.count
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
            post.title + "___ \(post.id)"
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

