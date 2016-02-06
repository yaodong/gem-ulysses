# ulysses.rb

This is a library to export your to HTML files. It still in development.

## Examples

Get your library:

    library = Ulysses::Library.new
    
Get groups from library

    groups = library.groups
    
Get children groups:

    group = library.groups.first
    children = group.children
    
Get Sheets:

    group.sheets
    
Export sheet to HTML:

    sheet = group.sheets.first
    html  = sheet.to_html
