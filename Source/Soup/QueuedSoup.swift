import Foundation

@objc(ILQueuedSoupDelegate)
public protocol QueuedSoupDelegate: SoupDelegate {}

@objc(ILQueuedSoup)
@objcMembers
open class QueuedSoup: SoupStock {
    public var queued: Soup
    public var soupOperations: OperationQueue

    public required init(name soupName: String) {
        self.queued = MemorySoup(name: soupName)
        self.soupOperations = OperationQueue()
        super.init(name: soupName)
    }

    public init(queuedSoup: Soup, soupQueue soupOps: OperationQueue?) {
        self.queued = queuedSoup
        self.soupOperations = soupOps ?? OperationQueue()
        super.init(name: queuedSoup.soupName)
    }

    public class func queuedSoup(_ queuedSoup: Soup, soupQueue soupOps: OperationQueue?) -> QueuedSoup {
        QueuedSoup(queuedSoup: queuedSoup, soupQueue: soupOps)
    }
}
