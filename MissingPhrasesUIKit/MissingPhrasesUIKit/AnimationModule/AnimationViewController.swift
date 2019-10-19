//
//  AnimationViewController.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 19.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {

    private let modelController: AnimationModelController

    init(modelController: AnimationModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
    }
}
