//
//  AnimationViewController.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 19.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {

    private var animationsRunning = true
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
        setupGesture()
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

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
    }

    @objc
    private func tapHandler() {
        animationsRunning.toggle()

        if animationsRunning {
            resumeAnimations(layer: view.layer)
        } else {
            pauseAnimations(layer: view.layer)
        }
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
        circleViews.forEach { $0.layer.removeAllAnimations() }
        initialLayout()
        DispatchQueue.main.async {
            self.startAnimations()
        }
    }

    private func startAnimations() {
        startAnimationRectangles(views: rectangleViews, models: modelController.file.rectangles)
        startAnimationCircles(views: circleViews, models: modelController.file.circles)
    }

    func startAnimationRectangles(views: [UIView], models: [Figure.Rectangle]) {
        zip(views, models).forEach { rectangleView, rectangle in
            self.startAnimation(view: rectangleView,
                                animations: rectangle.animations,
                                center: CGPoint(x: rectangle.centerX,
                                                y: rectangle.centerY))
        }
    }

    func startAnimationCircles(views: [UIView], models: [Figure.Circle]) {
        zip(views, models).forEach { circleView, circle in
            self.startAnimation(view: circleView,
                                animations: circle.animations,
                                center: CGPoint(x: circle.centerX,
                                                y: circle.centerY))
        }
    }

    private func startAnimation(view: UIView,
                                animations: Figure.Animations,
                                center: CGPoint,
                                animationSpeed: TimeInterval = 500) {
        animations.moves.enumerated().forEach { index, move in
            let time = move.time / animationSpeed
            let originX: CGFloat = center.x
            let originY: CGFloat = center.y
            let destX = move.destX
            let destY = move.destY
            let animationPosition = CABasicAnimation(keyPath: "transform.translation")
            animationPosition.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
            animationPosition.toValue = NSValue(cgPoint: CGPoint(x: destX - originX, y: destY - originY))
            animationPosition.duration = time
            animationPosition.autoreverses = move.isCycle
            animationPosition.fillMode = .forwards
            animationPosition.isRemovedOnCompletion = false
            animationPosition.isAdditive = true
            view.layer.add(animationPosition, forKey: "rectangle translate\(index)")
        }

        animations.rotates.enumerated().forEach { index, rotate in
            let time = rotate.time / animationSpeed
            let angle: CGFloat = rotate.angle * CGFloat.pi / 180
            let animationRotate = CABasicAnimation(keyPath: "transform.rotation")
            animationRotate.fromValue = 0
            animationRotate.toValue = angle
            animationRotate.duration = time
            animationRotate.isAdditive = true
            animationRotate.autoreverses = rotate.isCycle
            animationRotate.fillMode = .forwards
            animationRotate.isRemovedOnCompletion = false

            view.layer.add(animationRotate, forKey: "rectangle rotate\(index)")
        }

        animations.scales.enumerated().forEach { index, scale in
            let time = scale.time / animationSpeed
            let animationScale = CABasicAnimation(keyPath: "transform.scale")
            animationScale.fromValue = 0
            animationScale.toValue = scale.destScale
            animationScale.duration = time
            animationScale.isAdditive = true
            animationScale.autoreverses = scale.isCycle
            animationScale.fillMode = .forwards
            animationScale.isRemovedOnCompletion = false

            view.layer.add(animationScale, forKey: "rectangle scale\(index)")
        }
    }

    func pauseAnimations(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
    }

    func resumeAnimations(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1
        layer.beginTime = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
