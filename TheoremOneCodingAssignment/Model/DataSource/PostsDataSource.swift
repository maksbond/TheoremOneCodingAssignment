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
    func presentDetails(for post: Post)
    var tableViewElement: UITableView { get }
}

class PostsDataSource: NSObject {
    // Instance of network Manager
    private let networkManager: NetworkManager!

    // Posts view model
    private var postsViewModel: PostsViewModel?
    
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
    public func fetchPosts() {
        Task(priority: .userInitiated) {
            do {
                await self.delegate?.showLoadingIndicator()
                async let fetchedPosts = self.networkManager.fetchPosts()
                self.postsViewModel = try await PostsViewModel(posts: fetchedPosts)
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

extension PostsDataSource: UIGestureRecognizerDelegate {
    @MainActor @objc
    func didTapListContentView(_ recognizer: UIGestureRecognizer) {
        guard let cell = recognizer.view?.superview as? UITableViewCell,
              let tableView = delegate?.tableViewElement,
              let postIndex = postsViewModel?.postIndex(with: cell.tag),
              let moveIndex = postsViewModel?.toggleFavoriteElement(at: postIndex)
        else {
            return
        }
        tableView.reloadRows(at: [postIndex], with: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            tableView.moveRow(at: postIndex, to: moveIndex)
            self.postsViewModel?.move(from: postIndex, to: moveIndex)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let listView = touch.view as? UIListContentView,
              let imageFrame = listView.imageLayoutGuide?.layoutFrame else {
            return false
        }
        let touchPoint = touch.location(in: touch.view)
        return imageFrame.contains(touchPoint)
    }
}

extension PostsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let post = postsViewModel?.post(at: indexPath) else {
            return
        }
        self.delegate?.presentDetails(for: post)
    }
}

extension PostsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsViewModel?.numberOfRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = postsViewModel?.viewModel(at: indexPath) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: PostsDataSource.cellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.postTitle
        content.image = UIImage(systemName: viewModel.favoriteIcon)
        content.imageProperties.tintColor = viewModel.tintColor
        cell.contentConfiguration = content
        if let listContentView = cell.contentView as? UIListContentView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapListContentView))
            tapGesture.delegate = self
            listContentView.addGestureRecognizer(tapGesture)
        }
        cell.tag = viewModel.tag
        return cell
    }
}
