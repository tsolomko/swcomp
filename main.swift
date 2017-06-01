import Foundation
import SWCompression
import SwiftCLI

/* TODO: Switch to usage of Bundle.allBundles() function of Foundation framework when it becomes implemented.*/
// Version constants:
let SWCompressionVersion = "3.0.0"
let swcompRevision = "39"

class XZCommand: Command {

    let name = "xz"
    let shortDescription = "Extracts XZ archive"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let outputPath = self.outputPath.value
        let decompressedData = try XZArchive.unarchive(archive: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}

class LZMACommand: Command {

    let name = "lzma"
    let shortDescription = "Extracts LZMA archive"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let outputPath = self.outputPath.value
        let decompressedData = try LZMA.decompress(data: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}

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

class GZipCommand: Command {

    let name = "gz-d"
    let shortDescription = "Extracts GZip archive"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let outputPath = self.outputPath.value
        let decompressedData = try GzipArchive.unarchive(archive: fileData)
        try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}

class CompressGZipCommand: Command {

    let name = "gz-c"
    let shortDescription = "Creates GZip archive"

    let inputFile = Parameter()
    let outputArchive = Parameter()

    func execute() throws {
        let inputURL = URL(fileURLWithPath: self.inputFile.value)
        let outputURL = URL(fileURLWithPath: self.outputArchive.value)
        let fileData = try Data(contentsOf: inputURL, options: .mappedIfSafe)
        let fileName = inputURL.lastPathComponent
        let compressedData = try GzipArchive.archive(data: fileData,
                                                     fileName: fileName.isEmpty ? nil : fileName,
                                                     writeHeaderCRC: true)
        try compressedData.write(to: outputURL)
    }

}

class ZipCommand: Command {

    let name = "zip"
    let shortDescription = "Extracts ZIP container"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let outputPath = self.outputPath.value
        let zipList = try ZipContainer.open(container: fileData)
        for entry in zipList {
            let entryName = entry.name
            if entry.isDirectory {
                let directoryURL = URL(fileURLWithPath: outputPath)
                    .appendingPathComponent(entryName, isDirectory: true)
                print("directory: \(directoryURL.path)")
                try FileManager.default.createDirectory(at: directoryURL,
                                                        withIntermediateDirectories: true)
            } else {
                let entryData = try entry.data()
                let fileURL = URL(fileURLWithPath: outputPath)
                    .appendingPathComponent(entryName, isDirectory: false)
                print("file: \(fileURL.path)")
                try entryData.write(to: fileURL)
            }
        }
    }

}

class TarCommand: Command {

    let name = "tar"
    let shortDescription = "Extracts TAR container"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                                options: .mappedIfSafe)
        let outputPath = self.outputPath.value
        let entries = try TarContainer.open(container: fileData)
        for entry in entries {
            let entryName = entry.name
            if entry.isDirectory {
                let directoryURL = URL(fileURLWithPath: outputPath)
                    .appendingPathComponent(entryName, isDirectory: true)
                print("directory: \(directoryURL.path)")
                try FileManager.default.createDirectory(at: directoryURL,
                                                        withIntermediateDirectories: true)
            } else {
                let entryData = try entry.data()
                let fileURL = URL(fileURLWithPath: outputPath)
                    .appendingPathComponent(entryName, isDirectory: false)
                print("file: \(fileURL.path)")
                try entryData.write(to: fileURL)
            }
        }
    }

}

CLI.setup(name: "swcomp",
          version: "\(swcompRevision), SWCompression version: \(SWCompressionVersion)",
          description: "swcomp - small command-line client for SWCompression framework.")
CLI.register(commands: [XZCommand(),
                        LZMACommand(),
                        BZip2Command(),
                        GZipCommand(),
                        CompressGZipCommand(),
                        ZipCommand(),
                        TarCommand()])
_ = CLI.go()
