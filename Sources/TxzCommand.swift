// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class TxzCommand: Command {

    let name = "txz"
    let shortDescription = "Extracts TAR container compressed with XZ"

    let noMtime = Flag("--no-restore-mtime", usage: "Don't restore modification time of files and directories.")

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let containerData = try XZArchive.unarchive(archive: fileData)
        try TarCommand.process(tarContainer: containerData, outputPath.value, !noMtime.value, verbose.value)
    }

}
