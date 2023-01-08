//
//  BaseTableViewController.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 08.01.2023.
//

import UIKit
import os.log

class BaseTableViewController: UIViewController {
    // Log object to identify place of call
    internal var log: OSLog!

    // MARK: - UI elements
    internal lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = delegate()
        tableView.dataSource = dataSource()
        cellIdentifiers().forEach {
            tableView.register($0.value, forCellReuseIdentifier: $0.key)
        }
        tableView.translatesAutoresizingMaskIntoConstraints = true
        return tableView
    }()

    internal lazy var loadingIndicator: UIActivityIndicatorView = {
        var loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .gray
        loadingIndicator.isHidden = true
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        return loadingIndicator
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: loggerCategory())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupNavigationBar()
    }

    internal func setupUI() {
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

    internal func setupNavigationBar() {
        navigationItem.title = "Posts"
    }
    
    // MARK: - Overridable functions
    internal func loggerCategory() -> String {
        "BaseTableViewController"
    }

    internal func delegate() -> UITableViewDelegate? {
        nil
    }

    internal func dataSource() -> UITableViewDataSource? {
        nil
    }

    internal func cellIdentifiers() -> [String: UITableViewCell.Type] {
        [:]
    }
}
