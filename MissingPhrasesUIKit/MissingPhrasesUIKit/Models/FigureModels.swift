//
//  FigureModels.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import UIKit

struct FigureFile {
    let fullFileName: String
    let canvasSize: CGSize
    let rectangles: [Figure.Rectangle]
    let circles: [Figure.Circle]
}

struct Figure {
    struct Rectangle {
        let centerX: CGFloat
        let centerY: CGFloat
        let width: CGFloat
        let height: CGFloat
        let angle: CGFloat
        let color: ColorType
        let animations: Animations
    }

    struct Circle {
        let centerX: CGFloat
        let centerY: CGFloat
        let radius: CGFloat
        let color: ColorType
        let animations: Animations
    }

    struct Animations {

        struct Move {
            let destX: CGFloat
            let destY: CGFloat
            let time: TimeInterval
            let isCycle: Bool
        }

        struct Rotate {
            let angle: CGFloat
            let time: TimeInterval
            let isCycle: Bool
        }

        struct Scale {
            let destScale: CGFloat
            let time: TimeInterval
            let isCycle: Bool
        }

        var moves: [Move] = []
        var rotates: [Rotate] = []
        var scales: [Scale] = []
    }

}

enum ColorType: String {
    case black
    case yellow
    case red
    case white

    var uiColor: UIColor {
        switch self {
        case .black:
            return .black
        case .yellow:
            return .yellow
        case .red:
            return .red
        case .white:
            return .white
        }
    }
}

enum FigureType: String {
    case rectangle
    case circle
}

enum AnimationType: String {
    case move
    case rotate
    case scale
}
