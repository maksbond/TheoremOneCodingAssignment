//
//  ViewController.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

import UIKit
import os.log

class PostsTableViewController: UIViewController {
    // Network Manager
    private var networkManager: NetworkManager!
    
    // Log object to identify place of call
    private var log: OSLog!

    // Data source for posts
    private var postsDataSource: PostsDataSource!

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self.postsDataSource
        tableView.dataSource = self.postsDataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PostsDataSource.cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = true
        return tableView
    }()

    lazy var loadingIndicator: UIActivityIndicatorView = {
        var loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .gray
        loadingIndicator.isHidden = true
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        return loadingIndicator
    }()
    
    init(networkManager: NetworkManager) {
        super.init(nibName: nil, bundle: nil)
        self.networkManager = networkManager
        self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "PostsTableViewController")
        postsDataSource = PostsDataSource(networkManager: networkManager)
        postsDataSource.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupNavigationBar()
        postsDataSource.fetchPosts()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        // Add constraints
        NSLayoutConstraint.activate([
            // table view
            view.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            view.rightAnchor.constraint(equalTo: tableView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            view.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = "Posts"
    }
    
    deinit {
        postsDataSource = nil
        networkManager = nil
    }
}

@MainActor
extension PostsTableViewController: PostsDataSourceDelegate {
    func presentAlert(with title: String, message: String) {
        os_log(.error, log: log, "\n++++++\nPresent error with title:\n%{public}@\nMessage:\n%{public}@\n++++++\n", title, message)
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
