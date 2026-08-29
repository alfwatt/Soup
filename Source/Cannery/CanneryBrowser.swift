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
    var cannedSoup: Soup?
    var visibleIndicies: [SoupIndex]?
    var selectedEntry: SoupEntry?
    var selectedAncestors: SoupCursor?
    
    @IBOutlet private var entryList: NSOutlineView!
    @IBOutlet private var entryDetail: NSTableView!
    @IBOutlet private var entryAncestors: NSTableView!

    func demoSoup() -> Soup {
        // create a memory soup
        let memory: MemorySoup = MemorySoup(name: "Address Book")

        // setup memory soup
        memory.soupDescription = "Address Book Example Soup"
        _ = memory.createEntryIdentityIndex()
        _ = memory.createAncestryIndex()
        _ = memory.createIndex(ILSoupEntryDataHash)
        _ = memory.createDateIndex(ILSoupEntryCreationDate)
        _ = memory.createDateIndex(ILSoupEntryMutationDate)
        _ = memory.createTextIndex(ILName)
        _ = memory.createIdentityIndex(ILEmail)
        // memory.createTextIndex(ILNotes)
        
        // add some entries to the union
        _ = memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "iStumbler Labs",
            ILEmail: "support@istumbler.net",
            ILURL:   URL(string:"https://istumbler.net/labs") as Any,
            ILPhone: "415-449-0905"
        ]))
        
        let luca = memory.createBlankEntry().mutatedEntry([
            ILName: "LUCA",
            ILEmail: "luca@life.earth",
            ILNotes: "I live on the ocean floor"
        ])
        _ = memory.add(luca); // BUG: the hash luca gets stored as isn't the same that the mutated entries get

        let john = luca.mutatedEntry([
            ILName:  "John Doe",
            ILEmail: "j.doe@example.com",
            ILNotes: NSNull()
        ])
        _ = memory.add(john)

        let jane = luca.mutatedEntry([
            ILName:  "Jane Doe",
            ILEmail: "jane.d@example.com",
            ILNotes: NSNull()
        ])
        _ = memory.add(jane)

        let kim = luca.mutatedEntry([
            ILName:  "Kim Gru",
            ILEmail: "kim.g@example.com",
            ILNotes: NSNull()
        ])
        _ = memory.add(kim)

        let sam = luca.mutatedEntry([
            ILName:  "Sam Liu",
            ILEmail: "sam.l@example.com",
            ILNotes: NSNull()
        ])
        _ = memory.add(sam)

        let fin = luca.mutatedEntry([
            ILName: "Fin Gru-Liu",
            ILEmail: "fin.gl@example.com",
            ILBirthday: Date(),
            ILParents: [kim.entryKeys[ILSoupEntryIdentityUUID],
                        sam.entryKeys[ILSoupEntryIdentityUUID]]
        ])
        _ = memory.add(fin)

        let fin2 = fin.mutatedEntry([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [fin.entryKeys[ILSoupEntryIdentityUUID]] // cloned
        ])
        _ = memory.add(fin2)

        let fin3 = fin2.mutatedEntry([
            ILName: "Fin Gru-Liu the 3rd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [fin2.entryKeys[ILSoupEntryIdentityUUID]]
        ])
        _ = memory.add(fin3)

        // update the email to create a mutated fin3
        let fin3update = fin3.mutatedEntry([
            ILEmail: "fin.gl3@example.com"
        ])
        _ = memory.add(fin3update)
        
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

    private func isSoupAlias(_ value: Any?) -> Bool {
        guard let url = value as? URL else { return false }
        return url.scheme == "alias"
    }

    private func linkedAlias(_ alias: SoupAlias) -> NSAttributedString {
        NSAttributedString(
            string: alias.absoluteString,
            attributes: [
                .link: alias,
                .foregroundColor: NSColor.linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
    }

    private func showEntry(for alias: SoupAlias) {
        guard let entry = cannedSoup?.gotoAlias(alias) else { return }
        selectedEntry = entry
        selectedAncestors = cannedSoup?.queryAncestryIndex()?.ancestry(of: entry)
        window?.title = "Cannery: " + entry.dataHash
        entryDetail.reloadData()
        entryAncestors.reloadData()
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
            _ = memory.addEntry(memory.createBlankEntry().mutatedEntry([
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
            if selectedEntry is SoupEntry {
                self.cannedSoup?.deleteEntry(selectedEntry as! SoupEntry)
            }
        }
        entryList.reloadItem(nil, reloadChildren:true)
    }
}

// MARK: - NSOutlineViewDataSource

extension CanneryBrowser: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        var children = 0
        if item == nil, let allIndicies = cannedSoup?.soupIndices {
            children = allIndicies.count
        }
        else if let soupIndex = item as? SoupIndex {
            children = Int(soupIndex.valueCount)
        }
        else if let indexValue = item as? Dictionary<String, Any>,
            let index = indexValue["index"] as? SoupIndex { // the dictionary has an index key
            let entries = index.entries(withValue: indexValue["value"])
            children = (entries.count == 1 ? 0 : entries.count) // one is none (don't show children)
        }
        
        return children
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        var expandable: Bool = false
        if item is SoupIndex {
            expandable = true
        }
        else if let indexValue = item as? Dictionary<String, Any>,
                let index = indexValue["index"] as? SoupIndex {
            let cursor = index.entries(withValue: indexValue["value"])
            expandable = (cursor.count > 1)
        }
        return expandable
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var childItem = "!" as Any // don't auto-type childItem
        
        // root is the list of indicies inthe soup
        if item == nil, let allIndicies = cannedSoup?.soupIndices {
            childItem = allIndicies[index]
        }
        // if the item is an index, get the cursor for all entries
        else if let soupIndex = item as? SoupIndex {
                let descriptor = NSSortDescriptor(key: "description", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            let value = soupIndex.allValues(orderedBy: descriptor)[index]
            childItem = ["index": soupIndex, "value": value] as [String : Any]
        }
        // if we got an index and a value, fetch the entries
        else if let indexValue = item as? Dictionary<String, Any>,
                let soupIndex = indexValue["index"] as? SoupIndex {
            let cursor = soupIndex.entries(withValue: indexValue["value"])
            childItem = cursor.entry(at: UInt(index))
        }
        
        return childItem as Any
    }
        
    func outlineView(_ outlineView: NSOutlineView, objectValueFor column: NSTableColumn?, byItem item: Any?) -> Any? {
        var data: Any?
        if let soupIndex = item as? SoupIndex {
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
        else if let entry = item as? SoupEntry {
            data = entry.dataHash
        }

        return data
    }
}

// MARK: - NSOutlineViewDelegate

extension CanneryBrowser: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedItem = entryList.item(atRow: entryList.selectedRow)
        if let index = selectedItem as? SoupIndex {
            selectedEntry = nil
            selectedAncestors = nil
            self.window?.title = "Cannery: " + index.indexPath
        }
        else if let indexValue = selectedItem as? Dictionary<String, Any>,
                let soupIndex = indexValue["index"] as? SoupIndex {
            // TODO: show a list of entries when the user selects a value
            let cursor = soupIndex.entries(withValue: indexValue["value"])
            if cursor.count == 1 {
                selectedEntry = cursor.entries.last
            }
            // else present a list of entries in the middle panel
        }
        else if let soupEntry = selectedItem as? SoupEntry {
            selectedEntry = soupEntry
        }

        if selectedEntry != nil {
            selectedAncestors = cannedSoup?.queryAncestryIndex()?.ancestry(of:selectedEntry!)
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
                        if let alias = value as? SoupAlias, isSoupAlias(alias) {
                            value = linkedAlias(alias)
                        }
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
                            value = linkedAlias(rowAncestor.entryHash)
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

// MARK: - NSTableViewDelegate

extension CanneryBrowser: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView,
              tableView.selectedColumn >= 0,
              tableView.selectedColumn < tableView.tableColumns.count else {
            return
        }
        let column = tableView.tableColumns[tableView.selectedColumn]

        if tableView == entryDetail,
           column.identifier.rawValue == "entry.value",
           selectedEntry != nil,
           tableView.selectedRow >= 0,
           tableView.selectedRow < selectedEntry!.sortedEntryKeys.count {
            let key = selectedEntry!.sortedEntryKeys[tableView.selectedRow]
            if let alias = selectedEntry!.entryKeys[key] as? SoupAlias, isSoupAlias(alias) {
                showEntry(for: alias)
            }
        } else if tableView == entryAncestors,
                  column.identifier.rawValue == "ancestor.hash",
                  tableView.selectedRow >= 0,
                  let ancestors = selectedAncestors?.entries,
                  tableView.selectedRow < ancestors.count {
            let ancestor = ancestors[tableView.selectedRow]
            showEntry(for: ancestor.entryHash)
        }
    }
}

// MARK: - NSToolbarDelegate

extension CanneryBrowser: NSToolbarDelegate {
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return []
    }
}
