// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class TgzCommand: Command {

    let name = "tgz"
    let shortDescription = "Extracts TAR container compressed with GZip"

    let noMtime = Flag("--no-restore-mtime", usage: "Don't restore modification time of files and directories.")

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let containerData = try GzipArchive.unarchive(archive: fileData)
        try TarCommand.process(tarContainer: containerData, outputPath.value, !noMtime.value, verbose.value)
    }

}
