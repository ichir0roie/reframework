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
	local inputManager = getSingletonData("snow.StmInputManager")
	local inGameInputDevice = getSingletonField(inputManager, "_InGameInputDevice")
	local playerInput = sdk.get_native_field(inGameInputDevice, getType("snow.StmInputManager.InGameInputDevice"), "_pl_input")
	local weapon = sdk.get_native_field(playerInput, getType("snow.StmPlayerInput"), "RefPlayer")
	return weapon
end

local quest_started=false
local hunter_initialized=false

-- local playerManager=nil
-- local playerList=nil
local hunter=nil
local hunterType=nil
local playerData=nil

function updateHunterInfo()
	-- print('update')
	-- if hunter ~=nil then
	-- 	return tr
	-- end
	if hunter_initialized then
		return
	end

	print("update hunter")
	if pcall(setHunter) then
	else
		print("error hunter setup")
		hunter_initialized=false
		return
	end
	
	if hunter ==nil then
		hunter_initialized=false
		return
	end
	
	playerData=hunter:get_field("_refPlayerData")
	
	setup_wire()
	-- override_skill()

	hunter_initialized=true
end

function setHunter()
	-- playerManager=sdk.get_managed_singleton('snow.player.PlayerManager')
	-- playerList=playerManager:get_field('PlayerList')		
	hunter=getCurrentPlayer()
	hunterType=hunter:get_type_definition()
end

function notActionStatus()
	-- if not runActionMod or hunter ==nil or not quest_started then
	if not hunter_initialized or not quest_started then
		return true
	end
	return false
end

function updateStatus()
	if not hunter_initialized then
		updateHunterInfo()
	end

	if playerData==nil then
		return
	end

	if hunterType:get_name()=="InsectGlaive" then
		updateInsectGlaive()
	end

	playerData:set_field("_Attack",1000)
	playerData:set_field("_Defence",50)

	playerData:set_field("_vitalMax",200)
	playerData:set_field("_vitalKeep",200)
	playerData:set_field("_r_Vital",200)
	
	playerData:set_field("_staminaMax",5700)
	playerData:set_field("_stamina",5700)

	hunter:set_field("<SharpnessLv>k__BackingField",6)

end

function updateInsectGlaive()
	hunter:set_field("_RedExtractiveTime",5000)
	hunter:set_field("_WhiteExtractiveTime",5000)
	hunter:set_field("_OrangeExtractiveTime",5000)
	hunter:set_field("_AerialCount",0)
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
	print("setup wire")
	local playerCommon=hunter:get_field("_PlayerUserDataCommon")
	-- wire -> playeruserdatacommon

	local speed=0.75
	playerCommon:set_field('_HunterWireJumpHighSpeed',2)
	playerCommon:set_field('_HunterWireJumpHighFlySpeed',speed)
	playerCommon:set_field('_HunterWireJumpJumpLowSpeed',speed)
	playerCommon:set_field('_HunterWireJumpLowFlySpeed',speed)
	playerCommon:set_field('_HunterWireJumpTargetSpeed',speed)
	playerCommon:set_field('_HunterWireJumpTargetFlySpeed',speed)
	local gravity=-0.012
	playerCommon:set_field('_HunterWireJumpHighGravity',-0.007)
	playerCommon:set_field('_HunterWireJumpHighFlyGravity',gravity)
	playerCommon:set_field('_HunterWireJumpJumpLowGravity',gravity)
	playerCommon:set_field('_HunterWireJumpLowFlyGravity',gravity)
	playerCommon:set_field('_HunterWireJumpTargetGravity',gravity)
	playerCommon:set_field('_HunterWireJumpTargetFlyGravity',gravity)
end


local data=nil
function moneyUpdate()
	print('set money')
	if data == nil then
		data=sdk.get_managed_singleton("snow.data.DataManager")
	end
	if data==nil then
		return 
	end
	local money=data:get_field("_HandMoney")
	money:set_field("_Value",90000000)
end
function villagePointUpdate()
	print('update vp')
	if data == nil then
		data=sdk.get_managed_singleton("snow.data.DataManager")
	end
	if data==nil then
		return 
	end
	local money=data:get_field("<VillagePointData>k__BackingField")
	money:set_field("_Point",90000000)
end

function override_skill()
	-- testing
	print('override skill')
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


function questStart()
	print("start quest")
	quest_started=true
	hunter_initialized=false
end

function questEnd()
	print("end quest")
	quest_started=false
	hunter_initialized=false

end

function initQuest()
	print("init quest")
	quest_started=false
	hunter_initialized=false
end



sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("questStart"), nil, questStart)
sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("onQuestEnd"), nil, questEnd)
sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("initQuestParam"), nil, initQuest)

sdk.hook(sdk.find_type_definition("snow.player.PlayerBase"):get_method("update"), nil, updateStatus)

sdk.hook(sdk.find_type_definition("snow.data.HandMoney"):get_method("addMoney"), nil, moneyUpdate)
sdk.hook(sdk.find_type_definition("snow.data.VillagePoint"):get_method("setPointSnapshot"), nil, villagePointUpdate)

