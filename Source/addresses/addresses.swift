import Foundation
import Soup

private let name = "name"
private let email = "email"
private let phone = "phone"
private let url = "url"
private let notes = "notes"
private let birthday = "birthday"
private let parents = "parents"

@main
struct Addresses {
    static func main() {
let soup = UnionSoup(name: "Address Book")
let memory = MemorySoup(name: "Address Book")
let files = FileSoup(filePath: "~/Desktop/AddressBook.soup")
soup.addSoup(files)
soup.addSoup(memory)

memory.soupDescription = "Address Book Example Soup"
_ = memory.createIdentityIndex(ILSoupEntryIdentityUUID)
_ = memory.createIndex(ILSoupEntryAncestorEntryHash)
_ = memory.createIndex(ILSoupEntryDataHash)
_ = memory.createDateIndex(ILSoupEntryCreationDate)
_ = memory.createDateIndex(ILSoupEntryMutationDate)
_ = memory.createTextIndex(name)
_ = memory.createTextIndex(email)
_ = memory.createTextIndex(notes)

func addEntry(_ values: [String: Any]) {
    _ = soup.addEntry(memory.createBlankEntry().mutatedEntry(values))
}

addEntry([
    name: "iStumbler Labs",
    email: "support@istumbler.net",
    url: URL(string: "https://istumbler.net/labs") as Any,
    phone: "415-449-0905"
])
addEntry([name: "John Doe", email: "j.doe@example.com"])
addEntry([name: "Jane Doe", email: "jane.doe@example.com"])

let kimAlias = soup.addEntry(memory.createBlankEntry().mutatedEntry([name: "Kim Gru", email: "kim.g@example.com"]))
let samAlias = soup.addEntry(memory.createBlankEntry().mutatedEntry([name: "Sam Liu", email: "sam.l@example.com"]))
let kimUUID = soup.gotoAlias(kimAlias)?.entryKeys[ILSoupEntryIdentityUUID] as? String
let samUUID = soup.gotoAlias(samAlias)?.entryKeys[ILSoupEntryIdentityUUID] as? String

addEntry([
    name: "Fin Gru-Liu",
    email: "fin.gl@example.com",
    birthday: Date(),
    parents: [kimUUID, samUUID].compactMap { $0 }
])

while let entry = memory.cursor.nextEntry() {
    print("entry: \(entry)")
}

if let index = memory.queryTextIndex(name) {
    let cursor = index.entries(matching: ".* Doe")
    while let entry = cursor.nextEntry() {
        print("doe \(cursor.index): \(entry)")
    }
}
    }
}
