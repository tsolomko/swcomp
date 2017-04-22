import Foundation
import SWCompression
import SwiftCLI

/* TODO: Switch to usage of Bundle.allBundles() function of Foundation framework when it becomes implemented.*/
// Version constants:
let SWCompressionVersion = "2.3.0"
let swcompRevision = "30"

class XZCommand: Command {

    let name = "xz"
    let shortDescription = "Extracts XZ archive"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
      let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                              options: .mappedIfSafe)
      let outputPath = self.outputPath.value
      let decompressedData = try XZArchive.unarchive(archiveData: fileData)
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
      let decompressedData = try LZMA.decompress(compressedData: fileData)
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
      let decompressedData = try BZip2.decompress(compressedData: fileData)
      try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}

class GZipCommand: Command {

    let name = "gz"
    let shortDescription = "Extracts GZip archive"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
      let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                              options: .mappedIfSafe)
      let outputPath = self.outputPath.value
      let decompressedData = try GzipArchive.unarchive(archiveData: fileData)
      try decompressedData.write(to: URL(fileURLWithPath: outputPath))
    }

}

class ZipCommand: Command {

    let name = "zip"
    let shortDescription = "Extracts ZIP archive"

    let archive = Parameter()
    let outputPath = Parameter()

    func execute() throws {
      let fileData = try Data(contentsOf: URL(fileURLWithPath: self.archive.value),
                              options: .mappedIfSafe)
      let outputPath = self.outputPath.value
      let zipList = try ZipContainer.open(containerData: fileData)
      for entry in zipList {
          let entryData = entry.entryData
          let entryName = entry.entryName
          if entryData.count == 0 && entryName.characters.last! == "/"  {
              let directoryURL = URL(fileURLWithPath: outputPath)
                  .appendingPathComponent(entryName, isDirectory: true)
              print("directory: \(directoryURL.path)")
              try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
          } else {
              let fileURL = URL(fileURLWithPath: outputPath)
                  .appendingPathComponent(entryName, isDirectory: false)
              print("file: \(fileURL.path)")
              try entryData.write(to: fileURL)
          }
      }
    }

}

CLI.setup(name: "swcomp", version: swcompRevision, description: "swcomp - small command-line client for SWCompression framework.")
CLI.register(commands: [XZCommand(), LZMACommand(), BZip2Command(), GZipCommand(), ZipCommand()])
_ = CLI.go()
