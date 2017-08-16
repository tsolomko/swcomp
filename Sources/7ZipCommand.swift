// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression
import SwiftCLI

class SevenZipCommand: Command {

    let name = "7z"
    let shortDescription = "Extracts 7-Zip container"

    let info = Flag("-i", "--info", usage: "Print list of entries in container and their attributes")
    let extract = Key<String>("-e", "--extract", usage: "Extract container into specified directory (it must be empty or not exist)")

    var optionGroups: [OptionGroup] {
        let actions = OptionGroup(options: [info, extract], restriction: .exactlyOne)
        return [actions]
    }

    let archive = Parameter()

    static func printInfo(sevenZipContainer data: Data) throws {
        let entries = try SevenZipContainer.open(container: data)

        print("d = directory, f = file, l = symbolic link")

        for entry in entries {
            let attributes = entry.entryAttributes
            guard let type = attributes[FileAttributeKey.type] as? FileAttributeType else {
                print("ERROR: Not a FileAttributeType type. This error should never happen.")
                exit(1)
            }

            let isDirectory = type == FileAttributeType.typeDirectory || entry.isDirectory
            let entryPath = entry.name

            if isDirectory {
                print("d: \(entryPath)")
            } else if entry.isLink {
                guard let destinationPath = entry.linkPath else {
                    print("ERROR: Unable to get destination path for symbolic link \(entryPath).")
                    exit(1)
                }
                print("l: \(entryPath) -> \(destinationPath)")
            } else if type == FileAttributeType.typeRegular {
                print("f: \(entryPath)")
            } else {
                print("WARNING: Unknown file type \(type) for entry \(entryPath). Skipping this entry.")
                continue
            }

            var attributesLog = " attributes:"

            if let mtime = attributes[FileAttributeKey.modificationDate] {
                attributesLog += " mtime: \(mtime)"
            }

            if let ctime = attributes[FileAttributeKey.creationDate] {
                attributesLog += " ctime: \(ctime)"
            }

            if attributes[FileAttributeKey.appendOnly] as? Bool == true {
                attributesLog += " read-only"
            }

            if let permissions = attributes[FileAttributeKey.posixPermissions] as? UInt32 {
                attributesLog += String(format: " permissions: %o", permissions)
            }
            
            print(attributesLog)
        }
    }

    static func process(sevenZipContainer data: Data, _ outputPath: String, _ verbose: Bool) throws {
        let fileManager = FileManager.default

        let outputURL = URL(fileURLWithPath: outputPath)

        if try !isValidOutputDirectory(outputPath, create: true) {
            print("ERROR: Specified path already exists and is not a directory.")
            exit(1)
        }

        let entries = try SevenZipContainer.open(container: data)

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
            } else if entry.isLink {
                guard let destinationPath = entry.linkPath else {
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
            } else if type == FileAttributeType.typeRegular {
                if verbose {
                    print("f: \(entryPath)")
                }
                let entryData = try entry.data()
                try entryData.write(to: entryFullURL)
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

                if let readOnly = attributes[FileAttributeKey.appendOnly] as? Bool {
                    attributesLog += readOnly ? " read-only" : ""
                    attributesToWrite[FileAttributeKey.appendOnly] = NSNumber(value: readOnly)
                }
            #endif

            if let permissions = attributes[FileAttributeKey.posixPermissions] as? UInt32 {
                attributesLog += String(format: " permissions: %o", permissions)
                attributesToWrite[FileAttributeKey.posixPermissions] = NSNumber(value: permissions)
            }

            if !isDirectory {
                try fileManager.setAttributes(attributesToWrite, ofItemAtPath: entryFullURL.path)
                if verbose {
                    print(attributesLog)
                }
            } else {
                // We apply attributes to directories later,
                //  because extracting files into them changes mtime.
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
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        if info.value {
            try SevenZipCommand.printInfo(sevenZipContainer: fileData)
        } else {
            let outputPath = self.extract.value ?? FileManager.default.currentDirectoryPath
            try SevenZipCommand.process(sevenZipContainer: fileData, outputPath, verbose.value)
        }
    }
}
