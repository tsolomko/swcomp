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
        let outputPath = self.outputPath.value
        let entries = try TarContainer.open(container: containerData)
        for entry in entries {
            let entryName = entry.name
            if entry.isDirectory {
                let directoryURL = URL(fileURLWithPath: outputPath)
                    .appendingPathComponent(entryName, isDirectory: true)
                if verbose.value {
                    print("directory: \(directoryURL.path)")
                }
                try FileManager.default.createDirectory(at: directoryURL,
                                                        withIntermediateDirectories: true)
            } else {
                let entryData = try entry.data()
                let fileURL = URL(fileURLWithPath: outputPath)
                    .appendingPathComponent(entryName, isDirectory: false)
                if verbose.value {
                    print("file: \(fileURL.path)")
                }
                try entryData.write(to: fileURL)
            }
        }
    }

}
