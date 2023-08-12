-- require("key_enums")

-- local hwKB = nil
-- local kbToggleKey = 35 -- (by default END key) lookup the key_enums.lua file to see what number corresponds to what key.

-- local hwPad = nil
-- local padToggleBtn = 8192 -- (by default RS/R3 button) lookup the key_enums.lua file to see what number corresponds to what button.

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
	local playerInput = sdk.get_native_field(inGameInputDevice, getType("snow.StmInputManager.InGameInputDevice"),
		"_pl_input")
	local weapon = sdk.get_native_field(playerInput, getType("snow.StmPlayerInput"), "RefPlayer")
	return weapon
end

local in_quest = false

in_quest = true -- test

local hunter_initialized = false

-- local playerManager=nil
-- local playerList=nil
local hunter = nil
local hunterType = nil
local playerData = nil

function updateHunterInfo()
	print('update hunter info')
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
		hunter_initialized = false
		return
	end

	if hunter == nil then
		hunter_initialized = false
		return
	end

	playerData = hunter:get_field("_refPlayerData")
	print(playerData)

	setup_wire()
	-- override_skill()

	setup_equip()

	hunter_initialized = true
end

function setup_equip()
	local tree = hunter:get_field('_WeaponListDataCache')
	tree = tree:get_field('<LocalBaseData>k__BackingField')
	tree = tree:get_field('_WeaponBaseData')
	tree:set_field('_Atk', 2000)
end

function setHunter()
	-- playerManager=sdk.get_managed_singleton('snow.player.PlayerManager')
	-- playerList=playerManager:get_field('PlayerList')		
	hunter = getCurrentPlayer()
	hunterType = hunter:get_type_definition()
	print(hunterType:get_name())

	if hunterType:get_name() == "GunLance" then
		gunLanceSetup(q)
	end
end

function notActionStatus()
	-- if not runActionMod or hunter ==nil or not quest_started then
	if not hunter_initialized or not in_quest then
		return true
	end
	return false
end

function updateStatus()
	if not hunter_initialized and in_quest then
		updateHunterInfo()
	end

	if hunter == nil or playerData == nil then
		return
	end

	hunterType = hunter:get_type_definition()
	if hunterType:get_name() == "PlayerLobbyBase" then
		return
	end

	if hunterType:get_name() == "InsectGlaive" then
		updateInsectGlaive()
	end

	-- status
	-- playerData:set_field("_Attack",9000)
	-- playerData:set_field("_Defence",50)

	-- move
	-- hunter:set_field('_HitSlowSpeed',1.5)
	-- hunter:set_field('_HitSlowTimer',1000)

	playerData:set_field("_vitalMax", 200)
	playerData:set_field("_vitalKeep", 200)
	playerData:set_field("_r_Vital", 200)

	playerData:set_field("_staminaMax", 5700)
	playerData:set_field("_stamina", 5700)

	-- hunter:set_field("<SharpnessLv>k__BackingField",6)
end

function updateInsectGlaive()
	hunter:set_field("_RedExtractiveTime", 5000)
	hunter:set_field("_WhiteExtractiveTime", 5000)
	hunter:set_field("_OrangeExtractiveTime", 5000)
	hunter:set_field("_AerialCount", 2)
end

function view_info(o)
	if o == nil then
		print('nil')
		return
	end
	local typeDef = o:get_type_definition()
	print(typeDef)
	for i, m in ipairs(typeDef:get_fields()) do
		print(tostring(i) .. " : " .. m:get_name())
	end
	-- for i=0,o:get_reference_count()-1,1 do
	-- 	print(o:get_field(i))
	-- end
end

function setup_wire()
	print("setup wire")
	local playerCommon = hunter:get_field("_PlayerUserDataCommon")
	-- wire -> playeruserdatacommon

	local speed = 0.6
	playerCommon:set_field('_HunterWireJumpHighSpeed', speed)
	playerCommon:set_field('_HunterWireJumpHighFlySpeed', speed)
	-- playerCommon:set_field('_HunterWireJumpJumpLowSpeed', speed)
	playerCommon:set_field('_HunterWireJumpLowFlySpeed', speed)
	playerCommon:set_field('_HunterWireJumpTargetSpeed', 1.5)
	playerCommon:set_field('_HunterWireJumpTargetFlySpeed', 1.0)
	local gravity = -0.012
	playerCommon:set_field('_HunterWireJumpHighGravity', gravity)
	-- playerCommon:set_field('_HunterWireqJumpHighFlyGravity', gravity)
	-- playerCommon:set_field('_HunterWireJumpJumpLowGravity', gravity)
	playerCommon:set_field('_HunterWireJumpLowFlyGravity', gravity)
	playerCommon:set_field('_HunterWireJumpTargetGravity', -0.002)
	playerCommon:set_field('_HunterWireJumpTargetFlyGravity', -0.002)
end

