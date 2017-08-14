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

    let gz = Flag("-z", "--gz", usage: "Decompress with GZip first")
    let bz2 = Flag("-j", "--bz2", usage: "Decompress with BZip2 first")
    let xz = Flag("-x", "--xz", usage: "Decompress with XZ first")

    var optionGroups: [OptionGroup] {
        let compressions = OptionGroup(options: [gz, bz2, xz], restriction: .atMostOne)
        return [compressions]
    }

    let archive = Parameter()
    let outputPath = OptionalParameter()

    static func process(tarContainer data: Data, _ outputPath: String, _ verbose: Bool) throws {
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

        if verbose {
            print("d = directory, f = file, l = symbolic link")
        }

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
                    print("d: \(entryPath)")
                }
                try fileManager.createDirectory(at: entryFullURL, withIntermediateDirectories: true)
            } else if type == FileAttributeType.typeRegular {
                if verbose {
                    print("f: \(entryPath)")
                }
                let entryData = try entry.data()
                try entryData.write(to: entryFullURL)
            } else if type == FileAttributeType.typeSymbolicLink {
                // Data of entry is a relative path from the directory in which entry is located to destination.
                // For tar entries there is a special property `linkPath` for destination of link.
                guard let destinationPath = (entry as! TarEntry).linkPath else {
                    print("ERROR: Unable to get destination path for symbolic link \(entryPath).")
                    exit(1)
                }
                let endURL = entryFullURL.deletingLastPathComponent().appendingPathComponent(destinationPath)
                if verbose {
                    print("l: \(entryPath) -> \(endURL.path)")
                }
                try fileManager.createSymbolicLink(atPath: entryFullURL.path, withDestinationPath: endURL.path)
                // We cannot apply attributes to symbolic link.
                continue
            } else {
                print("WARNING: Unknown file type \(type) for entry \(entryPath). Skipping this entry.")
                continue
            }

            var attributesLog = " attributes:"

            var attributesToWrite = [FileAttributeKey: Any]()

            #if !os(Linux) // On linux only permissions attribute is supported.
            if let mtime = attributes[FileAttributeKey.modificationDate] {
                attributesLog += " mtime: \(mtime)"
                attributesToWrite[FileAttributeKey.modificationDate] = mtime
            }

            if let ctime = attributes[FileAttributeKey.creationDate] {
                attributesLog += " ctime: \(ctime)"
                attributesToWrite[FileAttributeKey.creationDate] = ctime
            }
            #endif

            if let permissions = attributes[FileAttributeKey.posixPermissions] as? Int {
                attributesLog += String(format: " permissions: %o", permissions)
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
                print("set for dir: \(tuple.path)", terminator: "")
                print(tuple.log)
            }
        }
    }

    func execute() throws {
        var fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                        options: .mappedIfSafe)

        if gz.value {
            fileData = try GzipArchive.unarchive(archive: fileData)
        } else if bz2.value {
            fileData = try BZip2.decompress(data: fileData)
        } else if xz.value {
            fileData = try XZArchive.unarchive(archive: fileData)
        }

        let outputPath = self.outputPath.value ?? FileManager.default.currentDirectoryPath
        try TarCommand.process(tarContainer: fileData, outputPath, verbose.value)
    }

}
