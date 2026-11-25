import Foundation

/// ANSI styling for CLI output.
///
/// Styles chain, e.g. `TerminalStyle.bold.red.on("text")`. Each style is closed with its own
/// reset code (not a full reset), so styled text can be nested inside other styled text.
///
/// Styling is disabled when stdout is not a terminal, when `TERM` is `dumb`, or when `NO_COLOR`
/// is set (https://no-color.org).
struct TerminalStyle: Sendable {

    private struct Code: Sendable {
        let open: String
        let close: String
    }

    private let codes: [Code]

    // MARK: - Entry points

    static var bold: TerminalStyle { TerminalStyle(codes: []).bold }
    static var underline: TerminalStyle { TerminalStyle(codes: []).underline }
    static var red: TerminalStyle { TerminalStyle(codes: []).red }
    static var yellow: TerminalStyle { TerminalStyle(codes: []).yellow }
    static var gray: TerminalStyle { TerminalStyle(codes: []).gray }
    static var greenBright: TerminalStyle { TerminalStyle(codes: []).greenBright }
    static var whiteBright: TerminalStyle { TerminalStyle(codes: []).whiteBright }

    // MARK: - Modifiers

    var bold: TerminalStyle { adding("1", close: "22") }
    var underline: TerminalStyle { adding("4", close: "24") }

    // MARK: - Foreground colors

    var red: TerminalStyle { adding("31", close: "39") }
    var yellow: TerminalStyle { adding("33", close: "39") }
    var gray: TerminalStyle { adding("90", close: "39") }
    var greenBright: TerminalStyle { adding("92", close: "39") }
    var whiteBright: TerminalStyle { adding("97", close: "39") }

    // MARK: - Background colors

    /// Background color given as `0xRRGGBB`. Uses 24-bit color when the terminal advertises it
    /// (`COLORTERM`), otherwise the given 256-color palette index.
    func background(hex: UInt32, fallback256 index: UInt8) -> TerminalStyle {
        let open = Self.supportsTrueColor
            ? "48;2;\((hex >> 16) & 0xFF);\((hex >> 8) & 0xFF);\(hex & 0xFF)"
            : "48;5;\(index)"
        return adding(open, close: "49")
    }

    // MARK: - Applying

    /// Returns `text` wrapped in this style's escape codes, or `text` unchanged when styling is disabled.
    func on(_ text: String) -> String {
        guard Self.isEnabled, !codes.isEmpty else { return text }
        let open = codes.map { "\u{001B}[\($0.open)m" }.joined()
        let close = codes.reversed().map { "\u{001B}[\($0.close)m" }.joined()
        return open + text + close
    }

    // MARK: - Private

    private func adding(_ open: String, close: String) -> TerminalStyle {
        TerminalStyle(codes: codes + [Code(open: open, close: close)])
    }

    private static let isEnabled: Bool = {
        let environment = ProcessInfo.processInfo.environment
        if let noColor = environment["NO_COLOR"], !noColor.isEmpty { return false }
        if environment["TERM"] == "dumb" { return false }
        return isatty(STDOUT_FILENO) != 0
    }()

    private static let supportsTrueColor: Bool = {
        let colorTerm = ProcessInfo.processInfo.environment["COLORTERM"]?.lowercased()
        return colorTerm == "truecolor" || colorTerm == "24bit"
    }()
}
