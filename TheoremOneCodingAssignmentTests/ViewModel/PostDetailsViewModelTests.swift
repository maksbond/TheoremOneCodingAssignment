//
//  PostDetailsViewModel.swift
//  TheoremOneCodingAssignmentTests
//
//  Created by Maksym Bondar on 09.01.2023.
//

import XCTest
@testable import TheoremOneCodingAssignment

final class PostDetailsViewModelTests: XCTestCase {
    var post: Post!
    var user: User!
    var comments: [Comment]!
    var postDetailsViewModel: PostDetailViewModel!
    
    override func setUpWithError() throws {
        post = Post(userId: 1, id: 1, title: "1", body: "Text 1")
        user = User(id: 1, name: "user", username: "user1", email: "test@gmail.com", website: "google.com")
        comments = [
            Comment(postId: 1, id: 1, name: "User2", email: "test2@gmail.com", body: "comment1"),
            Comment(postId: 1, id: 2, name: "User3", email: "test3@gmail.com", body: "comment2"),
            Comment(postId: 1, id: 3, name: "User4", email: "test4@gmail.com", body: "comment3")
        ]
        postDetailsViewModel = PostDetailViewModel(post: post, user: user, comments: comments)
    }

    override func tearDownWithError() throws {
        post = nil
        user = nil
        comments = nil
    }

    func testPostDetailsViewModel_init() throws {
        XCTAssertEqual(post, postDetailsViewModel.post)
    }
    
    func testPostDetailsViewModel_init_withoutUserAndComments() throws {
        postDetailsViewModel = PostDetailViewModel(post: post)
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 1)), .author(name: "", email: ""))
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 2)), .comment(authorName: "", description: ""))
        XCTAssertEqual(postDetailsViewModel.numberOfRows(in: 2), 0)
    }

    func testPostDetailsViewModel_update() throws {
        let updateUser = User(id: 1, name: "diff", username: "diff1", email: "diff@gmail.com", website: "youtube.com")
        postDetailsViewModel.update(user: updateUser, comments: [comments[1], comments[2]])
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 1)), .author(name: "diff1", email: "diff@gmail.com"))
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 2)), .comment(authorName: "User3", description: "comment2"))
    }
    
    func testPostDetailsViewModel_numberOfSections() throws {
        XCTAssertEqual(postDetailsViewModel.numberOfSections, 3)
    }

    func testPostDetailsViewModel_numberOfRowsInSection() throws {
        XCTAssertEqual(postDetailsViewModel.numberOfRows(in: 0), 1)
        XCTAssertEqual(postDetailsViewModel.numberOfRows(in: 1), 1)
        XCTAssertEqual(postDetailsViewModel.numberOfRows(in: 2), comments.count)
        XCTAssertEqual(postDetailsViewModel.numberOfRows(in: 5), 0)
    }

    func testPostDetailsViewModel_SectionTitleForSection() throws {
        XCTAssertEqual(postDetailsViewModel.sectionTitle(for: 0), "Post")
        XCTAssertEqual(postDetailsViewModel.sectionTitle(for: 1), "Author")
        XCTAssertEqual(postDetailsViewModel.sectionTitle(for: 2), "Comments")
        XCTAssertEqual(postDetailsViewModel.sectionTitle(for: 5), "")
    }
    
    func testPostDetailsViewModel_ViewModelAtIndex() throws {
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 0)), .post(title: post.title, description: post.body))
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 1)), .author(name: user.username, email: user.email))
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 2)), .comment(authorName: comments[0].name, description: comments[0].body))
        XCTAssertEqual(postDetailsViewModel.viewModel(at: IndexPath(row: 0, section: 3)), .none)
    }
    
    func testPostDetailsViewModel_ViewModel_allCases_Identifiers() throws {
        var allCases = PostDetailViewModel.ViewModel.allCases
        XCTAssertEqual(allCases.count, 3)
        allCases.append(.none)
        let identifiers = allCases.compactMap { $0.identifier }
        let expectedIdentifiers = ["PostDetailCellIdentifier", "PostDetailAuthorCellIdentifier", "PostDetailCommentCellIdentifier", ""]
        for (index, identifier) in identifiers.enumerated() {
            XCTAssertEqual(expectedIdentifiers[index], identifier)
        }
    }
}
