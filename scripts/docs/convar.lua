--============ Copyright © 2019, Planimeter, All rights reserved. ============--
--
-- Purpose: Dump list of console variables
--
--============================================================================--

love.filesystem.createDirectory( "docs" )

local markdown = {}
table.insert( markdown, "List of console variables" )
table.insert( markdown, "=========================" )
table.insert( markdown, "" )
table.insert( markdown, "| Name | Default | Min | Max | Description |" )
table.insert( markdown, "| ---- | ------- | --- | --- | ----------- |" )

local convars = {}

for name in pairs( convar._convars ) do
	table.insert( convars, name )
end

table.sort( convars )

local function tocell( v )
	local s = tostring( v )
	return s ~= "nil" and s or ""
end

for _, name in ipairs( convars ) do
	local convar = convar.getConvar( name )
	table.insert(
		markdown,
		"| " ..
			name                      .. " | " ..
			convar:getDefault()       .. " | "..
			tocell( convar:getMin() ) .. " | " ..
			tocell( convar:getMax() ) .. " | " ..
			( convar:getHelpString() or "" ) ..
		" |"
	)
end

table.insert( markdown, "" )
markdown = table.concat( markdown, "\r\n" )
love.filesystem.write( "docs/List_of_console_variables.md", markdown )
