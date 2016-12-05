import SWCompression
import Foundation

do {
  let archType = CommandLine.arguments[1]
  let fileData = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[2]))
  let outputPath = CommandLine.arguments[3]
  let decompressedData: Data
  switch archType {
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
