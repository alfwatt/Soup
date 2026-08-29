import Foundation

open class FileSoup: SoupStock {
    public let filePath: String

    public required init(name soupName: String) {
        self.filePath = soupName
        super.init(name: soupName)
    }

    public init(filePath: String) {
        self.filePath = filePath
        super.init(name: URL(fileURLWithPath: filePath).lastPathComponent)
    }

    public class func fileSoup(atPath filePath: String) -> FileSoup {
        FileSoup(filePath: filePath)
    }
}
