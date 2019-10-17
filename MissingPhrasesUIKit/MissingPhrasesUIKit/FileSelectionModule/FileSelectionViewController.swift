//
//  FileSelectionViewController.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import UIKit

class FileSelectionViewController: UIViewController {

    private let modelController: FileSelectionModelController
    private lazy var tableView = UITableView()
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    private var files: [FigureFile] = []
    private let cellType = UITableViewCell.self
    private lazy var cellIdentifier = String(describing: cellType)

    init(modelController: FileSelectionModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        setupUI()
        activityIndicator.startAnimating()
        modelController.loadFiles { [weak self] result in
            self?.activityIndicator.stopAnimating()
            switch result {
            case .success(let files):
                self?.files = files
            case .failure(let error):
                print(error)
            }
            self?.tableView.reloadData()
        }
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        let cellType = UITableViewCell.self
        tableView.register(cellType, forCellReuseIdentifier: cellIdentifier)
        activityIndicator.hidesWhenStopped = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension FileSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = files[indexPath.row].fullFileName
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
}

extension FileSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
