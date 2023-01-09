//
//  PostsViewModelTests.swift
//  TheoremOneCodingAssignmentTests
//
//  Created by Maksym Bondar on 09.01.2023.
//

import XCTest
@testable import TheoremOneCodingAssignment

final class PostsViewModelTests: XCTestCase {
    
    var posts: [Post]!
    var postsViewModel: PostsViewModel!
    
    override func setUpWithError() throws {
        posts = [
            Post(userId: 1, id: 1, title: "1", body: "Text 1"),
            Post(userId: 1, id: 2, title: "2", body: "Text 2"),
            Post(userId: 1, id: 3, title: "3", body: "Text 3"),
            Post(userId: 1, id: 4, title: "4", body: "Text 4"),
            Post(userId: 1, id: 5, title: "5", body: "Text 5")
        ]
        postsViewModel = PostsViewModel(posts: posts)
    }

    override func tearDownWithError() throws {
        posts = nil
        postsViewModel = nil
    }

    func testPostsViewModel_init() throws {
        XCTAssertEqual(posts.count, postsViewModel.numberOfRows)
        for (index, post) in posts.enumerated() {
            let postInModel = postsViewModel.post(at: IndexPath(row: index, section: 0))
            XCTAssertEqual(postInModel, post)
        }
    }

    func testPostsViewModel_ViewModel_init() throws {
        for (index, post) in posts.enumerated() {
            let viewModel = postsViewModel.viewModel(at: IndexPath(row: index, section: 0))
            XCTAssertEqual(viewModel.postTitle, post.title)
            XCTAssertEqual(viewModel.favoriteIcon, "star.fill")
            XCTAssertEqual(viewModel.tintColor, .systemGray)
            XCTAssertEqual(viewModel.tag, Int(post.id))
        }
    }
    
    func testPostsViewModel_ViewModel_FavoriteChange() throws {
        var viewModel = PostsViewModel.ViewModel(post: posts[0], isFavorite: false)
        XCTAssertEqual(viewModel.tintColor, .systemGray)
        viewModel.isFavorite = true
        XCTAssertEqual(viewModel.tintColor, .systemBlue)
    }
    
    func testPostsViewModel_viewModelAtIndex() throws {
        for (index, post) in posts.enumerated() {
            let postInModel = postsViewModel.viewModel(at: IndexPath(row: index, section: 0))
            XCTAssertEqual(postInModel.tag, Int(post.id))
            XCTAssertEqual(postInModel.postTitle, post.title)
        }
    }

    func testPostsViewModel_postIndexWithTag() throws {
        for (index, post) in posts.enumerated() {
            let indexPath = postsViewModel.postIndex(with: Int(post.id))
            XCTAssertEqual(indexPath, IndexPath(row: index, section: 0))
        }
    }

    func testPostsViewModel_postIndexWithInvalidTag() throws {
        XCTAssertEqual(postsViewModel.postIndex(with: 100), IndexPath(row: posts.count, section: 0))
    }
    
