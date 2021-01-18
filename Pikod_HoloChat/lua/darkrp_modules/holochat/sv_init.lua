util.AddNetworkString( "useMeCommand" )
util.AddNetworkString( "useStatusCommand" )
util.AddNetworkString( "clearStatusCommand" )

local function meCmd(ply, args)
	if not HoloChat.Me.ENABLED then return end
	if args == "" then return end
	net.Start( "useMeCommand" )
	net.WriteEntity( ply )
	net.WriteString( args )
	net.Broadcast()
end

local function statusCmd(ply, args)
	if not HoloChat.Status.ENABLED then return end
	local words = string.Split( args, " " )
	if not words[2] then 
		net.Start( "clearStatusCommand" )
		net.WriteEntity(ply)
		net.Broadcast()
		return
	end
	net.Start( "useStatusCommand" )
	net.WriteEntity( ply )
	net.WriteString( args )
	net.Broadcast()
end

if HoloChat.Me.ENABLED then DarkRP.defineChatCommand("me", meCmd) end
if HoloChat.Status.ENABLED then DarkRP.defineChatCommand("status", statusCmd) end