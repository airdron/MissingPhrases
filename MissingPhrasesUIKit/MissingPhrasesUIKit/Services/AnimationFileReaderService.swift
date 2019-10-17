//
//  AnimationFileReaderService.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 17.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import Foundation
import UIKit

class AnimationFileReaderService {

    func fetchFiles(fileNames: [String],
                    fileExtension: String,
                    completion: ((Result<[FigureFile], Error>) -> Void)?) {

        DispatchQueue.global().async {
            do {
                let files: [FigureFile] = try fileNames.map { fileName in
                    let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
                    let fileContent = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
                    return self.parseFile(fullFileName: fileName + "." + fileExtension, content: fileContent)
                }
                DispatchQueue.main.async {
                    completion?(.success(files))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }

    private func parseFile(fullFileName: String, content: String) -> FigureFile {
        let splitedString = content.split(separator: "\n")
        var index: Int = 0
        let canvasSize = makeCanvasSize(from: splitedString[index])
        index += 2
        var rectangles: [Figure.Rectangle] = []
        var circles: [Figure.Circle] = []

        while index < splitedString.count {
            var animationStrings: [String] = []
            let figureString = String(splitedString[index])
            let figureSplittedStrings = figureString.split(separator: " ")
            let type = figureType(from: figureSplittedStrings[0])
            index += 1
            let animationCount = Int(String(splitedString[index]))!
            (0..<animationCount).forEach { _ in
                index += 1
                animationStrings.append(String(splitedString[index]))
            }

            switch type {
            case .rectangle:
                rectangles.append(parseRectangleFigure(propertyStrings: figureSplittedStrings,
                                                       animationStrings: animationStrings))
            case .circle:
                circles.append(parseCircleFigure(propertyStrings: figureSplittedStrings,
                                                 animationStrings: animationStrings))
            }
            index += 1
        }
        return FigureFile(fullFileName: fullFileName, canvasSize: canvasSize, rectangles: rectangles, circles: circles)
    }

    private func parseCircleFigure(propertyStrings: [Substring], animationStrings: [String]) -> Figure.Circle {
        let circle = Figure.Circle(centerX: CGFloat(Double(propertyStrings[1])!),
                                   centerY: CGFloat(Double(propertyStrings[2])!),
                                   radius: CGFloat(Double(propertyStrings[3])!),
                                   color: ColorType(rawValue: String(propertyStrings[4]))!,
                                   animations: makeAnimations(animationStrings))
        return circle
    }

    private func parseRectangleFigure(propertyStrings: [Substring], animationStrings: [String]) -> Figure.Rectangle {

        let rectangle = Figure.Rectangle(centerX: CGFloat(Double(propertyStrings[1])!),
                                         centerY: CGFloat(Double(propertyStrings[2])!),
                                         width: CGFloat(Double(propertyStrings[3])!),
                                         height: CGFloat(Double(propertyStrings[4])!),
                                         angle: CGFloat(Double(propertyStrings[5])!),
                                         color: ColorType(rawValue: String(propertyStrings[6]))!,
                                         animations: makeAnimations(animationStrings))
        return rectangle
    }

    private func makeAnimations(_ animationStrings: [String]) -> Figure.Animations {
        var moves: [Figure.Animations.Move] = []
        var rotates: [Figure.Animations.Rotate] = []
        var scales: [Figure.Animations.Scale] = []

        animationStrings.forEach { string in
            let splittedAnimationStrings = string.split(separator: " ").map(String.init)
            switch AnimationType(rawValue: splittedAnimationStrings[0])! {
            case .move:
                guard let destX = Double(splittedAnimationStrings[1]),
                    let destY = Double(splittedAnimationStrings[2]),
                    let time = TimeInterval(splittedAnimationStrings[3]) else {
                        return
                }
                let isCycle = splittedAnimationStrings.last == "cycle"
                let move = Figure.Animations.Move(destX: CGFloat(destX),
                                                  destY: CGFloat(destY),
                                                  time: time,
                                                  isCycle: isCycle)
                moves.append(move)
            case .rotate:
                guard let angle = Double(splittedAnimationStrings[1]),
                    let time = TimeInterval(splittedAnimationStrings[2]) else {
                        return
                }
                let isCycle = splittedAnimationStrings.last == "cycle"
                let rotate = Figure.Animations.Rotate(angle: CGFloat(angle), time: time, isCycle: isCycle)
                rotates.append(rotate)
            case .scale:
                guard let destScale = Double(splittedAnimationStrings[1]),
                    let time = TimeInterval(splittedAnimationStrings[2]) else {
                        return
                }
                let isCycle = splittedAnimationStrings.last == "cycle"
                let scale = Figure.Animations.Scale(destScale: CGFloat(destScale), time: time, isCycle: isCycle)
                scales.append(scale)
            }
        }
        return Figure.Animations(moves: moves, rotates: rotates, scales: scales)
    }

    private func makeCanvasSize(from string: Substring) -> CGSize {
        let splitedStrings = string.split(separator: " ")
        guard let width = Double(splitedStrings[0]), let height = Double(splitedStrings[1]) else { return .zero }
        return CGSize(width: width, height: height)
    }

    private func figureType(from string: Substring) -> FigureType {
        return FigureType(rawValue: String(string)) ?? FigureType.rectangle
    }
}
