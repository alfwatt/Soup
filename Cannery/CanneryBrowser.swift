import Cocoa
import Soup

let ILName = "name"
let ILEmail = "email"
let ILPhone = "phone"
let ILURL = "url"
let ILNotes = "notes"
let ILBirthday = "birthday"
let ILParents = "parents"
let ILSpouse = "spouse"

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
        memory.createIdentityIndex(ILEmail)
        // memory.createTextIndex(ILNotes)
        
        // add some entries to the union
        memory.add(memory.createBlankEntry()!.mutatedEntry([
            ILName:  "iStumbler Labs",
            ILEmail: "support@istumbler.net",
            ILURL:   URL(string:"https://istumbler.net/labs") as Any,
            ILPhone: "415-449-0905"
        ]))
        
        let luca = memory.createBlankEntry()!.mutatedCopy([
            ILName: "LUCA",
            ILEmail: "luca@life.earth",
            ILNotes: "I live on the ocean floor"
        ])
        memory.add(luca); // BUG: the hash luca gets stored as isn't the same that the mutated entries get
        
        let john = luca.mutatedCopy([
            ILName:  "John Doe",
            ILEmail: "j.doe@example.com",
            ILNotes: NSNull()
        ])
        memory.add(john)

        let jane = luca.mutatedCopy([
            ILName:  "Jane Doe",
            ILEmail: "jane.d@example.com",
            ILNotes: NSNull()
        ])
        memory.add(jane)

        let kim = luca.mutatedCopy([
            ILName:  "Kim Gru",
            ILEmail: "kim.g@example.com",
            ILNotes: NSNull()
        ])
        memory.add(kim)
        
        let sam = luca.mutatedCopy([
            ILName:  "Sam Liu",
            ILEmail: "sam.l@example.com",
            ILNotes: NSNull()
        ])
        memory.add(sam)

        let fin = luca.mutatedCopy([
            ILName: "Fin Gru-Liu",
            ILEmail: "fin.gl@example.com",
            ILBirthday: Date(),
            ILParents: [kim.entryKeys[ILSoupEntryIdentityUUID],
                        sam.entryKeys[ILSoupEntryIdentityUUID]]
        ])
        memory.add(fin)
        
        let fin2 = fin.mutatedCopy([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [fin.entryKeys[ILSoupEntryIdentityUUID]] // cloned
        ])
        memory.add(fin2)
        
        let fin3 = fin2.mutatedCopy([
            ILName: "Fin Gru-Liu the 3rd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [fin2.entryKeys[ILSoupEntryIdentityUUID]]
        ])
        memory.add(fin3)
        
        // update the email to create a mutated fin3
        let fin3update = fin3.mutatedEntry([
            ILEmail: "fin.gl3@example.com"
        ])
        memory.add(fin3update)
        
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
            memory.add(memory.createBlankEntry()!.mutatedEntry([
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
        for selectedRow in entryList.selectedRowIndexes {
            let selectedItem: Dictionary = entryList.item(atRow: selectedRow) as! Dictionary<String, Any>
            let selectedEntry = selectedItem["entry"]
            if selectedEntry is ILSoupEntry {
                self.cannedSoup?.delete(selectedEntry as! ILSoupEntry)
            }
        }
        entryList.reloadItem(nil, reloadChildren:true)
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
            children = Int(soupIndex.valueCount)
        }
        else if let indexValue = item as? Dictionary<String, Any>,
            let index = indexValue["index"] as? ILSoupIndex { // the dictionary has an index key
            let entries = index.entries(withValue: indexValue["value"])
            children = (entries.count == 1 ? 0 : entries.count) // one is none (don't show children)
        }
        
        return children
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        var expandable: Bool = false
        if item is ILSoupIndex {
            expandable = true
        }
        else if let indexValue = item as? Dictionary<String, Any>,
                let index = indexValue["index"] as? ILSoupIndex {
            let cursor = index.entries(withValue: indexValue["value"])
            expandable = (cursor.count > 1)
        }
        return expandable
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var childItem = "!" as Any // don't auto-type childItem
        
        // root is the list of indicies inthe soup
        if item == nil, let allIndicies = cannedSoup?.soupIndicies {
            childItem = allIndicies[index]
        }
        // if the item is an index, get the cursor for all entries
        else if let soupIndex = item as? ILSoupIndex {
                let descriptor = NSSortDescriptor(key: "description", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            let value = soupIndex.allValuesOrdered(by: descriptor)[index]
            childItem = ["index": soupIndex, "value": value] as [String : Any]
        }
        // if we got an index and a value, fetch the entries
        else if let indexValue = item as? Dictionary<String, Any>,
                let soupIndex = indexValue["index"] as? ILSoupIndex {
            let cursor = soupIndex.entries(withValue: indexValue["value"])
            childItem = cursor.entry(at: UInt(index))
        }
        
        return childItem as Any
    }
        
    func outlineView(_ outlineView: NSOutlineView, objectValueFor column: NSTableColumn?, byItem item: Any?) -> Any? {
        var data: Any?
        if let soupIndex = item as? ILSoupIndex {
            data = String(format:"%@ \"%@\" %i/%i",
                          String(describing:type(of: soupIndex)).replacingOccurrences(of: "ILStock", with: ""),
                          soupIndex.indexPath,
                          soupIndex.valueCount,
                          soupIndex.entryCount)
        }
        else if let soupValue = item as? Dictionary<String,Any> {
            data = soupValue["value"]
            if let array = data as? [String] {
                data = array.joined(separator: ", ")
            }
        }
        else if let entry = item as? ILSoupEntry {
            data = entry.dataHash
        }

        return data
    }
}

// MARK: - NSOutlineViewDelegate

extension CanneryBrowser: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedItem = entryList.item(atRow: entryList.selectedRow)
        if let index = selectedItem as? ILSoupIndex {
            selectedEntry = nil
            selectedAncestors = nil
            self.window?.title = "Cannery: " + index.indexPath
        }
        else if let indexValue = selectedItem as? Dictionary<String, Any>,
                let soupIndex = indexValue["index"] as? ILSoupIndex {
            // TODO: show a list of entries when the user selects a value
            let cursor = soupIndex.entries(withValue: indexValue["value"])
            if cursor.count == 1 {
                selectedEntry = cursor.entries.last
            }
            // else present a list of entries in the middle panel
        }
        else if let soupEntry = selectedItem as? ILSoupEntry {
            selectedEntry = soupEntry
        }

        if selectedEntry != nil {
            selectedAncestors = cannedSoup?.queryAncestryIndex()?.ancestery(of:selectedEntry!)
            self.window?.title = "Cannery: " + (selectedEntry?.dataHash ?? "!")
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
        var value = "-" as Any?
        if let selectedEntry = selectedEntry {
            if tableView == entryDetail {
                if let columnId = tableColumn?.identifier.rawValue {
                    let selectedKey = selectedEntry.sortedEntryKeys[row]
                    if columnId.isEqual("entry.key") {
                        value = selectedKey as NSObject;
                    }
                    else if columnId.isEqual("entry.value") {
                        value = selectedEntry.entryKeys[selectedKey]
                    }
                }
            }
            else if tableView == entryAncestors {
                if let columnId = tableColumn?.identifier.rawValue {
                    if let rowAncestor = selectedAncestors?.entries[row] {
                        if columnId.isEqual("ancestor.generation") {
                            value = row
                        }
                        if columnId.isEqual("ancestor.hash") {
                            value = rowAncestor.dataHash as NSObject
                        }
                        else if columnId.isEqual("ancestor.mutated"),
                            rowAncestor.entryKeys[ILSoupEntryMutationDate] != nil {
                            value = rowAncestor.entryKeys[ILSoupEntryMutationDate]
                        }
                        else if columnId.isEqual("ancestor.created"),
                            rowAncestor.entryKeys[ILSoupEntryCreationDate] != nil {
                            value = rowAncestor.entryKeys[ILSoupEntryCreationDate]
                        }
                        else if columnId.isEqual("ancestor.name"),
                            rowAncestor.entryKeys[ILName] != nil {
                            value = rowAncestor.entryKeys[ILName]
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
