# Legacy

If really you don't want to use the **CLI** (😢) then you can still use SwiftyMocky with a Sourcery configuration, described below. This is the "old" way of integrating our library.

Summing up, you need **SwiftyMocky** framework in the runtime, and **sourcery** binary with a configuration pointing to our template for the mocks generation.

## Installation

Add SwiftyMocky to your test target using [Swift Package Manager](https://swift.org/package-manager/), as described in [installation][link-docs-installation] instructions.

Then add **mocky.yml** and **Rakefile** (or build script phase) to your project root directory, as described in below. See full [setup][link-docs-setup] instructions.

You also need the SwiftyMocky template. It ships in the package at `Sources/SwiftyMocky/Mock.swifttemplate` (for a SwiftPM project, the checkout lives in `.build/checkouts/SwiftyMocky`). The most reliable option is to copy it into your repository, e.g. `./Templates/Mock.swifttemplate`, and update it together with the SwiftyMocky version.

### Generating mocks implementations:

One of the boilerplate part of testing and development is writing and updating **mocks** accordingly to newest changes. SwiftyMocky is capable of generating mock implementations (with configurable behavior), based on protocol definition.

During development process it is possible to use SwiftyMocky in a *watcher* mode, which will observe changes in you project files, and regenerate files on the fly.

![Generating mock][example-watcher]

By default, all protocols marked as AutoMockable (inheriting from dummy protocol `AutoMockable` or annotated with `//sourcery: AutoMockable`) are being subject of mock implementation generation. All mocks goes to `Mock.generated.swift`, which can be imported into test target.

# How to start using SwiftyMocky

Mocks generation is based on `mocky.yml` file.

First, create file in your project root directory with following structure:

```yml
sources:
  include:
    - ./ExampleApp
    - ./ExampleAppTests
templates:
  - ./Templates/Mock.swifttemplate
output:
  ./ExampleApp
args:
  testable:
    - ExampleApp
  import:
    - RxSwift
    - RxBlocking
  excludedSwiftLintRules:
    - force_cast
    - function_body_length
    - line_length
    - vertical_whitespace
```

+ **sources**: all directories you want to scan for protocols/files marked to be auto mocked, or inline mocked. You can use `exclude`, to prevent from scanning particular files (makes sense for big `*.generated.swift` files)
+ **templates**: path to the SwiftyMocky sourcery template
+ **output**: place where `Mock.generated.swift` will be placed
+ **testable**: specify imports for Mock.generated, that should be marked as `@testable` (usually tested app module)
+ **import**: all additional imports, external libraries etc. to be placed in Mock.generated
+ **excludedSwiftLintRules**: if using swift SwiftLint.

If you are already using [Sourcery](https://github.com/krzysztofzablocki/Sourcery) with your own templates and you have configured `sourcery.yml` file, you can extend it to add support for SwiftyMocky. Click [here][link-guides-installation] for details.

## Generate mocks:

1. **manually**: by triggering:

  `mint run krzysztofzablocki/Sourcery@2.4.1 sourcery --config mocky.yml`
1. **in `watch` mode**: changed methods will be reflected in mocks, after generation of mock, by triggering:

  `mint run krzysztofzablocki/Sourcery@2.4.1 sourcery --config mocky.yml --watch`

> **!!! In case of incompatibile swift module versions error** - check Known issues section in guides or docs

**Don't forget** to add `Mock.generated.swift` to your test target :)

> **Please Note!**
> Most convenient way is to put generation in some kind of script - like Rakefile below.
> Just create file named Rakefile - generation is triggered by `rake mock`
> ```ruby
> # Rakefile
> task :mock do
>   sh "mint run krzysztofzablocki/Sourcery@2.4.1 sourcery --config mocky.yml"
> end
>
> task :mock_watcher do
>   sh "mint run krzysztofzablocki/Sourcery@2.4.1 sourcery --config mocky.yml --watch"
> end
> ```


## Setup for Sourcery users (alternative to mocky.yml):

We know that Sourcery is a powerful tool and you are likely to use it already. You can easily integrate SwiftyMocky with your project with keeping all already written templates working.

All you have to do is add path to the SwiftyMocky template in your `sourcery.yml` file:

```yaml
sources:
    - ./ExampleApp
    - ./ExampleAppTests
templates:
    - <templates path> # Path to already written Sourcery templates
    - ./Templates/Mock.swifttemplate # <- SwiftyMocky template
output:
    ./ExampleApp
args:
  testable:
    - ExampleApp
  import:
    - RxSwift
    - RxBlocking
  excludedSwiftLintRules:
    - force_cast
    - function_body_length
    - line_length
    - vertical_whitespace
```

You can use all arguments (like `testable`, `import`, etc.) in the same way as in `mocky.yaml`, under `args` key.

## Sourcery version

SwiftyMocky templates require **Sourcery 2.4.1**. The commands above run it through [Mint](https://github.com/yonaskolb/Mint); any other Sourcery 2.4.1 binary works as well.

<!-- Assets -->

[example-link]: https://raw.githubusercontent.com/MakeAWishFoundation/SwiftyMocky/3.2.0/guides/assets/link-binary-with-libraries.png "Example - link binary"
[example-add]: https://raw.githubusercontent.com/MakeAWishFoundation/SwiftyMocky/3.2.0/guides/assets/add-new-copy-files-phase.png "Example - add copy files phase"
[example-copy]: https://raw.githubusercontent.com/MakeAWishFoundation/SwiftyMocky/3.2.0/guides/assets/add-framework-tocopy-files-phase.png "Example - add SwiftyMocky to copy frameworks"


[example-watcher]: https://raw.githubusercontent.com/MakeAWishFoundation/SwiftyMocky/1.0.0/guides/assets/example-watcher.gif "Example - generation"