--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Dump sections
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
	local len = len( header )
	local v   = docs.findModule( header )
	if ( v.__base ) then
		local base = v.__base
		header = header .. " " ..
		"<small>" ..
			"_Inherits from [`" .. base .. "`](" .. base .. ")_" ..
		"</small>"
	end
	insert( md, header )
	insert( md, rep( "=", len ) )
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function getFirstLuaFunction( t )
	for _, v in pairs( t ) do
		if ( type( v ) == "function" and
		     not find( tostring( v ), "builtin#%w+" ) ) then
			return v
		end
	end
end

local function r_purpose( section )
	-- HACKHACK: Unify network purpose description.
	if ( section == "network" ) then
		return "Network interface"
	end

	local v = docs.findModule( section )
	if ( v.__type ) then
		if ( not v[ section ] ) then
			v = getFirstLuaFunction( v )
		else
			v = v[ section ]
		end
	else
		v = getFirstLuaFunction( v )
	end

	local src = debug.getinfo( v, "S" ).short_src
	src = filesystem.read( src )
	local _, _, purpose = find( src, "-- Purpose:%s(.-\r\n)" )
	return purpose
end

local function r_header2( header )
	local md = {}
	insert( md, header )
	insert( md, rep( "-", len( header ) ) )
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function isPanel( module )
	local v = docs.findModule( module )
	return typeof( v, "panel" ) or v == gui.panel
end

local function r_constructor( section )
	local md = {}
	insert( md, r_header2( "Constructor" ) )
	local modname = isPanel( section ) and "gui" or section
	insert(
		md,
		"* [`" .. ( modname == "gui" and "gui." or "" ) .. section .. "()`]" ..
		"(" .. modname .. "." .. section .. ")"
	)
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function r_methods( section, methods, separator )
	local md = {}
	for _, method in ipairs( methods ) do
		insert(
			md,
			"* [`" .. section .. separator .. method .. "()`]" ..
			"(" .. section .. "." .. method .. ")"
		)
	end
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function writeSection( section )
	local md = {}
	insert( md, r_header( section ) )
	insert( md, r_purpose( section ) )

	local v = docs.findModule( section )
	if ( v.__type ) then
		if ( #docs.getClassMethods( v ) > 0 ) then
			insert( md, r_header2( "Class Methods" ) )
			insert( md, r_methods( section, docs.getClassMethods( v ), "." ) )
		end

		insert( md, r_constructor( section ) )

		if ( #docs.getMethods( v ) > 0 ) then
			insert( md, r_header2( "Methods" ) )
			insert( md, r_methods( section, docs.getMethods( v ), ":" ) )
		end

		if ( #docs.getCallbacks( v ) > 0 ) then
			insert( md, r_header2( "Callbacks" ) )
			insert( md, r_methods( section, docs.getCallbacks( v ), ":" ) )
		end
	else
		if ( #docs.getAllMethods( v ) > 0 ) then
			insert( md, r_header2( "Methods" ) )
			insert( md, r_methods( section, docs.getAllMethods( v ), "." ) )
		end

		if ( #docs.getCallbacks( v ) > 0 ) then
			insert( md, r_header2( "Callbacks" ) )
			insert( md, r_methods( section, docs.getCallbacks( v ), "." ) )
		end
	end

	md = concat( md, "\r\n" )
	filesystem.write( "docs/" .. section .. ".md", md )
end

local sections = {}
table.append( sections, docs.getClasses() )
table.append( sections, docs.getInterfacesAndLibraries() )
table.append( sections, docs.getPanels() )

for _, section in ipairs( sections ) do
	writeSection( section )
end
