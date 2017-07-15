// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class Tbz2Command: Command {

    let name = "tbz2"
    let shortDescription = "Extracts TAR container compressed with BZip2"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let containerData = try BZip2.decompress(data: fileData)
        try TarCommand.process(tarContainer: containerData, outputPath.value, verbose.value)
    }

}
