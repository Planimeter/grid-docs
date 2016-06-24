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

local function writeMethods( section, methods, separator )
	for _, method in ipairs( methods ) do
		local md = {}
		local header = section .. separator .. method
		local constructor = section == method
		if ( constructor ) then
			header = section
		end
		insert( md, r_header( header .. "()" ) )

		insert( md, r_header2( "Parameters" ) )

		insert(
			md,
			"* [`" .. section .. separator .. method .. "()`]" ..
			"(" .. section .. "." .. method .. ")"
		)

		insert( md, "" )
		md = concat( md, "\r\n" )
		filesystem.write( "docs/" .. section .. "." method .. ".md", md )
	end
end

local function writeArticles( section )
	local v = docs.findModule( section )
	if ( v.__type ) then
		-- Class Methods
		if ( #docs.getClassMethods( v ) > 0 ) then
			writeMethods( section, docs.getClassMethods( v ), "." ) )
		end

		r_constructor( section )

		-- Methods
		if ( #docs.getMethods( v ) > 0 ) then
			writeMethods( section, docs.getMethods( v ), ":" ) )
		end

		-- Callbacks
		if ( #docs.getCallbacks( v ) > 0 ) then
			writeMethods( section, docs.getCallbacks( v ), ":" ) )
		end
	else
		-- Methods
		if ( #docs.getAllMethods( v ) > 0 ) then
			writeMethods( section, docs.getAllMethods( v ), "." ) )
		end

		-- Callbacks
		if ( #docs.getCallbacks( v ) > 0 ) then
			writeMethods( section, docs.getCallbacks( v ), "." ) )
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
