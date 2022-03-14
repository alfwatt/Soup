import Cocoa
import Soup

let ILName = "name"
let ILEmail = "email"
let ILPhone = "phone"
let ILURL = "url"
let ILNotes = "notes"
let ILBirthday = "birthday"
let ILParents = "parents"

class CanneryBrowser: NSWindowController {
    var cannedSoup: ILSoup?
    var visibleIndicies: [ILSoupIndex]?
    var selectedEntry: ILSoupEntry?
    @IBOutlet private var entryList: NSOutlineView!
    @IBOutlet private var entryDetail: NSTableView!

    func demoSoup() -> ILSoup {
        // create a memory soup
        let memory: ILMemorySoup = ILMemorySoup(name: "Address Book")

        // setup memory soup
        memory.soupDescription = "Address Book Example Soup"
        memory.createIdentityIndex(ILSoupEntryUUID)
        memory.createIndex(ILSoupEntryAncestorKey)
        memory.createIndex(ILSoupEntryDataHash)
        memory.createDateIndex(ILSoupEntryCreationDate)
        memory.createDateIndex(ILSoupEntryMutationDate)
        memory.createTextIndex(ILName)
        memory.createTextIndex(ILEmail)
        memory.createTextIndex(ILNotes)
        
        // add some entries to the union
        memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "iStumbler Labs",
            ILEmail: "support@istumbler.net",
            ILURL:   URL(string:"https://istumbler.net/labs") as Any,
            ILPhone: "415-449-0905"
        ]))
        
        memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "John Doe",
            ILEmail: "j.doe@example.com"
        ]))

        memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "Jane Doe",
            ILEmail: "jane.d@example.com"
        ]))

        let kimAlias = memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "Kim Gru",
            ILEmail: "kim.g@example.com"
        ]))
        let kimUUID = memory.gotoAlias(kimAlias).entryKeys[ILSoupEntryUUID]
        
        let samAlias = memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "Sam Liu",
            ILEmail: "sam.l@example.com"
        ]))
        let samUUID = memory.gotoAlias(samAlias).entryKeys[ILSoupEntryUUID];

        memory.add(memory.createBlankEntry().mutatedEntry([
            ILName: "Fin Gru-Liu",
            ILEmail: "fin.gl@example.com",
            ILBirthday: Date(),
            ILParents: [kimUUID, samUUID]
        ]))
        
        return memory
    }

    // MARK: - NSNibAwakening

    override func awakeFromNib() {
        super.windowDidLoad()
        self.cannedSoup = demoSoup()
        entryList.reloadData()
        entryDetail.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func onCreateEntry(_ sender: Any) {
        if let memory = cannedSoup {
            memory.add(memory.createBlankEntry().mutatedEntry([
                ILName: "New Entry"
            ]))
        }
        else {
            NSLog("onCreateEntry cannedSoup is nil")
        }

    }

    @IBAction func onRevertEntry(_ sender: Any) {
        NSLog("onRevertEntry")
    }

    @IBAction func onUpdateEntry(_ sender: Any) {
        NSLog("onUpdateEntry")
    }

    @IBAction func onDeleteEntry(_ sender: Any) {
        NSLog("onDeleteEntry")
    }
}

// MARK: - NSOutlineViewDataSource

extension CanneryBrowser: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        var children = 0
        if item == nil {
            if let allEntries = cannedSoup?.cursor.entries {
                children = allEntries.count
            }
        }
        return children
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var entry: ILSoupEntry?
        if item == nil {
            if let allEntries = cannedSoup?.cursor.entries {
                entry = allEntries[index]
            }
        }
        return entry as Any
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor column: NSTableColumn?, byItem item: Any?) -> Any? {

        NSLog("objectValueFor: %@", column ?? "nul")
        
        var data = "!"
        if let entry = item as? ILSoupEntry {
            data = entry.entryHash
        }
        
        return data
    }

}

// MARK: - NSTableViewDataSource

extension CanneryBrowser:  NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        var rows = 0
        // get the number of properties for the selected item
        if tableView == entryDetail {
            if let selectedEntry = selectedEntry {
                rows = selectedEntry.entryKeys.keys.count
            }
        }
        return rows
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        var value = "!"
        if let cursor = cannedSoup?.cursor, row < cursor.entries.count,
            entryList.selectedRowIndexes.count > 0, let tableColumn = tableColumn {
            let rowEntry: ILSoupEntry = cursor.entries[entryList.selectedRow]
            let entryKeyValues = Array(rowEntry.entryKeys.keys)
            let sortedKeyValues = entryKeyValues.sorted { ($0 as! String) > ($1 as! String) }
            let rowKey = sortedKeyValues[row]
            if tableColumn.identifier.rawValue == "entry.key" {
                value = rowKey as! String
            }
            else if tableColumn.identifier.rawValue == "entry.value" {
                value = rowEntry.entryKeys[row] as? String ?? "nil"
            }
        }
        return value
    }
}

// MARK: - NSToolbarDelegate

extension CanneryBrowser: NSToolbarDelegate {
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return []
    }
}
