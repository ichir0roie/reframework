require("key_enums")

local hwKB = nil
local kbToggleKey = 35 -- (by default END key) lookup the key_enums.lua file to see what number corresponds to what key.

local hwPad = nil
local padToggleBtn = 8192 -- (by default RS/R3 button) lookup the key_enums.lua file to see what number corresponds to what button.

local enableController = false
local enableKeyboard = false
local enabled = false

re.on_pre_application_entry("UpdateBehavior", function() 
    if not hwKB then
        hwKB = sdk.get_managed_singleton("snow.GameKeyboard"):get_field("hardKeyboard")
    end
    if not hwPad then
        hwPad = sdk.get_managed_singleton("snow.Pad"):get_field("hard")
    end
end)

re.on_frame(function()
        if (hwKB:call("getTrg", kbToggleKey) and enableKeyboard) or (hwPad:call("orTrg", padToggleBtn) and enableController) then
			if enabled then
				enabled = false
			else
				enabled = true
			end
		end
end)

re.on_draw_ui(function()
	local changed = false

    if imgui.tree_node("Infinite Wirebugs") then
        changed, enabled = imgui.checkbox("Enabled", enabled)
			if imgui.tree_node("Keybind shortcuts") then
				changed, enableController = imgui.checkbox("Controller (default: [RS/R3])", enableController)
				changed, enableKeyboard = imgui.checkbox("Keyboard (default: [END])", enableKeyboard)
				imgui.tree_pop()
		    end
        imgui.tree_pop()
		imgui.text(' - made by Fylex');
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
end

function on_post_wirebug(retval)
	if enabled then
		local hunter = getCurrentPlayer()
		local basePlayerTypeDef = getType("snow.player.PlayerBase")
		local wirebugGaugeTypeDef = getType("snow.player.PlayerBase.HunterWireGauge")
		
		local wirebugSlot = sdk.get_native_field(hunter, basePlayerTypeDef, "_HunterWireGauge")
		sdk.set_native_field(wirebugSlot[0], wirebugGaugeTypeDef, "_RecastTimer", 0)
		sdk.set_native_field(wirebugSlot[1], wirebugGaugeTypeDef, "_RecastTimer", 0)
		sdk.set_native_field(wirebugSlot[2], wirebugGaugeTypeDef, "_RecastTimer", 0)
	end
    return retval;
end

sdk.hook(sdk.find_type_definition("snow.player.fsm.PlayerFsm2ActionHunterWire"):get_method("start"), on_pre_wirebug, on_post_wirebug)

