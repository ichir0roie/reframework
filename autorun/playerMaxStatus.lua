require("key_enums")

local hwKB = nil
local kbToggleKey = 35 -- (by default END key) lookup the key_enums.lua file to see what number corresponds to what key.

local hwPad = nil
local padToggleBtn = 8192 -- (by default RS/R3 button) lookup the key_enums.lua file to see what number corresponds to what button.

local enableController = false
local enableKeyboard = false
local enabled = true

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
	-- local inputManager = getSingletonData("snow.StmInputManager")
	-- local inGameInputDevice = getSingletonField(inputManager, "_InGameInputDevice")
	-- local playerInput = sdk.get_native_field(inGameInputDevice, getType("snow.StmInputManager.InGameInputDevice"), "_pl_input")
	-- local weapon = sdk.get_native_field(playerInput, getType("snow.StmPlayerInput"), "RefPlayer")
	-- return weapon

	local playerManager=sdk.get_managed_singleton('snow.player.PlayerManager')
	local playerList=playerManager:get_field('PlayerList')
	return playerList[0]
end

local hunter=nil

function setup_hunter()
	print("setup hunter")
	hunter=getCurrentPlayer()
	
end

function on_post_update(r)
	if hunter ==nil then
		print("hunter is nil.")
		setup_hunter()
		return false
	end

	local playerData=hunter:get_field("_refPlayerData")
	
	playerData:set_field("_Attack",1000)
	playerData:set_field("_Defence",50)
	-- return r
end

local test_done=true

function on_post_vital(r)

	if test_done == false then
		test()
		test_done=true
		print(test_done)
	end

	if hunter ==nil then
		print("hunter is nil.")
		setup_hunter()
		return false
	end

	local playerData=hunter:get_field("_refPlayerData")
	playerData:set_field("_stamina",5700)
	playerData:set_field("_staminaMax",5700)
	playerData:set_field("_vitalMax",150)
	playerData:set_field("_vitalKeep",150)
	playerData:set_field("_r_Vital",150)
	-- return r
end

function test()
	print("test")
	if hunter ==nil then
		print("hunter is nil.")
		setup_hunter()
		return false
	end
	local playerData=hunter:get_field("_refPlayerData")
	print(playerData)
	override_skill()
end

function view_info(o)
	if o == nil then
		print('nil')
		return
	end
	local typeDef=o:get_type_definition()
	print(typeDef)
	for i,m in ipairs(typeDef:get_fields()) do
		print(tostring(i).." : "..m:get_name())
	end
	-- for i=0,o:get_reference_count()-1,1 do
	-- 	print(o:get_field(i))
	-- end
end

function setup_wire()
	if hunter ==nil then
		print("hunter is nil.")
		return false
	end
	-- local playerData=sdk.get_native_field(hunter,targetTypeDef,"_refPlayerData")

	local playerCommon=hunter:get_field("_PlayerUserDataCommon")
	-- wire -> playeruserdatacommon

	local speed=2
	playerCommon:set_field('_HunterWireJumpHighSpeed',5)
	playerCommon:set_field('_HunterWireJumpHighFlySpeed',speed)
	playerCommon:set_field('_HunterWireJumpJumpLowSpeed',speed)
	playerCommon:set_field('_HunterWireJumpLowFlySpeed',speed)
	-- playerCommon:set_field('_HunterWireJumpTargetSpeed',--speed)
	playerCommon:set_field('_HunterWireJumpTargetFlySpeed',speed)
	-- playerCommon:set_field('_LongJumpSpeed',speed)
	print('set wire')

	return true
end

local data=nil
function data_update()
	if data == nil then
		data=sdk.get_managed_singleton("snow.data.DataManager")
	end
	if data==nil then
		return 
	end
	local money=data:get_field("_HandMoney")
	money:set_field("_Value",90000000)
	return 
end

function override_skill()
	
	if hunter ==nil then
		print("hunter is nil.")
		return false
	end
	local skillList=hunter:get_field("_refPlayerSkillList")
	local skillData=skillList:get_field("_PlayerSkillData")
	-- print(skillData)
	for i=0,47,1 do --max 47
		-- print("position : "..tostring(i))
		-- print(skillData[i])
		skillData[i]:set_field('SkillId',i)
		skillData[i]:set_field('SkillLv',6)
		-- view_info(skillData[i])
		-- print()
	end
	
end

-- TODO イベントのハッカが早すぎる。

sdk.hook(sdk.find_type_definition("snow.player.PlayerManager"):get_method("set_PlayerData"), nil, setup_hunter)
sdk.hook(sdk.find_type_definition("snow.player.PlayerUserDataCommon"):get_method("get_ReffUserDataCommon"), nil, setup_wire)
sdk.hook(sdk.find_type_definition("snow.player.PlayerBase"):get_method("update"), nil, on_post_update)
sdk.hook(sdk.find_type_definition("snow.player.PlayerData"):get_method("set__vital"), nil, on_post_vital)
sdk.hook(sdk.find_type_definition("snow.data.HandMoney"):get_method("addMoney"), nil, data_update)
-- sdk.hook(sdk.find_type_definition("snow.player.PlayerSkillList"):get_method("get_PlayerSkillData"),nil,override_skill)

