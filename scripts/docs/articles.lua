--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Dump articles
--
--============================================================================--

require( "scripts/docs" )

filesystem.createDirectory( "docs" )

local insert = table.insert
local concat = table.concat
local rep    = string.rep
local find   = string.find
local len    = string.len

local function r_header( header )
	local md  = {}
	insert( md, header )
	insert( md, rep( "=", len( header ) ) )
	insert( md, "" )
	return concat( md, "\r\n" )
end

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

local function writeMethods( section, methods, separator )
	for _, method in ipairs( methods ) do
		-- Header
		local md = {}
		local signature = section .. separator .. method
		local constructor = section == method
		if ( constructor ) then
			signature = section
		end
		insert( md, r_header( signature .. "()" ) )

		-- Usage
		insert( md, r_header2( "Usage" ) )
		local v = docs.findModule( section )
		require( "engine.shared.dblib" )
		local params, isvararg = debug.getparameters( v[ method ] )
		if ( params[ 1 ] == "self" ) then
			table.remove( params, 1 )
		end
		local args = ( #params > 0 and "( " ..
			concat( params, ", " ) .. ( isvararg and ", ..." or "" ) ..
		" )" or "()" )
		insert( md, "```lua\r\n" ..
			signature .. args .. "\r\n" ..
		"```" )
		insert( md, "" )

		-- Parameters
		local parameters = {}
		for i, param in ipairs( params ) do
			table.insert( parameters, {
				{ [ "Name" ]        = "`" .. param .. "`" },
				{ [ "Type" ]        = "???" },
				{ [ "Description" ] = "???" }
			} )
		end
		if ( #parameters > 0 ) then
			insert( md, r_header2( "Parameters" ) )
			insert( md, r_table( parameters ) )
		end

		insert( md, "" )
		md = concat( md, "\r\n" )
		filesystem.write( "docs/" .. section .. "." .. method .. ".md", md )
	end
end

local function writeArticles( section )
	local v = docs.findModule( section )
	if ( v.__type ) then
		-- Class Methods
		if ( #docs.getClassMethods( v ) > 0 ) then
			writeMethods( section, docs.getClassMethods( v ), "." )
		end

		-- Constructor
		if ( v[ section ] ) then
			writeMethods( section, { section }, ":" )
		end

		-- Methods
		if ( #docs.getMethods( v ) > 0 ) then
			writeMethods( section, docs.getMethods( v ), ":" )
		end

		-- Callbacks
		if ( #docs.getCallbacks( v ) > 0 ) then
			writeMethods( section, docs.getCallbacks( v ), ":" )
		end
	else
		-- Methods
		if ( #docs.getAllMethods( v ) > 0 ) then
			writeMethods( section, docs.getAllMethods( v ), "." )
		end

		-- Callbacks
		if ( #docs.getCallbacks( v ) > 0 ) then
			writeMethods( section, docs.getCallbacks( v ), "." )
		end
	end
end

local sections = {}
table.append( sections, docs.getClasses() )
table.append( sections, docs.getInterfacesAndLibraries() )
table.append( sections, docs.getPanels() )

for _, section in ipairs( sections ) do
	writeArticles( section )
end