    func testPostsViewModel_toggleFavoriteElementAtIndex() throws {
        // First unfavorite post
        var toggleIndex = IndexPath(row: 0, section: 0)
        var moveIndex = postsViewModel.toggleFavoriteElement(at: toggleIndex)
        var expectedMoveIndex = IndexPath(row: 0, section: 0)
        XCTAssertEqual(moveIndex, expectedMoveIndex)
        XCTAssertTrue(postsViewModel.viewModel(at: toggleIndex).isFavorite)
        postsViewModel.move(from: toggleIndex, to: moveIndex)
        // Last unfavorite post
        toggleIndex = IndexPath(row: 4, section: 0)
        moveIndex = postsViewModel.toggleFavoriteElement(at: toggleIndex)
        expectedMoveIndex = IndexPath(row: 1, section: 0)
        XCTAssertEqual(moveIndex, expectedMoveIndex)
        XCTAssertTrue(postsViewModel.viewModel(at: toggleIndex).isFavorite)
        postsViewModel.move(from: toggleIndex, to: moveIndex)
        // middle unfavorite post
        toggleIndex = IndexPath(row: 3, section: 0)
        moveIndex = postsViewModel.toggleFavoriteElement(at: toggleIndex)
        XCTAssertEqual(moveIndex, expectedMoveIndex)
        XCTAssertTrue(postsViewModel.viewModel(at: toggleIndex).isFavorite)
        postsViewModel.move(from: toggleIndex, to: moveIndex)
        
        // Toggle favorite posts
        
        // middle unfavorite post
        toggleIndex = IndexPath(row: 1, section: 0)
        moveIndex = postsViewModel.toggleFavoriteElement(at: toggleIndex)
        expectedMoveIndex = IndexPath(row: 3, section: 0)
        XCTAssertEqual(moveIndex, expectedMoveIndex)
        XCTAssertFalse(postsViewModel.viewModel(at: toggleIndex).isFavorite)
        postsViewModel.move(from: toggleIndex, to: moveIndex)
        // Last unfavorite post
        toggleIndex = IndexPath(row: 1, section: 0)
        moveIndex = postsViewModel.toggleFavoriteElement(at: toggleIndex)
        expectedMoveIndex = IndexPath(row: 4, section: 0)
        XCTAssertEqual(moveIndex, expectedMoveIndex)
        XCTAssertFalse(postsViewModel.viewModel(at: toggleIndex).isFavorite)
        postsViewModel.move(from: toggleIndex, to: moveIndex)
        // First unfavorite post
        toggleIndex = IndexPath(row: 0, section: 0)
        moveIndex = postsViewModel.toggleFavoriteElement(at: toggleIndex)
        expectedMoveIndex = IndexPath(row: 0, section: 0)
        XCTAssertEqual(moveIndex, expectedMoveIndex)
        XCTAssertFalse(postsViewModel.viewModel(at: toggleIndex).isFavorite)
        postsViewModel.move(from: toggleIndex, to: moveIndex)
    }
    
    func testPostsViewModel_moveFromIndexToMoveIndex() throws {
        // Same index
        var index = IndexPath(row: 0, section: 0)
        var moveIndex = IndexPath(row: 0, section: 0)
        postsViewModel.move(from: index, to: moveIndex)
        XCTAssertEqual(postsViewModel.post(at: index), posts[0])
        // Move lower in array
        index = IndexPath(row: 0, section: 0)
        moveIndex = IndexPath(row: 4, section: 0)
        postsViewModel.move(from: index, to: moveIndex)
        XCTAssertEqual(postsViewModel.post(at: moveIndex), posts[0])
        // Move higher in array
        index = IndexPath(row: 4, section: 0)
        moveIndex = IndexPath(row: 0, section: 0)
        postsViewModel.move(from: index, to: moveIndex)
        XCTAssertEqual(postsViewModel.post(at: moveIndex), posts[0])
    }
    
    func testPostsViewModel_deletePostAtIndex() throws {
        let deleteIndex = IndexPath(row: 0, section: 0)
        var post = postsViewModel.deletePost(at: deleteIndex)
        XCTAssertEqual(post, posts[0])
        XCTAssertEqual(postsViewModel.numberOfRows, 4)
        // Delete favorite post
        let _ = postsViewModel.toggleFavoriteElement(at: deleteIndex)
        post = postsViewModel.deletePost(at: deleteIndex)
        XCTAssertEqual(post, posts[1])
        XCTAssertEqual(postsViewModel.numberOfRows, 3)
    }
    
    func testPostsViewModel_deleteUnfavoritePosts() throws {
        // All favorite posts
        for index in 0..<posts.count {
            let _ = postsViewModel.toggleFavoriteElement(at: IndexPath(row: index, section: 0))
        }
        var deletedPosts = postsViewModel.deleteUnfavoritePosts()
        XCTAssertEqual(deletedPosts, [])
        XCTAssertEqual(postsViewModel.numberOfRows, posts.count)
        // Couple favorite posts
        let _ = postsViewModel.toggleFavoriteElement(at: IndexPath(row: 4, section: 0))
        let _ = postsViewModel.toggleFavoriteElement(at: IndexPath(row: 3, section: 0))
        deletedPosts = postsViewModel.deleteUnfavoritePosts()
        XCTAssertEqual(deletedPosts, [posts[3], posts[4]])
        XCTAssertEqual(postsViewModel.numberOfRows, 3)
        // All unfavorite posts
        for index in 0..<3 {
            let _ = postsViewModel.toggleFavoriteElement(at: IndexPath(row: index, section: 0))
        }
        deletedPosts = postsViewModel.deleteUnfavoritePosts()
        XCTAssertEqual(deletedPosts, [posts[0], posts[1], posts[2]])
        XCTAssertEqual(postsViewModel.numberOfRows, 0)
    }
}
