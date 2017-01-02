import SWCompression
import Foundation

/* TODO: Switch to usage of Bundle.allBundles() function of Foundation framework when it becomes implemented.*/
// Version constants:
let SWCompressionVersion = "2.0.1"
let swcompRevision = "24"

func printHelp() {
    print("Unimplemented.")
    exit(1)
}

func printVersion() {
    print("SWCompression version used: \(SWCompressionVersion)")
    print("swcomp revision: \(swcompRevision)")
    exit(0)
}

if CommandLine.arguments.count < 2 {
    print("No arguments were passed. See --help or -h for more information")
    exit(1)
}

if CommandLine.arguments.count == 2 {
    switch CommandLine.arguments[1] {
    case "-h": fallthrough
    case "--help": printHelp()
    case "--version": printVersion()
    case "xz": fallthrough
    case "lzma": fallthrough
    case "bzip2": fallthrough
    case "gzip":
        print("Not enough arguments were passed. See --help or -h for more information")
        exit(1)

    default:
        print("Unknown option or argument was passed.")
        exit(1)
    }
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
