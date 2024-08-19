import Cocoa
import Foundation

@NSApplicationMain
class CanneryDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var soupBrowser: CanneryBrowser?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        soupBrowser = CanneryBrowser.init(windowNibName:"CanneryBrowser")
        soupBrowser?.loadWindow()
        soupBrowser?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

}
