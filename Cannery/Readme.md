#  <#Title#>

## Features

- Browse any Soup Data Source
    - FileSoup
    
- Display all the `soupIndicies` for a particular soup in an NSOutlineView
    - For each index, show a nested list of entries
    - For each entry, show a nested list of versions
    
- Provide `CRUD` options in the toolbar
    - Create a new entry
    - Remove an entry
    - Update an entry
    - Delete an entry

- Provide persistent Undo & Redo
    - Each element saves it's state
    - Undo history can be purged
    - Unless history has been purged, infinite undo
    - Redo forking: when an entry has 2 older entries:
        - present to the user the two options, hilighting diffs
        - wait for user to determine which path to follow
    
