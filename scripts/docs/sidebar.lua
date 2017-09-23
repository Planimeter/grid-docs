--============ Copyright © 2017, Planimeter, All rights reserved. ============--
--
-- Purpose: Dump sidebar
--
--============================================================================--

require( "scripts/docs" )

love.filesystem.createDirectory( "docs" )

local function renderSidebarSection( header, list )
	local markdown = {}
	table.insert( markdown, "**" .. header .. "**" )
	table.insert( markdown, "" )
	for _, item in ipairs( list ) do
		table.insert( markdown, "* [" .. item .. "](" .. item .. ")" )
	end
	table.insert( markdown, "" )
	return table.concat( markdown, "\r\n" )
end

local markdown = {}
table.insert( markdown, renderSidebarSection(
	"Callbacks",
	docs.getCallbacks(
		game.client,
		game.server,
		game
	)
) )

table.insert( markdown, renderSidebarSection(
	"Classes",
	docs.getClasses()
) )

table.insert( markdown, renderSidebarSection(
	"Interfaces and Libraries",
	docs.getInterfacesAndLibraries()
) )

table.insert( markdown, renderSidebarSection(
	"Panels",
	docs.getPanels()
) )

markdown = table.concat( markdown, "\r\n" )
love.filesystem.write( "docs/_Sidebar.md", markdown )
