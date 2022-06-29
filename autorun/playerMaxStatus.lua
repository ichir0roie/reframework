require("key_enums")

local hwKB = nil
local kbToggleKey = 35 -- (by default END key) lookup the key_enums.lua file to see what number corresponds to what key.

local hwPad = nil
local padToggleBtn = 8192 -- (by default RS/R3 button) lookup the key_enums.lua file to see what number corresponds to what button.

local enableController = false
local enableKeyboard = false
local enabled = true

local font = d2d.Font.new("Arial", 20, false)

re.on_draw_ui(function()
	local changed = false

    if imgui.tree_node("Player Max Status") then
        changed, enabled = imgui.checkbox("Enabled", enabled)
        imgui.tree_pop()
    end
end)


function getType(name)
	return sdk.find_type_definition(name)
end

function getSingletonData(name)
	return { sdk.get_managed_singleton(name), getType(name) }
end

function getSingletonField(singleton, name)
	local singletonRef, typedef = table.unpack(singleton)
	return sdk.get_native_field(singletonRef, typedef, name)
end

function getCurrentPlayer()
	local inputManager = getSingletonData("snow.StmInputManager")
	local inGameInputDevice = getSingletonField(inputManager, "_InGameInputDevice")
	local playerInput = sdk.get_native_field(inGameInputDevice, getType("snow.StmInputManager.InGameInputDevice"), "_pl_input")
	local weapon = sdk.get_native_field(playerInput, getType("snow.StmPlayerInput"), "RefPlayer")
	return weapon
end

function on_pre(args)
end

hunter = getCurrentPlayer()
basePlayerTypeDef = getType("snow.player.PlayerBase")

targetTypeDef = getType("snow.player.PlayerData")
-- local playerData=sdk.get_native_field(hunter,targetTypeDef,"_refPlayerData")
playerData=hunter:get_field("_refPlayerData")

function on_post_update(retval)
	playerData:set_field("_Attack",1500)
	playerData:set_field("_Defence",750)
end

function on_post_vital(retval)
	print('vital')
	playerData:set_field("_stamina",5700)
	playerData:set_field("_staminaMax",5700)
	playerData:set_field("_vitalMax",150)
	playerData:set_field("_vitalKeep",150)
	playerData:set_field("_r_Vital",150)
	-- hunter:set_field("_AdjustPlayerPositionSpd",10)

end

sdk.hook(sdk.find_type_definition("snow.player.PlayerBase"):get_method("update"), on_pre, on_post_update)
sdk.hook(sdk.find_type_definition("snow.player.PlayerData"):get_method("set__vital"), on_pre, on_post_vital)

