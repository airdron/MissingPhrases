//
//  FigureModels.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import UIKit

public struct FigureFile {
    public let fullFileName: String
    public let canvasSize: CGSize
    public let rectangles: [Figure.Rectangle]
    public let circles: [Figure.Circle]
}

public struct Figure {
    public struct Rectangle {
        public let centerX: CGFloat
        public let centerY: CGFloat
        public let width: CGFloat
        public let height: CGFloat
        public let angle: CGFloat
        public let color: ColorType
        public let animations: Animations
    }

    public struct Circle {
        public let centerX: CGFloat
        public let centerY: CGFloat
        public let radius: CGFloat
        public let color: ColorType
        public let animations: Animations
    }

    public struct Animations {
        public struct Move {
            public let destX: CGFloat
            public let destY: CGFloat
            public let time: TimeInterval
            public let isCycle: Bool
        }

        public struct Rotate {
            public let angle: CGFloat
            public let time: TimeInterval
            public let isCycle: Bool
        }

        public struct Scale {
            public let destScale: CGFloat
            public let time: TimeInterval
            public let isCycle: Bool
        }

        public var moves: [Move] = []
        public var rotates: [Rotate] = []
        public var scales: [Scale] = []
    }
}

public enum ColorType: String {
    case black
    case yellow
    case red
    case white

    public var uiColor: UIColor {
        switch self {
        case .black:
            return .black
        case .yellow:
            return .systemYellow
        case .red:
            return .systemRed
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
