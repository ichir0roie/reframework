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

function on_pre_wirebug(args)
	local hunter = getCurrentPlayer()
	local userDataType = getType("snow.player.PlayerUserDataCommon")
	local userDateComon=sdk.get_native_singleton("snow.player.PlayerUserDataCommon")
	print("test")
	dump(hunter)
	dump(userDateComon)

               

	-- sdk.set_native_field(hunter, userDataType, "_HunterWireJumpHighSpeed", 0)
	-- sdk.set_native_field(hunter, userDataType, "_HunterWireJumpLowSpeed", 0)
	-- sdk.set_native_field(hunter, userDataType, "_HunterWireJumpLowFlySpeed", 0)
	-- sdk.set_native_field(hunter, userDataType, "_HunterWireJumpTargetFlySpeed", 0)
end
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return print(s .. '} ')
    else
        return print(o)
    end
end

function on_post_wirebug(retval)
end

sdk.hook(sdk.find_type_definition("snow.player.fsm.PlayerFsm2ActionHunterWire"):get_method("start"), on_pre_wirebug, on_post_wirebug)

