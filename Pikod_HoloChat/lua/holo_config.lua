--[[
		 HoloChat
	Programmed by Pikod
	
	If you going to use
	this addon in your
	server please add
	  your workshop
	   collection.

	  Thx for using...
]]--

PI_HOLO:ClearConfig()

--[[

* Section: Modules
You can add command module (me, do, status etc.)

PI_HOLO:AddModule("me", {
	["DisplayLength"] = 5, -- Display length defines message how many seconds after will be disappear
	["IsConstant"] = false, -- If is command constant it will not disappear until you use command again (Without parameters.)
	["Display"] = {
		["Font"] = "default", -- You can change this with your fonts after add your font with CreateFont function
		["BackgroundPaddingWidth"] = 256, -- Space from right and left
		["BackgroundPaddingHeight"] = 64, -- Space from top and bottom
		["BackgroundColor"] = Color(0, 0, 0, 200), -- Background color
		["TextColor"] = Color(255, 255, 255), -- Text color (don't support alpha)
		["TextFormat"] = "%1%" -- Word %1% will be changed with player input.
	}
})

]]--

PI_HOLO:AddModule("me", {
	["DisplayLength"] = 5,
	["IsConstant"] = false,
	["Display"] = {
		["Font"] = "default",
		["BackgroundPaddingWidth"] = 256,
		["BackgroundPaddingHeight"] = 64,
		["BackgroundColor"] = Color(0, 0, 0, 200),
		["TextColor"] = Color(245, 34, 59),
		["TextFormat"] = "%1%"
	}
})

PI_HOLO:AddModule("do", {
	["DisplayLength"] = 5,
	["IsConstant"] = false,
	["Display"] = {
		["Font"] = "default",
		["BackgroundPaddingWidth"] = 256,
		["BackgroundPaddingHeight"] = 64,
		["BackgroundColor"] = Color(0, 0, 0, 200),
		["TextColor"] = Color(61, 204, 45),
		["TextFormat"] = "%1%"
	}
})

PI_HOLO:AddModule("status", {
	["DisplayLength"] = 5,
	["IsConstant"] = true,
	["Display"] = {
		["Font"] = "default",
		["BackgroundPaddingWidth"] = 256,
		["BackgroundPaddingHeight"] = 64,
		["BackgroundColor"] = Color(4, 0, 89, 200),
		["TextColor"] = Color(255, 255, 255),
		["TextFormat"] = "* %1% *"
	}
})

--[[

* Section: Properties  

Simple properties

--]]

PI_HOLO:SetProperty("prefix", "/") -- Commands prefix (/me, !me etc.)
PI_HOLO:SetProperty("cooldown", 0.5) -- Command use cooldown (recommended: 0.5)

--[[

* Section: Language  

for English:

PI_HOLO:SetWord("cooldown_error", "You cannot use it again for %1% seconds.")
PI_HOLO:SetWord("parameter_error", "You have to write your message after command.")

--]]

PI_HOLO:SetWord("cooldown_error", "Bu komutu tekrar kullanmak için %1% saniye beklemelisin.")
PI_HOLO:SetWord("parameter_error", "Komuttan sonra bir mesaj yazman gerek.")


--[[

* Section: Fonts

You can create fonts like example located below

--]]

PI_HOLO:CreateFont("default", "Arial")