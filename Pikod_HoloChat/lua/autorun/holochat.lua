--[[

		 HoloChat
	Programmed by Pikod

]]--

PI_HOLO = {}
local system = PI_HOLO -- Creation of shortcut

-- Log functions
local log_side_color = Color(64, 203, 245)
if CLIENT then 
	log_side_color = Color(252, 223, 3)
end

function system:Info(msg)
	MsgC( Color( 78, 230, 93 ), "HoloChat (Info) > ", log_side_color, msg.."\n" )
end

function system:Warn(msg)
	MsgC( Color( 227, 45, 61 ), "HoloChat (Warn) > ", log_side_color, msg.."\n" )
end

function system:Error(msg)
	error("HoloChat Error -> "..msg, 1)
end

-- Configuration functions
function system:AddModule(command, module)
	-- Check required params
	if not command then self:Error("Undefined module command name", 1) end
	if string.len(command) > 32 then self:Error("Very long command name (max 32).") end
	if string.len(command) < 1 then self:Error("Empty command name") end
	if not module then self:Error("Undefined module table") end

	command = command:lower()

	-- Optional params
	module.DisplayLength = (module.DisplayLength or 5) -- seconds
	module.IsConstant = (module.IsConstant or false)
	
	-- Display settings
	module.Display = (module.Display or {})
	module.Display.Font = (module.Display.Font or "default")
	module.Display.BackgroundPaddingWidth = (module.Display.BackgroundPaddingWidth or 256)
	module.Display.BackgroundPaddingHeight = (module.Display.BackgroundPaddingHeight or 64)
	module.Display.BackgroundColor = (module.Display.BackgroundColor or Color(0, 0, 0, 200))
	module.Display.TextColor = (module.Display.TextColor or Color(255, 255, 255))
	module.Display.TextFormat = (module.Display.TextFormat or "%1%")

	module.TimeForAnimation = {}
	module.TimeForAnimation["fadeIn"] = module.DisplayLength / 6 -- 1/6 for fade in
	module.TimeForAnimation["fadeOut"] = module.DisplayLength / 6 -- 1/6 for fade out
	module.TimeForAnimation["slideOut"] = module.DisplayLength / 8 -- 1/20 for slide
	
	-- Insertion
	self.modules[command] = module
end

-- Properties, settings etc.
function system:SetProperty(key, value)
	self.properties[key] = value
end

-- Translate language
function system:SetWord(key, value)
	self.language[key] = value
end

function system:CreateFont(name, family)
	if SERVER then return end
	surface.CreateFont("pi_holo:"..name, {
		font = family,
		extended = true,
		size = 256
	})
end

function system:ClearConfig()
	-- Default modules
	self.modules = {}
	-- self:AddModule("me", {})

	-- Default properties
	self.properties = {}
	self:SetProperty("prefix", "/")
	self:SetProperty("cooldown", 0.5) -- you probably won't feel the cooldown but it's enough for spammers.

	-- Default language
	self.language = {}
	self:SetWord("cooldown_error", "You cannot use it again for %1% seconds.")
	self:SetWord("parameter_error", "You have to write your message after command.")

	-- Default font
	self:CreateFont("default", "Arial")
end

system:ClearConfig() -- Load default properties


