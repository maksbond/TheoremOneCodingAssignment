//
//  PostDetailTableViewController.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

import UIKit
import os.log

class PostDetailTableViewController: BaseTableViewController {
    // Network Manager
    private var networkManager: NetworkManager!

    // Data source for post details
    private var postDetailsDataSource: PostDetailsDataSource!

    // MARK: - Initializers
    
    init(
        networkManager: NetworkManager,
        post: Post
    ) {
        super.init()
        self.networkManager = networkManager
        postDetailsDataSource = PostDetailsDataSource(networkManager: networkManager, post: post)
        postDetailsDataSource.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lify-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postDetailsDataSource.fetchPostDetails()
    }
    
    override func setupNavigationBar() {
        navigationItem.title = "Details"
    }
    
    deinit {
        postDetailsDataSource = nil
        networkManager = nil
    }
    
    // MARK: - Overrided methods
    override func loggerCategory() -> String {
        "PostDetailTableViewController"
    }

    override func delegate() -> UITableViewDelegate? {
        postDetailsDataSource
    }

    override func dataSource() -> UITableViewDataSource? {
        postDetailsDataSource
    }
    
    override func cellIdentifiers() -> [String : UITableViewCell.Type] {
        postDetailsDataSource.cellIdentifiers
    }

    override func setupUI() {
        super.setupUI()
        tableView.allowsSelection = false
    }
}

// MARK: - PostsDataSourceDelegate methods implementation

@MainActor
extension PostDetailTableViewController: PostDetailsDataSourceDelegate {
    func presentAlert(with title: String, message: String) {
        os_log(.error, log: log, "\n++++++\nPresent alert with title:\n%{public}@\nMessage:\n%{public}@\n++++++\n", title, message)
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
