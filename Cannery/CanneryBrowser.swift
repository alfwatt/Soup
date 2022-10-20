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
    var selectedAncestors: ILSoupCursor?
    
    @IBOutlet private var entryList: NSOutlineView!
    @IBOutlet private var entryDetail: NSTableView!
    @IBOutlet private var entryAncestors: NSTableView!

    func demoSoup() -> ILSoup {
        // create a memory soup
        let memory: ILMemorySoup = ILMemorySoup(name: "Address Book")

        // setup memory soup
        memory.soupDescription = "Address Book Example Soup"
        memory.createEntryIdentityIndex()
        memory.createAncestryIndex()
        memory.createIndex(ILSoupEntryDataHash)
        memory.createDateIndex(ILSoupEntryCreationDate)
        memory.createDateIndex(ILSoupEntryMutationDate)
        memory.createTextIndex(ILName)
        memory.createTextIndex(ILEmail)
        // memory.createTextIndex(ILNotes)
        
        // add some entries to the union
        memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "iStumbler Labs",
            ILEmail: "support@istumbler.net",
            ILURL:   URL(string:"https://istumbler.net/labs") as Any,
            ILPhone: "415-449-0905"
        ]))
        
        let luca = memory.createBlankEntry().mutatedEntry([
            ILName: "LUCA",
            ILEmail: "luca@life.earth"
        ])
        memory.add(luca); // BUG: the hash luca gets stored as isn't the same that the mutated entries get
        
        memory.add(luca.mutatedEntry([
            ILName:  "John Doe",
            ILEmail: "j.doe@example.com",
            ILSoupEntryIdentityUUID: NSUUID()
        ]))

        memory.add(luca.mutatedEntry([
            ILName:  "Jane Doe",
            ILEmail: "jane.d@example.com",
            ILSoupEntryIdentityUUID: NSUUID()
        ]))

        let kimAlias = memory.add(luca.mutatedEntry([
            ILName:  "Kim Gru",
            ILEmail: "kim.g@example.com",
            ILSoupEntryIdentityUUID: NSUUID()
        ]))
        let kimUUID = memory.gotoAlias(kimAlias).entryKeys[ILSoupEntryIdentityUUID]
        
        let samAlias = memory.add(luca.mutatedEntry([
            ILName:  "Sam Liu",
            ILEmail: "sam.l@example.com",
            ILSoupEntryIdentityUUID: NSUUID()
        ]))
        let samUUID = memory.gotoAlias(samAlias).entryKeys[ILSoupEntryIdentityUUID];

        let finAlias = memory.add(luca.mutatedEntry([
            ILName: "Fin Gru-Liu",
            ILEmail: "fin.gl@example.com",
            ILBirthday: Date(),
            ILParents: [kimUUID, samUUID],
            ILSoupEntryIdentityUUID: NSUUID()
        ]))
        let fin = memory.gotoAlias(finAlias)
        let finUUID = fin.entryKeys[ILSoupEntryIdentityUUID]
        
        let fin2 = memory.add(fin.mutatedEntry([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [finUUID],
            ILSoupEntryIdentityUUID: NSUUID()
        ]))
        
        return memory
    }
    
    func valueForAny(object: Any) -> String {
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
        entryAncestors.reloadData()
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
        else if let soupIndex = item as? ILSoupIndex {
            children = soupIndex.allEntries().entries.count
        }
        return children
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is ILSoupIndex
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var entry = "!" as Any
        if item == nil, let allIndicies = cannedSoup?.soupIndicies {
            entry = allIndicies[index]
        }
        else if let soupIndex = item as? ILSoupIndex {
            if index < soupIndex.allEntries().entries.count {
                let soupEntry = soupIndex.allEntries().entries[index]
                entry = [ "value": soupEntry.entryKeys[soupIndex.indexPath], "entry": soupEntry ]
            }
            else {
                print("WARNING - soupIndex: \(soupIndex) too short for outline index: \(index)")
            }
        }
        return entry as Any
    }
        
    func outlineView(_ outlineView: NSOutlineView, objectValueFor column: NSTableColumn?, byItem item: Any?) -> Any? {
        var data: Any?
        if let soupIndex = item as? ILSoupIndex {
            data = soupIndex.indexPath
        }
        else if let soupValue = item as? Dictionary<String,Any> {
            data = soupValue["value"]
        }
        return data
    }

}

// MARK: - NSOutlineViewDelegate

extension CanneryBrowser: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedItem = entryList.item(atRow: entryList.selectedRow)
        if selectedItem is ILSoupIndex {
            selectedEntry = nil
            selectedAncestors = nil
            self.window?.title = "Cannery"
        }
        else if let soupItem = selectedItem as? Dictionary<String,Any> {
            selectedEntry = soupItem["entry"] as? ILSoupEntry
            selectedAncestors = cannedSoup?.queryAncestryIndex().ancestery(of:selectedEntry!)
            self.window?.title = selectedEntry?.dataHash ?? "!"
        }
        entryDetail.reloadData()
        entryAncestors.reloadData()
    }
}

// MARK: - NSTableViewDataSource

extension CanneryBrowser:  NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        var rows = 0
        // get the number of properties for the selected item
        if let selectedEntry = selectedEntry {
            if tableView == entryDetail {
                rows = selectedEntry.sortedEntryKeys.count
            }
            else if tableView == entryAncestors {
                rows = selectedAncestors?.entries.count ?? 0
            }
        }
        return rows
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        var value: NSObject = "!" as NSObject
        if let selectedEntry = selectedEntry {
            if tableView == entryDetail {
                if let columnId = tableColumn?.identifier.rawValue {
                    let selectedKey = selectedEntry.sortedEntryKeys[row]
                    if columnId.isEqual("entry.key") {
                        value = selectedKey as NSObject;
                    }
                    else if columnId.isEqual("entry.value") {
                        value = selectedEntry.entryKeys[selectedKey] as! NSObject
                    }
                }
            }
            else if tableView == entryAncestors {
                if let columnId = tableColumn?.identifier.rawValue {
                    if let rowAncestor = selectedAncestors?.entries[row] {
                        if columnId.isEqual("ancestor.hash") {
                            value = rowAncestor.dataHash as NSObject
                        }
                        else if columnId.isEqual("ancestor.mutated") {
                            value = rowAncestor.entryKeys[ILSoupEntryMutationDate] as! NSObject
                        }
                        else if columnId.isEqual("ancestor.created") {
                            value = rowAncestor.entryKeys[ILSoupEntryCreationDate] as! NSObject
                        }
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
