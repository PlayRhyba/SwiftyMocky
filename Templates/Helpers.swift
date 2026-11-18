class Helpers {
    /// Sourcery normalizes `(any P)?` to `any P?` (also `!`, and inside closure types).
    /// Compilers before Swift 6.4 reject `any P?`, so restore the parenthesized form
    /// for every optional existential in the generated code.
    static func parenthesizeOptionalExistentials(_ code: String) -> String {
        let identifier = #"[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*(?:<[^<>]*>)?"#
        let pattern = #"\bany ("# + identifier + #"(?: ?& ?"# + identifier + #")*)([?!])"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return code }
        let range = NSRange(code.startIndex..<code.endIndex, in: code)
        return regex.stringByReplacingMatches(in: code, range: range, withTemplate: "(any $1)$2")
    }
    static func split(_ string: String, byFirstOccurenceOf word: String) -> (String, String) {
        guard let wordRange = string.range(of: word) else { return (string, "") }
        let selfRange = string.range(of: string)!
        let before = String(string[selfRange.lowerBound..<wordRange.lowerBound])
        let after = String(string[wordRange.upperBound..<selfRange.upperBound])
        return (before, after)
    }
    static func extractAssociatedTypes(from annotated: SourceryRuntime.Annotated) -> [String]? {
        if let types = annotated.annotations["associatedtype"] as? [String] {
            return types.reversed()
        } else if let type = annotated.annotations["associatedtype"] as? String {
            return [type]
        } else {
            return nil
        }
    }
    static func extractWhereClause(from annotated: SourceryRuntime.Annotated) -> String? {
        if let constraints = annotated.annotations["where"] as? [String] {
            return " where \(constraints.reversed().joined(separator: ", "))"
        } else if let constraint = annotated.annotations["where"] as? String {
            return " where \(constraint)"
        } else {
            return nil
        }
    }
    /// Extract all typealiases from "annotations"
    static func extractTypealiases(from annotated: SourceryRuntime.Annotated) -> [String] {
        if let types = annotated.annotations["typealias"] as? [String] {
            return types.reversed()
        } else if let type = annotated.annotations["typealias"] as? String {
            return [type]
        } else {
            return []
        }
    }
    static func extractGenericsList(_ associatedTypes: [String]?) -> [String] {
        return associatedTypes?.flatMap {
            split($0, byFirstOccurenceOf: " where ").0.replacingOccurrences(of: " ", with: "").split(separator: ":").map(String.init).first
        }.map { "\($0)" } ?? []
    }
    static func extractGenericTypesModifier(_ associatedTypes: [String]?) -> String {
        let all = extractGenericsList(associatedTypes)
        guard !all.isEmpty else { return "" }
        return "<\(all.joined(separator: ","))>"
    }
    static func extractGenericTypesConstraints(_ associatedTypes: [String]?) -> String {
        guard let all = associatedTypes else { return "" }
        let constraints = all.flatMap { t -> String? in
            let splitted = split(t, byFirstOccurenceOf: " where ")
            let constraint = splitted.0.replacingOccurrences(of: " ", with: "").split(separator: ":").map(String.init)
            guard constraint.count == 2 else { return nil }
            let adopts = constraint[1].split(separator: ",").map(String.init)
            var mapped = adopts.map { "\(constraint[0]): \($0)" }
            if !splitted.1.isEmpty {
                mapped.append(splitted.1)
            }
            return mapped.joined(separator: ", ")
            }
            .joined(separator: ", ")
        guard !constraints.isEmpty else { return "" }
        return " where \(constraints)"
    }
    static func extractAttributes(
        from attributes: [String: [SourceryRuntime.Attribute]],
        filterOutStartingWith disallowedPrefixes: [String] = []
    ) -> String {
        return attributes
        .reduce([SourceryRuntime.Attribute]()) { $0 + $1.1 }
        .map { $0.description }
        .filter { !["private", "internal", "public", "open", "optional"].contains($0) }
        .filter { element in
            !disallowedPrefixes.contains(where: element.hasPrefix)
        }
        .sorted()
        .joined(separator: " ")
    }
}
