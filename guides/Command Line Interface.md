# Command Line Interface

**SwiftyMocky CLI** is a custom command line tool, writtten in swift, that will simplify setting up mock configuration, validating and troubleshooting configuration and simplify mocks generation.

CLI is hosted at: [https://github.com/PlayRhyba/SwiftyMocky](https://github.com/PlayRhyba/SwiftyMocky)

## Installation:

Please refer to [Guides/Installation.md](./Installation.md#installation-cli)

## Usage:

```bash
// From cloned repo main dir
$ swift run swiftymocky <command>

// Using mint
$ mint run PlayRhyba/SwiftyMocky <command>
```

## Commands:

+ `init` - Creates template of Mockfile to fill
+ `generate [<mock-name>]` - generate mocks (all of them, or the one named). Flags:
    + `--disableCache`: disables using cache
    + `--verbose`, `-v`: additional sourcery debug info
    + `--watch`, `-w`: run in watcher mode, requires a mock name
+ `watch <mock-name>` - run in watcher mode (accepts `--disableCache` and `--verbose`)
+ `setup [<project>.xcodeproj]` - creates a Mockfile; pass a project path if there is more than one xcodeproj in the directory
+ `migrate [<project>.xcodeproj]` - migrate existing SwiftyMocky yml configurations into Mockfile™
+ `autoimport [<mock-name>]` - scans sources and automatically resolves imports for the mocks
+ `doctor [<project>.xcodeproj]` - run to inspect status of SwiftyMocky setup

Every command accepts `--help` (`-h`), and `swiftymocky --version` prints the CLI version. `swiftymocky help <command>` shows detailed help for a command.