-- function override_skill()
-- 	-- testing
-- 	print('override skill')
-- 	local skillList = hunter:get_field("_refPlayerSkillList")
-- 	local skillData = skillList:get_field("_PlayerSkillData")
-- 	-- print(skillData)
-- 	for i = 0, 47, 1 do --max 47
-- 		-- print("position : "..tostring(i))
-- 		-- print(skillData[i])
-- 		skillData[i]:set_field('SkillId', i)
-- 		skillData[i]:set_field('SkillLv', 6)
-- 		-- view_info(skillData[i])
-- 		-- print()
-- 	end
-- end

function questStart()
	print("start quest")
	in_quest = true
end

function questEnd()
	print("end quest")
	in_quest = false
	hunter_initialized = false
end

function initQuest()
	print("init quest")
	-- gunLanceSetup()
end

function defPre()

end

sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("questStart"), nil, questStart)
sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("onQuestEnd"), nil, questEnd)
sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("initQuestParam"), nil, initQuest)

sdk.hook(sdk.find_type_definition("snow.player.PlayerBase"):get_method("update"), nil, updateStatus)

function machineGunUpdate(r)
	playerData:set_field("_HeavyBowgunWyvernMachineGunBullet", 50)
	addBulletNum(nil)
	return r
end

function snipeUpdate(r)
	playerData:set_field("_HeavyBowgunWyvernSnipeBullet", 1)
	playerData:set_field("_HeavyBowgunWyvernSnipeTimer", 0)
	return r
end

sdk.hook(
	sdk.find_type_definition("snow.player.fsm.PlayerFsm2ActionHeavyBowgunSetBulletWyvernMachineGun"):get_method("update"),
	defPre, machineGunUpdate)
sdk.hook(
	sdk.find_type_definition("snow.player.fsm.PlayerFsm2ActionHeavyBowgunAddBulletWyvernSnipeEnd"):get_method("start"),
	defPre, snipeUpdate)


-- 若干問題あり。装備を変えた場合に対応できてない。
function addBulletNum(num)
	hunter:call('resetBulletNum')
	playerData:set_field("_HeavyBowgunHeatGauge", 0)
	return num
end

sdk.hook(sdk.find_type_definition("snow.player.HeavyBowgun"):get_method("addBulletNum"), defPre, addBulletNum)
sdk.hook(sdk.find_type_definition("snow.player.LightBowgun"):get_method("addBulletNum"), defPre, addBulletNum)
sdk.hook(sdk.find_type_definition("snow.player.HeavyBowgun"):get_method("addBulletNumFullAuto"), defPre, addBulletNum)

function gunLanceUpdate(v)
	hunter:set_field("_ShotChargeFrame", 100)
	if hunter:get_field("_BulletNum") == 0 then
		hunter:set_field("_BulletNum", 1)
	end
	-- hunter:set_field("_CanUsePile",true)
	hunter:set_field("_AerialCount", 0)

	return v
end

sdk.hook(sdk.find_type_definition("snow.player.GunLance"):get_method("update"), defPre, gunLanceUpdate)

local gunLanceShellManager
local shell
local items
local item
local upRate = 4
function gunLanceShellUpRate(key)
	items = nil
	item = nil
	for s = 0, #shell - 1, 1 do
		items = shell[s]:get_field("mItems")
		for i = 0, #items do
			item = items[i]
			if item ~= nil then
				item:set_field(key, upRate)
			end
		end
	end
end

function gunLanceSetup()
	gunLanceShellManager = sdk.get_managed_singleton('snow.shell.GunLanceShellManager')
end

function gunLanceSetShell(key)
	if gunLanceShellManager == nil then
		gunLanceSetup()
	end
	if gunLanceShellManager ~= nil then
		shell = gunLanceShellManager:get_field(key)
	end
end

function gunLanceShell(shellKey, paramKey)
	gunLanceSetShell(shellKey)
	gunLanceShellUpRate(paramKey)
end

function gunLanceShell000(v)
	gunLanceShell("_GunLanceShell000s", '_DamageRate_Physical')
	return v
end

sdk.hook(sdk.find_type_definition("snow.shell.GunLanceShell000"):get_method("init"), defPre, gunLanceShell000)
function gunLanceShell001(v)
	gunLanceShell("_GunLanceShell001s", '_DamageRate')
	return v
end

sdk.hook(sdk.find_type_definition("snow.shell.GunLanceShell001"):get_method("init"), defPost, gunLanceShell001)
function gunLanceShell002(v)
	gunLanceShell("_GunLanceShell002s", '_DamageRate')
	return v
end

sdk.hook(sdk.find_type_definition("snow.shell.GunLanceShell002"):get_method("init"), defPost, gunLanceShell002)
function gunLanceShell003(v)
	gunLanceShell("_GunLanceShell003s", '_DamageRate')
	return v
end

sdk.hook(sdk.find_type_definition("snow.shell.GunLanceShell003"):get_method("init"), defPost, gunLanceShell003)
function gunLanceShell101(v)
	gunLanceShell("_GunLanceShell101s", '_DamageRate')
	return v
end

sdk.hook(sdk.find_type_definition("snow.shell.GunLanceShell101"):get_method("init"), defPost, gunLanceShell101)


-- TODO 修練場での初期化
