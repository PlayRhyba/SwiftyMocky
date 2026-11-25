import Foundation

/// Runs shell commands (Sourcery, Mint) for the CLI.
///
/// Commands go through `/bin/bash -c`, because the Sourcery command comes from the Mockfile as
/// shell text (e.g. `mint run krzysztofzablocki/Sourcery@2.4.1 sourcery`) and arguments are
/// already quoted for the shell.
enum Shell {

    /// A command finished with a non-zero exit status.
    struct Failure: Error, CustomStringConvertible {
        let command: String
        let exitCode: Int32
        /// Captured standard error. Empty for `run`, which prints straight to the terminal.
        let errorOutput: String

        var description: String {
            var lines = ["Command failed with exit code \(exitCode): \(command)"]
            if !errorOutput.isEmpty {
                lines.append(errorOutput)
            }
            return lines.joined(separator: "\n")
        }
    }

    /// Runs a command with its output going straight to the terminal.
    ///
    /// - Parameters:
    ///   - command: Shell command
    ///   - arguments: Arguments appended to the command (already shell-quoted)
    ///   - directory: Working directory, defaults to the current one
    /// - Throws: `Shell.Failure` if the command exits with a non-zero status
    static func run(_ command: String, arguments: [String] = [], at directory: String? = nil) throws {
        _ = try execute(command, arguments: arguments, at: directory, capturingOutput: false)
    }

    /// Runs a command and returns its standard output, trimmed of surrounding whitespace.
    ///
    /// - Parameters:
    ///   - command: Shell command
    ///   - arguments: Arguments appended to the command (already shell-quoted)
    ///   - directory: Working directory, defaults to the current one
    /// - Returns: Standard output
    /// - Throws: `Shell.Failure` if the command exits with a non-zero status
    @discardableResult
    static func capture(_ command: String, arguments: [String] = [], at directory: String? = nil) throws -> String {
        try execute(command, arguments: arguments, at: directory, capturingOutput: true)
    }

    // MARK: - Private

    private final class Buffer: @unchecked Sendable {
        var data = Data()
    }

    private static func execute(
        _ command: String,
        arguments: [String],
        at directory: String?,
        capturingOutput: Bool
    ) throws -> String {
        let commandLine = ([command] + arguments).joined(separator: " ")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", commandLine]
        if let directory {
            process.currentDirectoryURL = URL(fileURLWithPath: directory)
        }

        guard capturingOutput else {
            try process.run()
            process.waitUntilExit()
            try check(process, commandLine, errorOutput: "")
            return ""
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()

        // Drain stderr on another thread, so a full stderr pipe can't block the process
        // while stdout is being read.
        let errorBuffer = Buffer()
        let errorHandle = errorPipe.fileHandleForReading
        let group = DispatchGroup()
        DispatchQueue.global().async(group: group) {
            errorBuffer.data = errorHandle.readDataToEndOfFile()
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        group.wait()
        process.waitUntilExit()

        try check(process, commandLine, errorOutput: string(from: errorBuffer.data))
        return string(from: outputData)
    }

    private static func check(_ process: Process, _ commandLine: String, errorOutput: String) throws {
        guard process.terminationStatus != 0 else { return }
        throw Failure(command: commandLine, exitCode: process.terminationStatus, errorOutput: errorOutput)
    }

    private static func string(from data: Data) -> String {
        String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
