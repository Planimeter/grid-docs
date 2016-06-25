--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: API Documentation interface
--
--============================================================================--

local debug      = debug
local error      = error
local filesystem = filesystem
local gui        = gui
local ipairs     = ipairs
local pairs      = pairs
local rawtype    = rawtype
local require    = require
local select     = select
local string     = string
local table      = table
local tostring   = tostring
local type       = type
local typeof     = typeof
local _G         = _G

module( "docs" )

callbacks = {
	"keypressed",
	"keyreleased",
	"textinput",
	"textedited",
	"mousemoved",
	"mousepressed",
	"mousereleased",
	"wheelmoved",
	"touchpressed",
	"touchreleased",
	"touchmoved",
	"joystickpressed",
	"joystickreleased",
	"joystickaxis",
	"joystickhat",
	"gamepadpressed",
	"gamepadreleased",
	"gamepadaxis",
	"joystickadded",
	"joystickremoved",
	"focus",
	"mousefocus",
	"visible",
	"quit",
	"threaderror",
	"resize",
	"filedropped",
	"directorydropped",
	"lowmemory",
	"update"
}

function findCallbacks( interface )
	local t = {}
	for k in pairs( interface ) do
		if ( string.find( k, "on[%u%l+]+" ) == 1 ) then
			table.insert( t, k )
		end

		if ( table.hasvalue( callbacks, k ) ) then
			table.insert( t, k )
		end

		if ( k == "callback" ) then
			table.insert( t, k )
		end
	end
	return t
end

function findModule( modname )
	local package = _G[ modname ] or gui[ modname ]
	if ( package ) then return package end

	if ( modname == "http" ) then
		require( "engine.shared.socket.http" )
		return findModule( modname )
	end

	if ( modname == "https" ) then
		require( "engine.shared.socket.https" )
		return findModule( modname )
	end

	if ( modname == "network" ) then
		local client = table.shallowcopy( _G.networkclient )
		local server = table.shallowcopy( _G.networkserver )
		table.merge( client, server )
		return client
	end

	if ( modname == "profile" ) then
		require( "engine.shared.profile" )
		return findModule( modname )
	end

	error( "module '" .. modname .. "' not found", 2 )
end

function getAllMethods( t )
	local methods = {}
	for k, v in pairs( t ) do
		local builtin     = string.find( tostring( v ), "builtin#%w+" )
		local constructor = t.__type == k
		local callback    = table.hasvalue( getCallbacks( t ), k )
		local metamethod  = string.find( k, "__%w+" )
		if ( type( v ) == "function" and
		     not builtin and
		     not constructor and
		     not callback and
		     not metamethod ) then
			table.insert( methods, k )
		end
	end
	table.sort( methods )
	return methods
end

function getCallbacks( ... )
	local args = { ... }
	local callbacks = {}
	for i = 1, select( "#", ... ) do
		table.append( callbacks, findCallbacks( args[ i ] ) )
	end
	table.sort( callbacks )
	return table.unique( callbacks )
end

function getClasses()
	local classes = {}
	local blacklist = {
		"localplayer"
	}
	for k, v in pairs( _G ) do
		if ( rawtype( v ) == "table" and
		     v.__type and
		     not string.find( k, "g_" ) and
		     not string.find( k, "localhost_" ) and
		     not table.hasvalue( blacklist, k ) ) then
			table.insert( classes, k )
		end
	end
	table.sort( classes )
	return classes
end

function isClassMethod( f )
	require( "engine.shared.dblib" )
	local parameters = debug.getparameters( f )
	return not parameters[ 1 ] or parameters[ 1 ] ~= "self"
end

function getClassMethods( class )
	local classMethods = {}
	local methods = getAllMethods( class )
	for _, method in ipairs( methods ) do
		if ( isClassMethod( class[ method ] ) ) then
			table.insert( classMethods, method )
		end
	end
	return classMethods
end

function getInterfacesAndLibraries()
	local packages = {}
	local blacklist = {
		"clientengine",
		"serverengine",
		"networkclient",
		"networkserver",
		"gameclient",
		"gameserver",
		"docs",
		"game"
	}
	for k, v in pairs( _G ) do
		if ( rawtype( v ) == "table" and
		     v._M and
		     not table.hasvalue( blacklist, k ) ) then
			table.insert( packages, k )
		end
	end

	-- network interface
	table.insert( packages, "network" )

	-- socket interfaces
	table.insert( packages, "http" )
	table.insert( packages, "https" )

	-- Lua 5.1.5 base library extensions
	table.insert( packages, "math" )
	table.insert( packages, "os" )
	table.insert( packages, "string" )
	table.insert( packages, "table" )

	-- profiling interface
	table.insert( packages, "profile" )

	table.sort( packages )
	return table.unique( packages )
end

function getMethods( t )
	local methods = {}
	local m = getAllMethods( t )
	local classMethods = getClassMethods( t )
	for _, method in ipairs( m ) do
		if ( not table.hasvalue( classMethods, method ) ) then
			table.insert( methods, method )
		end
	end
	return methods
end

function isPanel( modname )
	local v = findModule( modname )
	return typeof( v, "panel" ) or v == gui.panel
end

function getPanels()
	local panels = {}
	local blacklist = {
		"console",
		"debugoverlaypanel",
		"init",
		"optionsmenu",
		"scheme",
		"testframe"
	}
	local files = filesystem.getDirectoryItems( "engine/client/gui" )
	for _, panel in ipairs( files ) do
		local extension = "%." .. ( string.fileextension( panel ) or "" )
		panel = string.gsub( panel, extension, "" )
		if ( not string.find( panel, "^hud%a+" ) and
		     not table.hasvalue( blacklist, panel ) ) then
			table.insert( panels, panel )
		end
	end
	table.sort( panels )
	return panels
end
