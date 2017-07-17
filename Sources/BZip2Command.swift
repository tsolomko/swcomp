// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class BZip2Command: Command {

    let name = "bz2"
    let shortDescription = "Extracts BZip2 archive"

    let archive = Parameter()
    let outputPath = OptionalParameter()

    func execute() throws {
        let inputURL = URL(fileURLWithPath: self.archive.value)
        let fileData = try Data(contentsOf: inputURL, options: .mappedIfSafe)
        let outputPath = self.outputPath.value ?? inputURL.deletingLastPathComponent().path
        let decompressedData = try BZip2.decompress(data: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}