-- Server side
if SERVER then
	-- Variables
	system.cooldowns = {}

	-- Includes
	AddCSLuaFile("holo_config.lua")
	include("holo_config.lua")

	-- Network string
	util.AddNetworkString("pi_holo:holo_message_broadcast")
	util.AddNetworkString("pi_holo:holo_constant_disable")
	util.AddNetworkString("pi_holo:notification")

	-- Functions
	function system:SendNotify(ply, type, message, length)
		length = (length or 3)
		net.Start("pi_holo:notification")
			net.WriteInt(type, 4)
			net.WriteString(message)
			net.WriteInt(length, 5)
		net.Send(ply)
	end


	local function onCommand(ply, text, teamchat)
		print(text)

		if teamchat then return end
		if not IsValid(ply) then return end -- player check

		local text = text:lower() -- for no case sensivity

		for key, value in pairs(system.modules) do
			
			local commandString = system.properties["prefix"]..key
			if not (string.sub(text, 0, string.len(commandString)) == commandString) then continue end -- continue to loop if command not matches

			-- Command matches
			if system.cooldowns[ply] and system.cooldowns[ply] > CurTime() then -- check is player in cooldown
			
				system:SendNotify(ply, 1, string.Replace(system.language["cooldown_error"], "%1%", math.floor(system.cooldowns[ply] - CurTime()) + 1), 3)
				return ""
			
			end

			system.cooldowns[ply] = CurTime() + system.properties["cooldown"] -- set cooldown
			
			local cmdStartLength = string.len(commandString)+2

			if not value.IsConstant then

				if string.len(text) <= cmdStartLength then
					system:SendNotify(ply, 1, system.language["parameter_error"], 3)
					return ""
				end

				local message = string.sub(text, cmdStartLength) 
				net.Start("pi_holo:holo_message_broadcast")
					net.WriteString(key)
					net.WriteEntity(ply) -- who use command
					net.WriteString(message) -- message
				net.Broadcast()

			else

				if string.len(text) <= cmdStartLength then

					net.Start("pi_holo:holo_constant_disable")
						net.WriteString(key)
						net.WriteEntity(ply) -- who use command
					net.Broadcast()

				else

					local message = string.sub(text, cmdStartLength) 
					net.Start("pi_holo:holo_message_broadcast")
						net.WriteString(key)
						net.WriteEntity(ply) -- who use command
						net.WriteString(message) -- message
					net.Broadcast()

				end

			end

			return "" -- remove chat message
		end
	end

	-- Hooks
	hook.Add("PlayerSay", "pi_holo:commands", onCommand)
end

