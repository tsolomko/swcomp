import Foundation
import SWCompression
import SwiftCLI

struct GlobalOptions: GlobalOptionsSource {
    static let verbose = Flag("--verbose", usage: "Print the list of extracted files and directories.")
    static var options: [Option] {
        return [verbose]
    }
}

extension ZipCommand {
    var verbose: Flag {
        return GlobalOptions.verbose
    }
}

extension TarCommand {
    var verbose: Flag {
        return GlobalOptions.verbose
    }
}

extension TgzCommand {
    var verbose: Flag {
        return GlobalOptions.verbose
    }
}

extension TxzCommand {
    var verbose: Flag {
        return GlobalOptions.verbose
    }
}

extension Tbz2Command {
    var verbose: Flag {
        return GlobalOptions.verbose
    }
}
