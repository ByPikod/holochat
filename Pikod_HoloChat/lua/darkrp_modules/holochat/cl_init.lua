print("Pikod HoloChat activated!")
------------------------------------------

DarkRP.declareChatCommand{
	command = "me",
	description = "Role chat command.",
	delay = 1
}

DarkRP.declareChatCommand{
	command = "status",
	description = "Role chat command.",
	delay = 1
}

------------------------------------------

if SERVER then return end
local meList = {}
local statusList = {}

function isInTheTable(tablo, key)
	for k, v in pairs(tablo) do
		if k == key then 
			return true
		end
	end
	return false
end

------------------------------------------

--> Me Module

------------------------------------------

surface.CreateFont("PIKOD:MeFont", {
	font = HoloChat.Me.FONT,
	size = 24,
	extended = true
})
local meOffset = Vector( 0, 0, HoloChat.Me.LOCATION_OFFSET + 80 )

net.Receive("useMeCommand", function()
	local ply = net.ReadEntity() -- NET FUNCTIONS
	local args = net.ReadString()
	if IsValid(ply) and args then
		for k, v in pairs(meList) do
			if v[1]:AccountID() == ply:AccountID() then
				meList[k] = nil
			end
		end
		local unique
		repeat
			unique = math.random (1, 999)
		until (not isInTheTable(meList, unique))
		meList[unique] = {ply, args}
		local index = #meList
		timer.Simple(6, function()
			for k, v in pairs(meList) do
				if k == unique then
					meList[k] = nil
				end
			end
		end)
	end
end)

hook.Add("PostDrawOpaqueRenderables", "drawMeChat", function()
	for k, v in pairs(meList) do
		local ang = LocalPlayer():EyeAngles()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( v[1]:GetPos() + meOffset + ang:Up(), Angle( 0, ang.y, 90 ), HoloChat.Me.SIZE )
			
			surface.SetFont("PIKOD:MeFont")
			local textWidth, textHeight = surface.GetTextSize(v[2])
			draw.DrawText(v[2], "PIKOD:MeFont", 0, HoloChat.Me.Padding.HEIGHT, HoloChat.Me.TEXT_COLOR, TEXT_ALIGN_CENTER )
			draw.RoundedBox( 2, ((textWidth+(HoloChat.Me.Padding.WIDTH*2))/2)*(-1), 0, textWidth+(HoloChat.Me.Padding.WIDTH*2), textHeight+(HoloChat.Me.Padding.HEIGHT*2), HoloChat.Me.BACKGROUND_COLOR )
			
		cam.End3D2D()
	end
end)

------------------------------------------

--> Status Module

------------------------------------------

surface.CreateFont("PIKOD:StatusFont", {
	font = HoloChat.Status.FONT,
	size = 24,
	extended = true
})

local statusOffset = Vector( 0, 0, HoloChat.Status.LOCATION_OFFSET + 80 )

net.Receive("useStatusCommand", function()
	local ply = net.ReadEntity()
	local args = net.ReadString()
	
	statusList[ply] = args
end)

net.Receive("clearStatusCommand", function()
	local ply = net.ReadEntity()
	statusList[ply] = nil
end)

hook.Add("PostDrawOpaqueRenderables", "drawStatusChat", function()
	for k, v in pairs(statusList) do
		local ang = LocalPlayer():EyeAngles()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( k:GetPos() + statusOffset + ang:Up(), Angle( 0, ang.y, 90 ), HoloChat.Status.SIZE )
			
			surface.SetFont("PIKOD:StatusFont")
			local textWidth, textHeight = surface.GetTextSize(v)
			draw.DrawText(v, "PIKOD:StatusFont", 0, HoloChat.Status.Padding.HEIGHT, HoloChat.Status.TEXT_COLOR, TEXT_ALIGN_CENTER )
			draw.RoundedBox( 2, ((textWidth+(HoloChat.Status.Padding.WIDTH*2))/2)*(-1), 0, textWidth+(HoloChat.Status.Padding.WIDTH*2), textHeight+(HoloChat.Status.Padding.HEIGHT*2), HoloChat.Status.BACKGROUND_COLOR )
			
		cam.End3D2D()
	end
end)

------------------------------------------