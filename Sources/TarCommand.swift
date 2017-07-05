// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class TarCommand: Command {

    let name = "tar"
    let shortDescription = "Extracts TAR container"

    let noMtime = Flag("--no-restore-mtime", usage: "Don't restore modification time of files and directories.")

    let archive = Parameter()
    let outputPath = Parameter()

    static func process(tarContainer data: Data, _ outputPath: String, _ writeMtime: Bool, _ verbose: Bool) throws {
        let fileManager = FileManager.default

        let outputURL = URL(fileURLWithPath: outputPath)

        if try !isValidOutputDirectory(outputPath, create: true) {
            print("ERROR: Specified path already exists and is not a directory.")
            exit(1)
        }

        let entries = try TarContainer.open(container: data)

        var directoryAttributes = [(attributes: [FileAttributeKey: Any],
                                    path: String,
                                    log: String)]()

        for entry in entries {
            let attributes = entry.entryAttributes
            guard let type = attributes[FileAttributeKey.type] as? FileAttributeType else {
                print("ERROR: Not a FileAttributeType type. This error should never happen.")
                exit(1)
            }

            let isDirectory = type == FileAttributeType.typeDirectory || entry.isDirectory

            let entryPath = entry.name
            let entryFullURL = outputURL.appendingPathComponent(entryPath, isDirectory: isDirectory)

            if isDirectory {
                if verbose {
                    print("directory: \(entryPath)")
                }
                try fileManager.createDirectory(at: entryFullURL, withIntermediateDirectories: true)
            } else if type == FileAttributeType.typeRegular {
                if verbose {
                    print("file: \(entryPath)")
                }
                let entryData = try entry.data()
                try entryData.write(to: entryFullURL)
            } else if type == FileAttributeType.typeSymbolicLink {
                // Data of entry is a relative path from the directory in which entry is located to destination.
                if verbose {
                    print("symbolic link: \(entryPath)", terminator: "")
                }
                // For tar entries there is a special property `linkPath` for destination of link.
                guard let destinationPath = (entry as! TarEntry).linkPath else {
                    print("ERROR: Unable to get destination path for symbolic link \(entryPath).")
                    exit(1)
                }
                let endURL = entryFullURL.deletingLastPathComponent().appendingPathComponent(destinationPath)
                if verbose {
                    print(" destination: \(endURL.path)")
                }
                try fileManager.createSymbolicLink(atPath: entryFullURL.path, withDestinationPath: endURL.path)
                // We cannot apply attributes to symbolic link.
                continue
            } else {
                print("WARNING: Unknown file type \(type) for entry \(entryPath). Skipping this entry.")
            }

            var attributesLog = "\tattributes:"

            var attributesToWrite = [FileAttributeKey: Any]()

            #if !os(Linux) // On linux only permissions attribute is supported.
            if writeMtime, let mtime = attributes[FileAttributeKey.modificationDate] {
                attributesLog += " mtime: \(mtime)"
                attributesToWrite[FileAttributeKey.modificationDate] = mtime
            }
            #endif

            if let permissions = attributes[FileAttributeKey.posixPermissions] as? Int {
                attributesLog += " permissions: \(permissions)"
                attributesToWrite[FileAttributeKey.posixPermissions] = NSNumber(value: permissions)
            }

            if !isDirectory {
                try fileManager.setAttributes(attributesToWrite, ofItemAtPath: entryFullURL.path)
                if verbose {
                    print(attributesLog)
                }
            } else {
                directoryAttributes.append((attributesToWrite, entryFullURL.path, attributesLog))
            }
        }

        for tuple in directoryAttributes {
            try fileManager.setAttributes(tuple.attributes, ofItemAtPath: tuple.path)
            if verbose {
                print("set for dir: \(tuple.path) ", terminator: "")
                print(tuple.log)
            }
        }
    }

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                        options: .mappedIfSafe)

        let outputPath = self.outputPath.value
        try TarCommand.process(tarContainer: fileData, outputPath, !noMtime.value, verbose.value)
    }

}
