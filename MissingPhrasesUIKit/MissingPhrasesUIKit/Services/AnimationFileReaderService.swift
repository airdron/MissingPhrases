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
                let files = try fileNames.map { fileName in
                    let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
                    let fileContent = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
                }
            } catch {
                completion?(.failure(error))
            }

        }
    }

    private func parseFile(content: String) -> FigureFile {
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
        return FigureFile(canvasSize: canvasSize, rectangles: rectangles, circles: circles)
    }

    private func parseRectangleFigure(propertyStrings: [Substring], animationStrings: [String]) -> Figure.Rectangle {
        fatalError()
    }

    private func parseCircleFigure(propertyStrings: [Substring], animationStrings: [String]) -> Figure.Circle {
        fatalError()
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
