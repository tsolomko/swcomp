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
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let outputPath = self.outputPath.value
        let decompressedData = try BZip2.decompress(data: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}
