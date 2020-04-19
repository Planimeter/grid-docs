--============ Copyright © 2020, Planimeter, All rights reserved. ============--
--
-- Purpose: Dump list of console commands
--
--============================================================================--

love.filesystem.createDirectory( "docs" )

local markdown = {}
table.insert( markdown, "List of console commands" )
table.insert( markdown, "========================" )
table.insert( markdown, "" )
table.insert( markdown, "| Name | Description |" )
table.insert( markdown, "| ---- | ----------- |" )

local concommands = {}

for name in pairs( concommand._concommands ) do
	table.insert( concommands, name )
end

table.sort( concommands )

for _, name in ipairs( concommands ) do
	local concommand = concommand.getConcommand( name )
	table.insert(
		markdown,
		"| " ..
			name                       .. " | " ..
			concommand:getHelpString() ..
		" |"
	)
end

table.insert( markdown, "" )
markdown = table.concat( markdown, "\r\n" )
love.filesystem.write( "docs/List_of_console_commands.md", markdown )
