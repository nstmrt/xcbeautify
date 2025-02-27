import Foundation

public class OutputHandler {
    let quiet: Bool
    let quieter: Bool
    let isCI: Bool
    let writer: (String) -> Void

    /// In quiet mode, lastFormatted will record last output and whether it will be
    /// printed is determined by the current output type. In this way, if we encounter
    /// warnings or errors, we get a chance to print last output as their banner. So now
    /// the output is in following form:
    /// [Target] Doing Something
    /// warnings or errors
    ///
    /// Ref: https://github.com/tuist/xcbeautify/pull/15
    private var lastFormatted: String? = nil

    public init(quiet: Bool, quieter: Bool, isCI: Bool = false, _ writer: @escaping (String) -> Void) {
        self.quiet = quiet
        self.quieter = quieter
        self.isCI = isCI
        self.writer = writer
    }

    public func write(_ type: OutputType, _ content: String?) {
        guard let content = content else { return }

        if !quiet, !quieter {
            writer(content)
            return
        }

        switch type {
        case OutputType.warning:
            if quieter { return }
            fallthrough
        case OutputType.error:
            if let last = lastFormatted {
                writer(last)
                lastFormatted = nil
            }
            writer(content)
        case OutputType.result:
            writer(content)
        case OutputType.test:
            if isCI {
                writer(content)
            } else {
                fallthrough
            }
        default:
            lastFormatted = content
        }
    }
}
