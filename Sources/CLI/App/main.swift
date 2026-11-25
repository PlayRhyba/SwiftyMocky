import Foundation
import ArgumentParser
import PathKit
import SwiftyMockyCLICore

// MARK: - Root command

struct SwiftyMockyCommand: ParsableCommand {
    static let configuration: CommandConfiguration = {
        var subcommands: [any ParsableCommand.Type] = [Init.self, Generate.self, Watch.self]
        #if os(macOS)
        subcommands += [Setup.self, Migrate.self, Autoimport.self, Doctor.self]
        #endif
        #if DEBUG
        subcommands += [Assetize.self]
        #endif
        return CommandConfiguration(
            commandName: "swiftymocky",
            abstract: "Generates mocks for Swift protocols using Sourcery.",
            version: Application().version,
            subcommands: subcommands
        )
    }()
}

// MARK: - Shared options

struct GenerationOptions: ParsableArguments {
    @Flag(name: [.customLong("verbose"), .customShort("v")], help: ArgumentHelp(Messages.Generate.verbose))
    var verbose = false

    @Flag(name: .customLong("disableCache"), help: ArgumentHelp(Messages.Generate.disableCache))
    var disableCache = false
}

// MARK: - Commands

extension SwiftyMockyCommand {

    struct Init: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "init",
            abstract: Messages.Setup.initDescription
        )

        func run() {
            Application().initialize()
        }
    }

    struct Generate: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Generate.description)

        @OptionGroup var options: GenerationOptions

        @Flag(name: [.customLong("watch"), .customShort("w")], help: ArgumentHelp(Messages.Generate.watcher))
        var watch = false

        @Argument(help: "Name of the mock to generate (as in the Mockfile). Generates all mocks if omitted.")
        var mockName: String?

        func validate() throws {
            if watch && mockName == nil {
                throw ValidationError("--watch requires a mock name.")
            }
        }

        func run() {
            let application = Application()
            if let mockName {
                application.generate(
                    mock: mockName,
                    disableCache: options.disableCache,
                    verbose: options.verbose,
                    watch: watch
                )
            } else {
                application.generate(disableCache: options.disableCache, verbose: options.verbose)
            }
        }
    }

    struct Watch: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Generate.watcher)

        @OptionGroup var options: GenerationOptions

        @Argument(help: "Name of the mock to watch (as in the Mockfile).")
        var mockName: String

        func run() {
            Application().generate(
                mock: mockName,
                disableCache: options.disableCache,
                verbose: options.verbose,
                watch: true
            )
        }
    }

    #if os(macOS)
    struct Setup: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Setup.description)

        @Argument(help: "Path to the .xcodeproj, if there is more than one in the directory.")
        var project: String?

        func run() {
            Application().setup(project: project)
        }
    }

    struct Migrate: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Migrate.description)

        @Argument(help: "Path to the .xcodeproj, if there is more than one in the directory.")
        var project: String?

        func run() {
            Application().migrate(project: project)
        }
    }

    struct Autoimport: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Autoimport.description)

        @Argument(help: "Name of the mock (as in the Mockfile). Updates all mocks if omitted.")
        var mockName: String?

        func run() {
            Application().autoimport(forMock: mockName)
        }
    }

    struct Doctor: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Doctor.description)

        @Argument(help: "Path to the .xcodeproj, if there is more than one in the directory.")
        var project: String?

        func run() {
            Application().doctor(project: project)
        }
    }
    #endif

    #if DEBUG
    struct Assetize: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: Messages.Tools.assetizeDescription)

        func run() throws {
            let application = Application()
            let pwd = Path(ProcessInfo.processInfo.environment["PWD"] ?? "")

            // Assetize from current template, but check version first. CLI version should match SM version
            let templateFile = pwd + "Sources/SwiftyMocky/Mock.swifttemplate"
            let templateContent: String = try templateFile.read()
            if !templateContent.contains("// Generated with SwiftyMocky \(application.version)") {
                Message.warning("CLI version \(application.version)")
            }

            application.assetizeTemplates(
                mockTemplate: pwd + "Sources/SwiftyMocky/Mock.swifttemplate",
                prototypeTemplate: pwd + "Sources/SwiftyPrototype/Prototype.swifttemplate",
                allTypesTemplate: pwd + "Templates/AllTypes.swifttemplate",
                template: pwd + "Templates/Assets.template",
                output: pwd + "Sources/CLI/Core/Assets/Assets.swift"
            )
        }
    }
    #endif
}

// MARK: - Entry point

Message.swiftyMockyLabel("SwiftyMocky CLI v\(Application().version)")
SwiftyMockyCommand.main()
