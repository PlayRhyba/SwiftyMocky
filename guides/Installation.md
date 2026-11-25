<a name="installation-cli"></a>

# SwiftyMocky CLI

CLI will help you with project setup and mocks generation. Also, it supports new **Mockfile** format.

To install it:

**[Mint 🌱](https://github.com/yonaskolb/Mint)**:

```bash
> brew install mint
> mint install PlayRhyba/SwiftyMocky
```

**Make**:

Clone the repository and run `make` in its root directory:

```bash
> git clone https://github.com/PlayRhyba/SwiftyMocky.git
> cd SwiftyMocky && make
```

> More information about **CLI** you will fund in "Command Line Interface" section.

<a name="installation-runtime"></a>

# SwiftyMocky Runtime installation

SwiftyMocky Runtime is available through:

## 1. **[Ice Package Manager ❄️](https://github.com/jakeheis/Ice)**:

```bash
> ice add PlayRhyba/SwiftyMocky
```

> It will be supported when Ice reviews PR, fallback to SwiftPM if any issues.

## 2. **[Swift Package Manager](https://swift.org/package-manager/)**:

Add **SwiftyMocky** to you **Package.swift** dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/PlayRhyba/SwiftyMocky", from: "4.3.1"),
]
```

And add `SwiftyMocky` to your test target dependencies.

## Sourcery version

SwiftyMocky templates require **Sourcery 2.4.1**. The CLI runs it through [Mint](https://github.com/yonaskolb/Mint) by default (`mint run krzysztofzablocki/Sourcery@2.4.1 sourcery`). To use a different binary, set `sourceryCommand` in your [Mockfile](./Mockfile.md).

<!-- Assets -->

