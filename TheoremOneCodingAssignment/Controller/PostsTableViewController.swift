//
//  ViewController.swift
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
}

// MARK: - PostsDataSourceDelegate methods implementation

@MainActor
extension PostsTableViewController: PostsDataSourceDelegate {
    func presentAlert(with title: String, message: String) {
        os_log(.error, log: log, "\n++++++\nPresent error with title:\n%{public}@\nMessage:\n%{public}@\n++++++\n", title, message)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
}
