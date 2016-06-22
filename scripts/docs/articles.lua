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

local function getFirstLuaFunction( t )
	for _, v in pairs( t ) do
		if ( type( v ) == "function" and
		     not find( tostring( v ), "builtin#%w+" ) ) then
			return v
		end
	end
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

local function r_constructor( article )
	local md = {}
	insert( md, r_header2( "Constructor" ) )
	local modname = isPanel( article ) and "gui" or article
	insert(
		md,
		"* [`" .. ( modname == "gui" and "gui." or "" ) .. article .. "()`]" ..
		"(" .. modname .. "." .. article .. ")"
	)
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function r_methods( article, methods, separator )
	local md = {}
	for _, method in ipairs( methods ) do
		insert(
			md,
			"* [`" .. article .. separator .. method .. "()`]" ..
			"(" .. article .. "." .. method .. ")"
		)
	end
	insert( md, "" )
	return concat( md, "\r\n" )
end

local function writeArticle( article )
	local md = {}
	insert( md, r_header( article ) )

	local v = docs.findModule( article )
	if ( v.__type ) then
		if ( #docs.getClassMethods( v ) > 0 ) then
			insert( md, r_header2( "Class Methods" ) )
			insert( md, r_methods( article, docs.getClassMethods( v ), "." ) )
		end

		insert( md, r_constructor( article ) )

		if ( #docs.getMethods( v ) > 0 ) then
			insert( md, r_header2( "Methods" ) )
			insert( md, r_methods( article, docs.getMethods( v ), ":" ) )
		end

		if ( #docs.getCallbacks( v ) > 0 ) then
			insert( md, r_header2( "Callbacks" ) )
			insert( md, r_methods( article, docs.getCallbacks( v ), ":" ) )
		end
	else
		if ( #docs.getAllMethods( v ) > 0 ) then
			insert( md, r_header2( "Methods" ) )
			insert( md, r_methods( article, docs.getAllMethods( v ), "." ) )
		end

		if ( #docs.getCallbacks( v ) > 0 ) then
			insert( md, r_header2( "Callbacks" ) )
			insert( md, r_methods( article, docs.getCallbacks( v ), "." ) )
		end
	end

	md = concat( md, "\r\n" )
	filesystem.write( "docs/" .. article .. ".md", md )
end

local articles = {}
table.append( articles, docs.getClasses() )
table.append( articles, docs.getInterfacesAndLibraries() )
table.append( articles, docs.getPanels() )

for _, article in ipairs( articles ) do
	writeArticle( article )
end