-- Client side
if CLIENT then
	include("holo_config.lua")
	system.holoList = {}
	system.fonts = {}

	-- Functions
	net.Receive("pi_holo:notification", function()

		local type = net.ReadInt(4)
		local message = net.ReadString()
		local length = net.ReadInt(5)
		notification.AddLegacy(message, type, length)

	end)

	net.Receive("pi_holo:holo_message_broadcast", function()

		local command = net.ReadString()
		local entity = net.ReadEntity()
		local message = net.ReadString()
		if not IsValid(entity) then return end

		local module = system.modules[command]

		system.holoList[entity] = (system.holoList[entity] or {})
		table.insert(system.holoList[entity], {
			["Appear"] = CurTime(),
			["Disappear"] = (CurTime() + module.DisplayLength),
			["TimeForAnimation"] = module.TimeForAnimation,
			["Display"] = module.Display,
			["DisplayLength"] = module.DisplayLength,
			["IsConstant"] = module.IsConstant,
			["Message"] = message,
			["Command"] = command
		})

	end)

	net.Receive("pi_holo:holo_constant_disable", function()

		local command = net.ReadString()
		local entity = net.ReadEntity()
		if not IsValid(entity) then return end

		for k,v in pairs(system.holoList) do
			if not (k == entity) then continue end
			for k1,v1 in pairs(v) do
				if v1.Command == command then

					v1.IsConstant = false

					if v1.TimeForAnimation["fadeOut"] > v1.TimeForAnimation["slideOut"] then
						v1.Disappear = CurTime() + v1.TimeForAnimation["fadeOut"]
					else
						v1.Disappear = CurTime() + v1.TimeForAnimation["slideOut"]
					end
					return

				end
			end
		end

	end)

	-- Holographic pm offset
	local offset = Vector(0, 0, 75)

	-- Draw function
	local function DrawHolo()
		local ang = LocalPlayer():EyeAngles()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		local removes = {} -- remove list
		
		for k, v in pairs(system.holoList) do -- loop entities
			
			if not IsValid(k) or not v then
				continue
			end
			
			-- sorting messages by correct queue
			local sortedList = {}
			for i = #v, 1, -1 do 
				table.insert(sortedList, v[i])
			end


			-- loop offset variables
			local messageOffset = 0

			-- loop messages of entity
			for key, value in pairs(sortedList) do 
				-- animation calculation variables
				local timeLeft = value.Disappear - CurTime()
				local timePassed = (value.DisplayLength - timeLeft)
				local leftTimeForAnimationFadeIn = (timePassed - value.TimeForAnimation["fadeIn"]) * -1
				local leftTimeForAnimationFadeOut = (timeLeft - value.TimeForAnimation["fadeOut"]) * -1
				local leftTimeForAnimationSlideOut = (timeLeft - value.TimeForAnimation["slideOut"]) * -1

				
				-- Is disappeared
				if value.IsConstant or timeLeft >= 0 then
					cam.Start3D2D( k:GetPos() + offset + ang:Up(), Angle( 0, ang.y, 90 ), 0.03 )
						
						-- default animation variables
						local alpha = 255
						local offset = 0
						value.Offset = (value.Offset or 0)

						-- in animations
						if leftTimeForAnimationSlideOut > 0 and not value.IsConstant then
							offset = 0 - (leftTimeForAnimationSlideOut * (200 / value.TimeForAnimation["fadeOut"])) 
						end

						-- out animations
						if leftTimeForAnimationFadeIn > 0 then 
							alpha = 255 - (leftTimeForAnimationFadeIn * (255 / value.TimeForAnimation["fadeIn"])) 
						elseif leftTimeForAnimationFadeOut > 0 and not value.IsConstant then
							alpha = 255 - (leftTimeForAnimationFadeOut * (255 / value.TimeForAnimation["fadeOut"])) 
						end

						-- calculating box size
						local str = string.Replace(value.Display.TextFormat, "%1%", value.Message)
						surface.SetFont("pi_holo:"..value.Display.Font)
						local tw, th = surface.GetTextSize(str)

						-- offset prepare
						messageOffset = messageOffset - (th + value.Display.BackgroundPaddingHeight) - 40 -- update new offset
						value.Offset = Lerp( 5 * FrameTime(), value.Offset, messageOffset );

						-- box and text draw
						local box_x = 0 - (tw / 2) - (value.Display.BackgroundPaddingWidth / 2)
						local box_y = value.Offset + offset - (value.Display.BackgroundPaddingHeight / 2)
						local box_w = tw + value.Display.BackgroundPaddingWidth
						local box_h = th + value.Display.BackgroundPaddingHeight
						
						-- radius variables
						local radius = 10
						local b1 = true
						local b2 = true
						local b3 = true
						local b4 = true


						-- make it special shape if key is "1"
						if key == 1 then
							radius = 50
							b1 = true
							b2 = true
							b3 = false
							b4 = false
						end

						draw.RoundedBoxEx(radius, box_x, box_y, box_w, box_h, Color(value.Display.BackgroundColor.r, value.Display.BackgroundColor.g, value.Display.BackgroundColor.b, math.Clamp(alpha, 0, value.Display.BackgroundColor.a)), b1, b2, b3, b4)
						draw.DrawText(str, "pi_holo:"..value.Display.Font, 0, value.Offset + offset, Color( value.Display.TextColor.r, value.Display.TextColor.g, value.Display.TextColor.b, alpha ), TEXT_ALIGN_CENTER)
					
						-- ballon effect
						if key == 1 then
							local triangle = {
								{ x = box_x + (box_w / 2) - 150, y = (box_y + box_h) },
								{ x = box_x + (box_w / 2) + 150, y = (box_y + box_h) },
								{ x = box_x + (box_w / 2), y = (box_y + box_h + 80) }
							}
							surface.SetDrawColor( value.Display.BackgroundColor.r, value.Display.BackgroundColor.g, value.Display.BackgroundColor.b, math.Clamp(alpha, 0, value.Display.BackgroundColor.a) )
							draw.NoTexture()
							surface.DrawPoly( triangle )
						end
					cam.End3D2D()
				else
					table.insert(removes, {
						["removeFrom"] = v,
						["removeTo"] = value
					})
				end
				
			end
			

			-- Removing disappeared messages
			for k,v in pairs(removes) do
				table.RemoveByValue(v["removeFrom"], v["removeTo"])
			end

		end
	end

	-- Hooks
	hook.Add("PostDrawOpaqueRenderables", "drawMeChat", DrawHolo)
end

system:Info("Enabled")