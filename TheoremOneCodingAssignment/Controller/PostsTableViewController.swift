//
//  PostsTableViewController.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

import UIKit
import os.log

class PostsTableViewController: BaseTableViewController {
    // Network Manager
    private var networkManager: NetworkManager!

    // Data source for posts
    private var postsDataSource: PostsDataSource!

    // MARK: - Initializers
    
    init(networkManager: NetworkManager) {
        super.init()
        self.networkManager = networkManager
        postsDataSource = PostsDataSource(networkManager: networkManager)
        postsDataSource.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lify-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsDataSource.fetchPosts()
    }
    
    override func setupNavigationBar() {
        navigationItem.title = "Posts"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteUnfavorite))
    }
    
    deinit {
        postsDataSource = nil
        networkManager = nil
    }
    
    // MARK: - Overrided methods
    override func loggerCategory() -> String {
        "PostsTableViewController"
    }

    override func delegate() -> UITableViewDelegate? {
        postsDataSource
    }

    override func dataSource() -> UITableViewDataSource? {
        postsDataSource
    }
    
    override func cellIdentifiers() -> [String : UITableViewCell.Type] {
        [PostsDataSource.cellIdentifier: UITableViewCell.self]
    }
    
    // MARK: - Bar button actions
    
    @objc
    func deleteUnfavorite() {
        presentAlert(with: "Delete all unfavorite posts", message: "You will delete all unfavorite posts") { [weak self] in
            self?.postsDataSource.deleteAllUnfavorite()
        }
    }
}

// MARK: - PostsDataSourceDelegate methods implementation

@MainActor
extension PostsTableViewController: PostsDataSourceDelegate {
    func presentAlert(with title: String, message: String, completion: (() -> Void)?) {
        os_log(.error, log: log, "\n++++++\nPresent alert with title:\n%{public}@\nMessage:\n%{public}@\n++++++\n", title, message)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        })
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showLoadingIndicator() {
        os_log(.info, log: log, "\n++++++\nShow loading indicator\n++++++\n")
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    
    func hideLoadingIndicator() {
        os_log(.info, log: log, "\n++++++\nHide loading indicator\n++++++\n")
        loadingIndicator.stopAnimating()
    }
    
    func updatePresentedContent() {
        os_log(.info, log: log, "\n++++++\nReload table view\n++++++\n")
        tableView.reloadData()
    }
    
    func presentDetails(for post: Post) {
        let postDetailsViewController = PostDetailTableViewController(
            networkManager: networkManager,
            post: post
        )
        self.navigationController?.pushViewController(postDetailsViewController, animated: true)
    }

    var tableViewElement: UITableView {
        tableView
    }
}
