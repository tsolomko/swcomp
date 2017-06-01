# swcomp
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/tsolomko/SWCompression/master/LICENSE)

A small command-line tool which decompresses and unarchives several types of archives.
Its main purpose is to serve as an example of capabilities of [SWCompression](https://github.com/tsolomko/SWCompression).

__Works on Linux.__

Compiling
----------
First, clone this repository:

`
git clone https://github.com/tsolomko/swcomp.git
`

Then build it with:

`
swift build -c release
`

The `-c release` part is very important.
It tells [Swift Package Manager](https://github.com/apple/swift-package-manager/) to build everything with 'Release' configuration.
And this significantly improves performance.

Usage
------
`swcomp <command> <path_to_archive_or_container> <path_to_output>`

All arguments are required.

To list all available commands, run:
`swcomp help`

It is recommended to specify full absolute paths, especially on Linux,
because it seems like there are some problems with path resolving in Swift.
