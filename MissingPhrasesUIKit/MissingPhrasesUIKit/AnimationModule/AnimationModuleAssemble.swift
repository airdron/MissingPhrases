//
//  AnimationModuleAssemble.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 19.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import Foundation
import MissingPhrasesCommon
class AnimationModuleAssemble {

    static func make(with file: FigureFile) -> AnimationViewController {
        let modelController = AnimationModelController(file: file)
        return AnimationViewController(modelController: modelController)
    }
}
