util.AddNetworkString( "useMeCommand" )

local function meCmd(ply, args)
	if args == "" then return "" end
	net.Start( "useMeCommand" )
	net.WriteEntity( ply )
	net.WriteString( args )
	net.Broadcast()
end

DarkRP.defineChatCommand("me", meCmd)