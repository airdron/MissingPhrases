//
//  FileSelectionModelController.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import Foundation
import MissingPhrasesCommon

class FileSelectionModelController {

    private let fileService: AnimationFileReaderService

    init(fileService: AnimationFileReaderService) {
        self.fileService = fileService
    }

    func loadFiles(completion: ((Result<[FigureFile], Error>) -> Void)?) {
        fileService.fetchFiles(completion: completion)
    }
}
