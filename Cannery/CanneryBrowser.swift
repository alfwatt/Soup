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
    public var cannedSoup: ILSoup!
    @IBOutlet private var entryList: NSOutlineView!
    @IBOutlet private var entryDetail: NSTableView!

    func demoSoup() -> ILSoup {
        // create a file/memory union soup
        let soup: ILUnionSoup = ILUnionSoup()
        let memory: ILMemorySoup = ILMemorySoup(name: "Address Book")
        let files: ILFileSoup = ILFileSoup(atPath: "~/Desktop/AddressBook.soup")
        soup.add(files)
        soup.add(memory)

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
        soup.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "iStumbler Labs",
            ILEmail: "support@istumbler.net",
            ILURL:   URL(string:"https://istumbler.net/labs") as Any,
            ILPhone: "415-449-0905"
        ]))

        soup.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "John Doe",
            ILEmail: "j.doe@example.com"
        ]))

        soup.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "Jane Doe",
            ILEmail: "jane.d@example.com"
        ]))

        let kimAlias = soup.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "Kim Gru",
            ILEmail: "kim.g@example.com"
        ]))
        let kimUUID = soup.gotoAlias(kimAlias).entryKeys[ILSoupEntryUUID]
        
        let samAlias = soup.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "Sam Liu",
            ILEmail: "sam.l@example.com"
        ]))
        let samUUID = soup.gotoAlias(samAlias).entryKeys[ILSoupEntryUUID];

        soup.add(memory.createBlankEntry().mutatedEntry([
            ILName: "Fin Gru-Liu",
            ILEmail: "fin.gl@example.com",
            ILBirthday: Date(),
            ILParents: [kimUUID, samUUID]
        ]))
        
        return soup
    }

    // MARK: - NSWindowController Overrides

    override func windowDidLoad() {
        super.windowDidLoad()
        self.cannedSoup = demoSoup()
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
            let allEntries = cannedSoup.cursor.entries
            rows = allEntries!.count
        }
        else if tableView == entryDetail {
            rows = 1
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
            children = 2 // TODO number of indexes in the soup, starts withh Identity
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
