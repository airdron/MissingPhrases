//
//  FileSelectionModuleAssemble.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import Foundation

class FileSelectionModuleAssemble {

    static func make() -> FileSelectionViewController {
        let service = AnimationFileReaderService()
        let modelController = FileSelectionModelController(fileService: service)
        let viewController = FileSelectionViewController(modelController: modelController)
        return viewController
    }
}
