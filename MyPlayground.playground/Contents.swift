//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class FigureFile {
    var canvasWidth: CGFloat = 0
    var canvasHeight: CGFloat = 0
    var figuresCount: Int = 0
    var figures: [Animatable] = []
}

enum Color: String {
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

enum Figure: String {
    case rectangle
    case circle
}

enum Animation: String {
    case move
    case rotate
    case scale
}

enum AnimationValue {
    case move(destX: CGFloat, destY: CGFloat, time: TimeInterval, isCycle: Bool)
    case rotate(angle: CGFloat, time: TimeInterval, isCycle: Bool)
    case scale(destScale: CGFloat, time: TimeInterval, isCycle: Bool)
}

protocol Animatable {
    
    func add(in canvas: UIView)
    func start(in canvas: UIView)
}

class Rectangle: Animatable {

    var centerX: CGFloat = 0
    var centerY: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    var angle: CGFloat = 0
    var color: UIColor = .black
    var animations: [AnimationValue] = []
    var view = UIView()

    func add(in canvas: UIView) {
        view.center = CGPoint(x: centerX, y: centerY)
        view.frame.size = CGSize(width: width, height: height)
        view.backgroundColor = color
        canvas.addSubview(view)
    }
    
    func start(in canvas: UIView) {
        
        print(animations)
        var transform = CGAffineTransform.identity

        animations.forEach { animation in
            switch animation {
            case .move(let x, let y, let time, let isCycle):
                transform = transform.translatedBy(x: x - self.centerX, y: y - self.centerY)
                
            case .rotate(let angle, let time, let isCycle):
                    transform = transform.rotated(by: angle / 180)
         
               
            case .scale(let destScale, let time, let isCycle):
              
                    transform.scaledBy(x: destScale, y: destScale)
                                     

              
            }
            
            UIView.animate(withDuration: 3, delay: 0.0, options: [.curveEaseIn, .repeat], animations: {
                self.view.transform = transform
            }, completion: nil)
        }
    }
}

class Circle: Animatable {
    var centerX: CGFloat = 0
    var centerY: CGFloat = 0
    var radius: CGFloat = 0
    var color: UIColor = .black
    var animations: [AnimationValue] = []
    var view = UIView()
    func add(in canvas: UIView) {
        let width: CGFloat = 2 * radius
        let height: CGFloat = 2 * radius
        view.center = CGPoint(x: centerX, y: centerY)
        view.frame.size = CGSize(width: width, height: height)
        view.backgroundColor = color
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        canvas.addSubview(view)
    }
    
