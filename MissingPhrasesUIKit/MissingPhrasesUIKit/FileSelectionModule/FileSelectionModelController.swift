//
//  FileSelectionModelController.swift
//  MissingPhrasesUIKit
//
//  Created by Andrew Oparin on 16.10.2019.
//  Copyright © 2019 Andrew Oparin. All rights reserved.
//

import Foundation

class FileSelectionModelController {

    private let fileNames = (0...10).map(String.init)
    private let fileExtension = "txt"

    private let fileService: AnimationFileReaderService

    init(fileService: AnimationFileReaderService) {
        self.fileService = fileService
    }

    func loadFiles(completion: ((Result<[FigureFile], Error>) -> Void)?) {
        fileService.fetchFiles(fileNames: fileNames, fileExtension: fileExtension, completion: completion)
    }
}
