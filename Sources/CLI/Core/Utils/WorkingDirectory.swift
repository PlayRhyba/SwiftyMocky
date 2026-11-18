import Foundation
import PathKit
import Yams

// MARK: - Temporary directory

class WorkingDirectory {

    let identifier = UUID().uuidString
    var path: Path { return root + Path(".mocky\(identifier)") }
    var template: Path { return root + Path(".mocky\(identifier)/.template.swifttemplate") }
    var config: Path { return root + Path(".mocky\(identifier)/.config.yml.tmp") }

    private let root: Path

    // MARK: - Lifecycle

    init(root: Path) {
        self.root = root
    }

    // MARK: - Actions

    func createDirIfNeeded() throws {
        guard !path.exists else { return }
        try path.mkdir()
    }

    func create(config: LegacyConfiguration, output: String? = nil) throws {
        // Sourcery 2.x matches excluded files against the enumerated (canonical, absolute) paths of
        // included files, using case-sensitive comparison. Relative paths like `../Dir/File.swift`, or
        // paths whose letter case differs from the one on disk, would never match - so pass canonical ones.
        let includes = config.sources.include.map(canonicalPath(for:))
        let excludes = config.sources.exclude?.map(canonicalPath(for:))
        let templates = config.templates
        let updatedConfig = LegacyConfiguration(
            sources: MockConfiguration.Sources(
                include: includes,
                exclude: excludes
            ),
            templates: templates,
            output: output ?? ("." + config.output),
            args: config.args
        )
        try? self.config.delete()
        let yaml: String = try YAMLEncoder().encode(updatedConfig)
        try self.config.write(yaml)
    }

    private func canonicalPath(for source: String) -> String {
        let absolute = (root + Path(source)).absolute()
        let canonical = try? absolute.url.resourceValues(forKeys: [.canonicalPathKey]).canonicalPath
        return canonical ?? absolute.string
    }

    func cleanup() throws {
        try? config.delete()
        try? template.delete()
        try? path.delete()
    }
}
