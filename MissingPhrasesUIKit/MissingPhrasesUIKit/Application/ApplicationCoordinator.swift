//
//  ApplicationCoordinator.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import UIKit

class ApplicationCoordinator {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showFileSelection(source: window)
    }

    func showFileSelection(source window: UIWindow) {
        let viewController = FileSelectionModuleAssemble.make()
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
    }
}