    func start(in canvas: UIView) {
        animations.forEach { animation in
            switch animation {
            case .move(let x, let y, let time, let isCycle):
                UIView.animate(withDuration: time / 1000, delay: 0.0, options: isCycle ? [.autoreverse, .curveEaseIn] : [.curveEaseIn], animations: {
                    self.view.frame.origin = CGPoint(x: x, y: y)

                }, completion: nil)
            case .rotate(let angle, let time, let isCycle):
                UIView.animate(withDuration: time / 1000, delay: 0.0, options: isCycle ? [.autoreverse, .curveEaseIn] : [.curveEaseIn], animations: {
                    self.view.transform = CGAffineTransform.identity.rotated(by: angle / 180 * CGFloat.pi)
                }, completion: nil)
               
            case .scale(let destScale, let time, let isCycle):
                UIView.animate(withDuration: time / 1000, delay: 0.0, options: isCycle ? [.autoreverse, .curveEaseIn] : [.curveEaseIn], animations: {
                    self.view.transform = CGAffineTransform.identity.scaledBy(x: destScale, y: destScale)

                }, completion: nil)
            }
        }
    }
}

func readFiles() -> [String] {
    (0...10).map { index in
        let fileURL = Bundle.main.url(forResource: "\(index)", withExtension: "txt")
        let content = try! String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
        return content
    }
}

func makeFigure(figureString: String, animationStrings: [String]) -> Animatable {
    let splittedStrings = figureString.split(separator: " ").map(String.init)
    
    let animations: [AnimationValue] = animationStrings.map { string in
        let splittedAnimationStrings = string.split(separator: " ").map(String.init)
        switch Animation(rawValue: splittedAnimationStrings[0])! {
        case .move:
            return .move(destX: CGFloat(Double(splittedAnimationStrings[1])!),
                         destY: CGFloat(Double(splittedAnimationStrings[2])!),
                         time: Double(splittedAnimationStrings[3])!,
                         isCycle: splittedAnimationStrings.last == "cycle")
        case .rotate:
            return .rotate(angle: CGFloat(Double(splittedAnimationStrings[1])!),
                           time: Double(splittedAnimationStrings[2])!,
                           isCycle: splittedAnimationStrings.last == "cycle")
        case .scale:
            return .scale(destScale: CGFloat(Double(splittedAnimationStrings[1])!),
                          time: Double(splittedAnimationStrings[2])!,
                          isCycle: splittedAnimationStrings.last == "cycle")
        }
    }
    
    switch Figure.init(rawValue: splittedStrings[0]) {
    case .rectangle?:
        let rectangle = Rectangle()
        rectangle.centerX = CGFloat(Double(splittedStrings[1])!)
        rectangle.centerY = CGFloat(Double(splittedStrings[2])!)
        rectangle.width = CGFloat(Double(splittedStrings[3])!)
        rectangle.height = CGFloat(Double(splittedStrings[4])!)
        rectangle.angle = CGFloat(Double(splittedStrings[5])!)
        rectangle.color = Color.init(rawValue: splittedStrings[6])!.uiColor
        rectangle.animations = animations
        return rectangle
    case .circle?:
        let circle = Circle()
        circle.centerX = CGFloat(Double(splittedStrings[1])!)
        circle.centerY = CGFloat(Double(splittedStrings[2])!)
        circle.radius = CGFloat(Double(splittedStrings[3])!)
        circle.color = Color.init(rawValue: splittedStrings[4])!.uiColor
        circle.animations = animations
        return circle
    case .none:
        fatalError()
    }
}

func parseFileString(_ string: String) -> FigureFile {
    let file = FigureFile()
    let splitedString = string.split(separator: "\n")
    var index: Int = 0
    let canvasString = splitedString[index]
    let canvasSplitedStrings = canvasString.split(separator: " ")
    file.canvasWidth = CGFloat(Double(canvasSplitedStrings[0])!)
    file.canvasHeight = CGFloat(Double(canvasSplitedStrings[1])!)
    index += 1
    file.figuresCount = Int(String(splitedString[index]))!
    index += 1
    while index < splitedString.count {
        var animationStrings: [String] = []
        let figureString = String(splitedString[index])
        index += 1
        let figureCount = Int(String(splitedString[index]))!
        (0..<figureCount).forEach { _ in
            index += 1
            animationStrings.append(String(splitedString[index]))
        }
        file.figures.append(makeFigure(figureString: figureString,
                                       animationStrings: animationStrings))
        index += 1
    }
    return file
}

let files = readFiles().map { string -> FigureFile in
    return parseFileString(string)
}

let canvas = UIView(frame: CGRect(x: 0, y: 0, width: files[6].canvasWidth, height: files[6].canvasHeight))
canvas.backgroundColor = .green

files[6].figures.forEach { $0.add(in: canvas) }

files[6].figures.forEach { $0.start(in: canvas) }


//let canvas = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//canvas.backgroundColor = .green

//let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
//view.backgroundColor = .red
//canvas.addSubview(view)
//UIView.animate(withDuration: 0.3) {
//    view.frame.origin.x = 50
//}
////
//let views = (0..<10).map { index -> UIView in
//    let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 20 , height: 20))
//    view.backgroundColor = .red
//    canvas.addSubview(view)
//    return view
//}
//views.enumerated().forEach { (arg) in
//
//    let (index, view) = arg
//    UIView.animate(withDuration: 2) {
////        view.frame.origin = CGPoint(x: 10 + 10 * index, y: 10)
//        view.transform = CGAffineTransform.identity.rotated(by:  CGFloat.pi).translatedBy(x: 10 + 10 * CGFloat(index), y: 10)
//    }

//    UIView.animate(withDuration: 2) {
//        view.frame.origin = CGPoint(x: 10 + 10 * index, y: 10)
//        view.transform = CGAffineTransform().scaledBy(x: 2, y: 2)
//    }
//}

PlaygroundPage.current.liveView = canvas

