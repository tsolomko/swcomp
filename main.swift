import SWCompression
import Foundation

/* TODO: Add '--version' command-line option
when Bundle.allBundles() function of Foundation framework becomes implemented.*/
// Version constants:
let SWCompressionVersion = "2.0.0"
let swcompRevision = "14"
let swcompRevision = "15"

if CommandLine.arguments.count < 1 {
    print("Not enough arguments passed. See --help or -h for more information")
}

do {
    let archType = CommandLine.arguments[1]
    let fileData = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[2]),
                            options: .mappedIfSafe)
    let outputPath = CommandLine.arguments[3]
    let decompressedData: Data
    switch archType {
    case "lzma":
        decompressedData = try LZMA.decompress(compressedData: fileData)
    case "xz":
        decompressedData = try XZArchive.unarchive(archiveData: fileData)
    case "bzip2":
        decompressedData = try BZip2.decompress(compressedData: fileData)
    case "gzip":
        decompressedData = try GzipArchive.unarchive(archiveData: fileData)
    default:
        print("ERROR: unknown archive type.")
        exit(1)
    }
    try decompressedData.write(to: URL(fileURLWithPath: outputPath))
} catch let error {
    print("ERROR: \(error)")
    exit(1)
}
exit(0)
