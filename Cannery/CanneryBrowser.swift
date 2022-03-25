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

    static func valueForAny(object: Any) -> String {
        var value = ""
        
        if let object = object as? String {
            value = object
        }
        else if let object = object as? NSObject {
            value = object.description
        }
        
        return value
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
        if item == nil, let allIndicies = cannedSoup?.soupIndicies {
            children = allIndicies.count
        }
        else if let soupIndexPath = item as? ILIndexPath {
            if let soupIndex = cannedSoup?.soupIndicies[soupIndexPath] {
                children = soupIndex.
            }
        }
        return children
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is ILSoupIndex
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var entry = "!" as Any
        if item == nil, let allIndicies = cannedSoup?.soupIndicies {
            entry = allIndicies[index].indexPath! // save the index path so we can look it up later
        }
        else if let soupIndex = item as? ILSoupIndex {
            if index < soupIndex.allEntries().entries.count {
                entry = soupIndex.allEntries()?.entries[index] as Any
            }
            else {
                print("WARNING - soupIndex: \(soupIndex) too short for outline index: \(index)")
            }
        }
        return entry as Any
    }
        
    func outlineView(_ outlineView: NSOutlineView, objectValueFor column: NSTableColumn?, byItem item: Any?) -> Any? {
        var data: Any?
        if let soupIndex = item as? ILIndexPath {
            data = soupIndex
        }
        else if let soupEntry = item as? ILSoupEntry {
            let entryIndexPath = outlineView.parent(forItem: item) as! ILIndexPath
            if let entryValue = soupEntry.entryKeys[entryIndexPath as String] {
                data = String(describing: entryValue)
            }
        }
        return data
    }

}

// MARK: - NSOutlineViewDelegate

extension CanneryBrowser: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedIndex = entryList.selectedRow
        if selectedIndex != NSNotFound {
            if let allEntries = cannedSoup?.cursor.entries {
                if selectedIndex <= allEntries.count  {
                    selectedEntry = allEntries[selectedIndex]
                    entryDetail.reloadData()
                }
            }
        }
    }
}

// MARK: - NSTableViewDataSource

extension CanneryBrowser:  NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        var rows = 0
        // get the number of properties for the selected item
        if tableView == entryDetail {
            if let selectedEntry = selectedEntry {
                rows = selectedEntry.sortedEntryKeys.count
            }
        }
        return rows
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        var value: NSObject = "!" as NSObject
        if let selectedEntry = selectedEntry {
            if let columnId = tableColumn?.identifier.rawValue {
                let sortedKeys = selectedEntry.sortedEntryKeys
                if let selectedKey = sortedKeys?[row] {
                    if columnId.isEqual("entry.key") {
                        value = selectedKey as NSObject;
                    }
                    else if columnId.isEqual("entry.value") {
                        value = selectedEntry.entryKeys[selectedKey] as! NSObject
                    }
                }
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
