import Cocoa
import Soup

class CanneryBrowser: NSWindowController {
    public var cannedSoup: ILSoup!
    @IBOutlet private var entryList: NSOutlineView!
    @IBOutlet private var entryDetail: NSTableView!

    // MARK: - NSWindowController Overrides

    override func windowDidLoad() {
        super.windowDidLoad()
        entryList.reloadData()
        entryDetail.reloadData()
    }
}

// MARK: - NSOutlineViewDelegate

extension CanneryBrowser: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let viewCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as! NSTableCellView
        viewCell.textField?.stringValue = "text"
        return viewCell
    }
}

// MARK: - NSTableViewDataSource

extension CanneryBrowser:  NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        var rows = 0
        if tableView == entryList {
            rows = 2
        }
        else if tableView == entryDetail {
            rows = 4
        }
        return rows
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        var value = "!"
        if let columnId = tableColumn?.identifier.rawValue {
            if columnId.isEqual("entry.key") {
                value = "Key"
            }
            else if columnId.isEqual("entry.value") {
                value = "Value"
            }
        }
        return value
    }
}

// MARK: - NSOutlineViewDataSource

extension CanneryBrowser: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        var children = 0
        if item == nil {
            children = 2 // TODO humber of indexes in the soup, starts withh Identity
        }
        return children
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return "entry"
    }
}
