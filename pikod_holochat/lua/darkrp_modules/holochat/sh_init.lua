DarkRP.declareChatCommand{
	command = "me",
	description = "Rol yapma komudu.",
	delay = 1
}

local drawList = {}
RoleChat = {}

RoleChat.configuration = {
	generalSize = 0.30,
	fontName = "Arial",
	textSize = 18,
	boxWidthPadding = 5,
	boxHeightPadding = 3,
	locationOffset = 85
}

if CLIENT then
	surface.CreateFont("3DChat", {
		font = RoleChat.configuration.fontName,
		size = RoleChat.configuration.textSize
	})

	local offset = Vector( 0, 0, RoleChat.configuration.locationOffset )

	function tablodaVarmi(tablo, key)
		for k, v in pairs(tablo) do
			if k == key then 
				return true
			end
		end
		return false
	end

	net.Receive("useMeCommand", function()
		local ply = net.ReadEntity() -- NET FUNCTIONS
		local args = net.ReadString()
		if IsValid(ply) and args then
			for k, v in pairs(drawList) do
				if v[1]:AccountID() == ply:AccountID() then
					drawList[k] = nil
				end
			end
			local unique
			repeat
				unique = math.random (1, 999)
			until (not tablodaVarmi(drawList, unique))
			drawList[unique] = {ply, args}
			local index = #drawList
			timer.Simple(6, function()
				for k, v in pairs(drawList) do
					if k == unique then
						print(k)
						drawList[k] = nil
					end
				end
			end)
		end
	end)

	hook.Add("PostDrawOpaqueRenderables", "drawMeChat", function()
		for k, v in pairs(drawList) do
			local ang = LocalPlayer():EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			cam.Start3D2D( v[1]:GetPos() + offset + ang:Up(), Angle( 0, ang.y, 90 ), RoleChat.configuration.generalSize )
				surface.SetFont("3DChat")
				local textWidth, textHeight = surface.GetTextSize(v[2])
				draw.DrawText(v[2], "3DChat", 0, RoleChat.configuration.boxHeightPadding, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				draw.RoundedBox( 2, ((textWidth+(RoleChat.configuration.boxWidthPadding*2))/2)*(-1), 0, textWidth+(RoleChat.configuration.boxWidthPadding*2), textHeight+(RoleChat.configuration.boxHeightPadding*2), Color(0, 0, 0, 150) )
			cam.End3D2D()
		end
	end)
end