// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class XZCommand: Command {

    let name = "xz"
    let shortDescription = "Extracts XZ archive"

    let archive = Parameter()
    let outputPath = OptionalParameter()

    func execute() throws {
        let inputURL = URL(fileURLWithPath: self.archive.value)
        let fileData = try Data(contentsOf: inputURL, options: .mappedIfSafe)
        let outputPath = self.outputPath.value ?? inputURL.deletingLastPathComponent().path
        let decompressedData = try XZArchive.unarchive(archive: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}
