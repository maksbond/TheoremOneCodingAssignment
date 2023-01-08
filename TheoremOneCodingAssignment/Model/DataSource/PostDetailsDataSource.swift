//
//  PostsDataSource.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 08.01.2023.
//

import UIKit
import Foundation

@MainActor
protocol PostDetailsDataSourceDelegate: AnyObject {
    func presentAlert(with title: String, message: String)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updatePresentedContent()
}

class PostDetailsDataSource: NSObject {
    // Instance of network Manager
    private let networkManager: NetworkManager!

    // Post used for presenting
    private var postDetailViewModel: PostDetailViewModel!
    
    // Delegate used to interact with controller
    public weak var delegate: PostDetailsDataSourceDelegate?

    // default init method
    init(
        networkManager: NetworkManager,
        post: Post
    ) {
        self.networkManager = networkManager
        self.postDetailViewModel = PostDetailViewModel(post: post)
        super.init()
    }
    
    /// Fetch post details from API and call delegates methods in progress
    public func fetchPostDetails() {
        Task(priority: .userInitiated) {
            do {
                await self.delegate?.showLoadingIndicator()
                async let user = self.networkManager.fetchUser(for: self.postDetailViewModel.post)
                async let comments = self.networkManager.fetchComments(for: self.postDetailViewModel.post)
                try await self.postDetailViewModel.update(user: user, comments: comments)
                await self.delegate?.hideLoadingIndicator()
                await self.delegate?.updatePresentedContent()
            } catch {
                let title: String
                let message: String
                if let error = error as? NetworkManager.NetworkManagerError {
                    title = "Network Manager"
                    message = error.description
                } else {
                    title = "Unknown"
                    message = error.localizedDescription
                }
                await self.delegate?.hideLoadingIndicator()
                await self.delegate?.updatePresentedContent()
                await self.delegate?.presentAlert(with: title, message: message)
            }
        }
    }
    
    var cellIdentifiers: [String: UITableViewCell.Type] {
        var identifiers = [String: UITableViewCell.Type]()
        PostDetailViewModel.ViewModel.allCases.forEach {
            identifiers[$0.identifier] = UITableViewCell.self
        }
        return identifiers
    }
}

extension PostDetailsDataSource: UITableViewDelegate {}

extension PostDetailsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        postDetailViewModel.sectionTitle(for: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return postDetailViewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDetailViewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = postDetailViewModel.viewModel(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.identifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        switch viewModel {
        case .post(let title, let description):
            content.text = title
            content.secondaryText = description
        case .author(let name, let email):
            content.text = name
            content.secondaryText = email
        case .comment(let authorName, let description):
            content.text = authorName
            content.secondaryText = description
        case .none:
            break
        }
        cell.contentConfiguration = content
        return cell
    }
}
