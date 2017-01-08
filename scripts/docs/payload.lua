--============ Copyright © 2017, Planimeter, All rights reserved. ============--
--
-- Purpose: Dump list of payloads
--
--============================================================================--

filesystem.createDirectory( "docs" )

local insert = table.insert
local sort   = table.sort
local len    = string.len
local rep    = string.rep
local concat = table.concat

local md = {}
insert( md, "List of payloads" )
insert( md, "================" )
insert( md, "" )

local payloads = {}

for name in pairs( payload.structs ) do
	insert( payloads, name )
end

sort( payloads )

local function r_header2( header )
	local md = {}
	insert( md, header )
	insert( md, rep( "-", len( header ) ) )
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function r_thead( keys )
	local th = {}
	local border = {}
	insert( th, "| " )
	insert( border, "| " )
	for i, k in ipairs( keys ) do
		local space = ( i ~= #keys and " " or "" )
		insert( th, k .. " |" .. space )
		insert( border, rep( "-", len( k ) ) .. " |" .. space )
	end
	th = concat( th ) .. "\r\n"
	border = concat( border )
	return th .. border
end

local function r_table( t )
	local md = {}
	local keys = {}
	for _, k in ipairs( t ) do
		for i, u in ipairs( k ) do
			for key in pairs( u ) do
				keys[ i ] = key
			end
		end
	end
	insert( md, r_thead( keys ) )

	for _, k in ipairs( t ) do
		local values = {}
		insert( values, "| " )
		for i, v in ipairs( k ) do
			local space = ( i ~= #k and " " or "" )
			insert( values, v[ keys[ i ] ] .. " |" .. space )
		end
		insert( md, concat( values ) )
	end

	insert( md, "" )
	return concat( md, "\r\n" )
end

for _, name in ipairs( payloads ) do
	local keys = payload.structs[ name ].keys
	local payloads = {}
	for i, key in ipairs( keys ) do
		table.insert( payloads, {
			{ [ "Name" ] = "`" .. key.name .. "`" },
			{ [ "Type" ] = "`" .. key.type .. "`" }
		} )
	end
	insert( md, r_header2( name ) )
	insert( md, r_table( payloads ) )
end

md = concat( md, "\r\n" )
filesystem.write( "docs/List_of_payloads.md", md )
