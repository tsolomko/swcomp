import Foundation
import SWCompression
import SwiftCLI

/* TODO: Switch to usage of Bundle.allBundles() function of Foundation framework when it becomes implemented.*/
// Version constants:
let SWCompressionVersion = "3.0.1"
let swcompRevision = "45"

CLI.setup(name: "swcomp",
          version: "\(swcompRevision), SWCompression version: \(SWCompressionVersion)",
          description: "swcomp - small command-line client for SWCompression framework.")
SwiftCLI.GlobalOptions.source(GlobalOptions.self)
CLI.register(commands: [XZCommand(),
                        LZMACommand(),
                        BZip2Command(),
                        GZipCommand(),
                        CompressGZipCommand(),
                        ZipCommand(),
                        TarCommand(),
                        TgzCommand(),
                        TxzCommand(),
                        Tbz2Command()])
_ = CLI.go()
