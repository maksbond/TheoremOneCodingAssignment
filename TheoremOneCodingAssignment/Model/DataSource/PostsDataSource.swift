//
//  PostsDataSource.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 08.01.2023.
//

import UIKit
import Foundation

@MainActor
protocol PostsDataSourceDelegate: AnyObject {
    func presentAlert(with title: String, message: String)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updatePresentedContent()
}

class PostsDataSource: NSObject {
    // Instance of network Manager
    private let networkManager: NetworkManager!

    // Post used for presenting
    private var posts = [Post]()
    
    // Delegate used to interact with controller
    public weak var delegate: PostsDataSourceDelegate?
    
    // Identifier for post cells
    static let cellIdentifier = "PostIdentifier"

    // default init method
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        super.init()
    }
    
    /// Fetch posts from API and call delegates methods in progress
    func fetchPosts() {
        Task(priority: .userInitiated) {
            do {
                await self.delegate?.showLoadingIndicator()
                let fetchedPosts = try await self.networkManager.fetchPosts()
                self.posts = fetchedPosts
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
}

extension PostsDataSource: UITableViewDelegate {
    
}

extension PostsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostsDataSource.cellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let row = posts[indexPath.row]
        content.text = row.title
        cell.contentConfiguration = content
        return cell
    }
}
