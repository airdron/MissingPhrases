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
    private var rectangleViews: [UIView] = []
    private var circleViews: [UIView] = []
    private var contentView = UIView()

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
        setupConstraints()
    }

    private func setupUI() {
        title = modelController.file.fullFileName
        rectangleViews = modelController.file.rectangles.map { rectangle in
            let view = UIView()
            view.backgroundColor = rectangle.color.uiColor
            return view
        }
        circleViews = modelController.file.circles.map { circle in
            let view = UIView()
            view.backgroundColor = circle.color.uiColor
            return view
        }
        view.addSubview(contentView)
        rectangleViews.forEach(contentView.addSubview)
        circleViews.forEach(contentView.addSubview)

        view.backgroundColor = .systemIndigo
    }

    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func initialLayout() {
        zip(rectangleViews, modelController.file.rectangles).forEach { rectangleView, rectangle in
            rectangleView.transform = .identity
            let originX: CGFloat = (rectangle.centerX - rectangle.width / 2)
            let originY: CGFloat = (rectangle.centerY - rectangle.height / 2)
            let angle: CGFloat = rectangle.angle * CGFloat.pi / 180
            rectangleView.frame.origin.x = originX
            rectangleView.frame.origin.y = originY
            rectangleView.frame.size.width = rectangle.width
            rectangleView.frame.size.height = rectangle.height
            rectangleView.transform = CGAffineTransform.identity.rotated(by: angle)
        }

        zip(circleViews, modelController.file.circles).forEach { circleView, circle in
            let width = 2 * circle.radius
            let height = 2 * circle.radius
            let originX: CGFloat = (circle.centerX - circle.radius)
            let originY: CGFloat = (circle.centerY - circle.radius)
            circleView.layer.masksToBounds = true
            circleView.frame.origin.x = originX
            circleView.frame.origin.y = originY
            circleView.frame.size.width = width
            circleView.frame.size.height = height
            circleView.layer.cornerRadius = circle.radius
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rectangleViews.forEach { $0.layer.removeAllAnimations() }
        initialLayout()
        DispatchQueue.main.async {
            self.startAnimations()
        }
    }

    private func startAnimations() {
        zip(rectangleViews, modelController.file.rectangles).forEach { rectangleView, rectangle in
            rectangle.animations.moves.enumerated().forEach { index, move in
                let time = move.time / 1000
                let originX: CGFloat = rectangle.centerX
                let originY: CGFloat = rectangle.centerY
                let fromValue = CGPoint(x: originX, y: originY)
                let destX = move.destX
                let destY = move.destY
                let toValue = CGPoint(x: destX,
                                      y: destY)
                let animationPosition = CABasicAnimation(keyPath: "position")
                animationPosition.fromValue = NSValue(cgPoint: fromValue)
                animationPosition.toValue = NSValue(cgPoint: toValue)
                animationPosition.duration = time
                animationPosition.autoreverses = move.isCycle
                animationPosition.fillMode = .forwards
                animationPosition.isRemovedOnCompletion = false
                rectangleView.layer.add(animationPosition, forKey: "rectangle p\(index)")
                rectangleView.frame.origin = CGPoint(x: move.destX - rectangle.width / 2,
                                                     y: move.destY - rectangle.height / 2)
            }

            rectangle.animations.rotates.enumerated().forEach { index, rotate in
                let time = rotate.time / 1000
                rectangleView.transform = .identity
                rectangle.animations.rotates.forEach { rotate in
                    let originAngle: CGFloat = rectangle.angle * CGFloat.pi / 180
                    let angle: CGFloat = rotate.angle * CGFloat.pi / 180
                    let animationRotate = CABasicAnimation(keyPath: "transform.rotation")
                    animationRotate.fromValue = 0
                    animationRotate.toValue = angle + originAngle
                    animationRotate.duration = time
                    animationRotate.isAdditive = true
                    animationRotate.autoreverses = rotate.isCycle
                    animationRotate.fillMode = .forwards
                    animationRotate.isRemovedOnCompletion = false
                    rectangleView.layer.add(animationRotate, forKey: "rectangle r\(index)")
                }
            }
        }
    }
}
