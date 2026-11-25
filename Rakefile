## [ Mocks Generation ] ########################################################

task :mock do
    print_info "Generating mocks using local CLI version"
    sh "swift run swiftymocky generate"
end

## [ Tools ] ###################################################################

task :update do
    print_info "Re-Generating main template from parts"

    # Prepare SwiftyMocky template
    destination = "../Sources/SwiftyMocky/Mock.swifttemplate"
    sh "rm -rf #{destination}"
    sh "cd ./Templates && echo \"<%_\" > #{destination}"
    sh "cd ./Templates && echo 'let mockTypeName = \"Mock\"' >> #{destination}"
    sh "cd ./Templates && cat ArgumentsHelper.swift >> #{destination}"
    sh "cd ./Templates && echo \"_%>\" >> #{destination}"
    sh "cd ./Templates && cat Header-Mock.swifttemplate >> #{destination}"
    sh "cd ./Templates && cat Imports.swifttemplate >> #{destination}"
    sh "cd ./Templates && echo \"<%_\" >> #{destination}"
    sh "cd ./Templates && cat Current.swift >> #{destination}"
    sh "cd ./Templates && cat TemplateHelper.swift >> #{destination}"
    sh "cd ./Templates && cat Helpers.swift >> #{destination}"
    sh "cd ./Templates && cat ParameterWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat TypeWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat MethodWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat SubscriptWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat VariableWrapper.swift >> #{destination}"
    sh "cd ./Templates && echo \"_%>\" >> #{destination}"
    sh "cd ./Templates && cat Main.swifttemplate >> #{destination}"

    # Prepare SwiftyPrototype template
    destination = "../Sources/SwiftyPrototype/Prototype.swifttemplate"
    sh "rm -rf #{destination}"
    sh "cd ./Templates && echo \"<%_\" > #{destination}"
    sh "cd ./Templates && echo 'let mockTypeName = \"Prototype\"' >> #{destination}"
    sh "cd ./Templates && cat ArgumentsHelper.swift >> #{destination}"
    sh "cd ./Templates && echo \"_%>\" >> #{destination}"
    sh "cd ./Templates && cat Header-Prototype.swifttemplate >> #{destination}"
    sh "cd ./Templates && cat Imports.swifttemplate >> #{destination}"
    sh "cd ./Templates && echo \"<%_\" >> #{destination}"
    sh "cd ./Templates && cat Current.swift >> #{destination}"
    sh "cd ./Templates && cat TemplateHelper.swift >> #{destination}"
    sh "cd ./Templates && cat Helpers.swift >> #{destination}"
    sh "cd ./Templates && cat ParameterWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat TypeWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat MethodWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat SubscriptWrapper.swift >> #{destination}"
    sh "cd ./Templates && cat VariableWrapper.swift >> #{destination}"
    sh "cd ./Templates && echo \"_%>\" >> #{destination}"
    sh "cd ./Templates && cat Main.swifttemplate >> #{destination}"
end

desc "Regenerates templates and mocks, then runs SwiftPM tests"
task :test do
    sh "rake update"
    sh "rake cli:assetize"
    sh "rake mock"
    sh "swift test"
end

task :xcode do
    sh "open SwiftyMocky.xcodeproj"
end

## [ Deploy ] ##################################################################

desc "Sets new version"
task :version do
    ARGV.each { |a| task a.to_sym do ; end }
    version_from = ARGV[1].to_s.strip
    version_to = ARGV[2].to_s.strip
    if version_from && !version_from.empty? && version_to && !version_to.empty?
        print_info "Changing version from #{version_from} -> #{version_to} !\n"
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./.jazzy.yaml")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./README.md")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./guides/Installation.md")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./guides/Overview.md")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./Templates/Header-Mock.swifttemplate")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./Templates/Header-Prototype.swifttemplate")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./Makefile")
        sh("sed -i '' 's|#{version_from}|#{version_to}|g' ./Sources/CLI/Core/Application.swift")
    else
        print("Missing versions!\n")
        exit(1)
    end
end

namespace :cli do
    desc "Assetizes templates for specified version of a SwiftyMocky into CLI"
    task :assetize do
        sh "swift run swiftymocky assetize"
    end

    task :build do
        print_info "Building CLI release version binary"
        # sh "swift build -c release --disable-sandbox"
        sh "swift build -c release"
    end
end

desc "Deploys new version of a binary, by pushing passed tag"
task :deploy do
    ARGV.each { |a| task a.to_sym do ; end }
    version = ARGV[1].to_s
    if version && !version.to_s.strip.empty?
        sh("git commit -m \"Deploy #{version}\"")
        sh("git push")
        sh("git tag #{version} && git push --tags")
    else
        print("Missing version!\n")
        exit(1)
    end
end

## [ Docs ] ####################################################################

desc "Update docs"
task :docs do
    print_info "Updating docs"
    # Build through the package workspace: `--spm` can't read SwiftPM 6.4+ build layout, and the
    # root SwiftyMocky.xcodeproj would shadow the package for a plain `xcodebuild -scheme`.
    sh "sourcekitten doc --module-name SwiftyMocky -- -workspace .swiftpm/xcode/package.xcworkspace -scheme SwiftyMocky -destination 'generic/platform=macOS' > docs.json && jazzy --clean && rm docs.json"
end

## [ Helpers ] #################################################################

def print_info(str)
    (red,clr) = (`tput colors`.chomp.to_i >= 8) ? %W(\e[33m \e[m) : ["", ""]
    puts red, "== #{str.chomp} ==", clr
end
