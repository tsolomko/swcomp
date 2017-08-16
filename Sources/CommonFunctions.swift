// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation
import SWCompression

func isValidOutputDirectory(_ outputPath: String, create: Bool) throws -> Bool {
    let fileManager = FileManager.default
    var isDir: ObjCBool = false

    if fileManager.fileExists(atPath: outputPath, isDirectory: &isDir) {
        #if os(Linux) // On linux ObjCBool is an alias for Bool.
            return isDir
        #else
            return isDir.boolValue
        #endif
    } else if create {
        try fileManager.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
    }
    return true
}

func printInfo(_ entries: [ContainerEntry]) {
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

func write(_ entries: [ContainerEntry], _ outputPath: String, _ verbose: Bool) throws {
    let fileManager = FileManager.default
    let outputURL = URL(fileURLWithPath: outputPath)
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
