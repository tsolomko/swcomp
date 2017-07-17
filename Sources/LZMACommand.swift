// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class LZMACommand: Command {

    let name = "lzma"
    let shortDescription = "Extracts LZMA archive"

    let archive = Parameter()
    let outputPath = OptionalParameter()

    func execute() throws {
        let inputURL = URL(fileURLWithPath: self.archive.value)
        let fileData = try Data(contentsOf: inputURL, options: .mappedIfSafe)
        let outputPath = self.outputPath.value ?? inputURL.deletingLastPathComponent().path
        let decompressedData = try LZMA.decompress(data: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}
