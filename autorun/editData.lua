-- バックアップ！！

function setItemBox()
    local dataManager=sdk.get_managed_singleton("snow.data.DataManager")
    local itemBox=dataManager:get_field("_PlItemBox")
    local inventoryList= itemBox:get_field("_InventoryList")
    local items=inventoryList:get_field("mItems")

    print(#items)
    local itemZero=68157440
    local itemPlaceMax=2999
    local place=0
    for i=0,1799,1 do
        local itemCount=items[i]:get_field("_ItemCount")
        
        if place==1104 then
            place=2001
        end
            
        if place>itemPlaceMax then
            return
        end

        itemCount:set_field("_Id",itemZero+place)
        itemCount:set_field("_Num",5000+place)    

        place=place+1
    end
end

local runSetItemBoxFlug=false

function runSetItemBox()
    print('move area')
    if not runSetItemBoxFlug then
        return
    end

    runSetItemBoxFlug=false
    print('item box')
    setItemBox()

end

local runSetItemPouchFlug=true

local itemsNormal=nil
local itemsBullet=nil

function itemPouchInitialize()
    local dataManager=sdk.get_managed_singleton("snow.data.DataManager")
    local itemBox=dataManager:get_field("_ItemPouch")
    local inventoryList= itemBox:get_field("_NormalInventoryList")
    local bulletList=itemBox:get_field('_BulletBottleInventoryList')
    itemsNormal=inventoryList:get_field("mItems")
    itemsBullet=bulletList:get_field("mItems")
end

function itemsMax(items)
    for i=0,#items-1,1 do
        local itemCount=items[i]:get_field("_ItemCount")
        local id=itemCount:get_field("_Id")
        if id ~=67108864 then
        itemCount:set_field("_Num",90)
        end
    end
end

function tryConsumeItemPouch()
    if not runSetItemPouchFlug then
        return 
    end
    if itemsNormal ==nil then
        itemPouchInitialize()
    end
    itemsMax(itemsNormal)
    return 
end

function tryConsumeBullet()
    if not runSetItemPouchFlug then
        return
    end
    if itemsBullet ==nil then
        itemPouchInitialize()
    end
    itemsMax(itemsBullet)
end

re.on_draw_ui(function()
	local changed = false

    if imgui.tree_node("Item Manager") then
        changed, runSetItemBoxFlug = imgui.checkbox("run itemBox", runSetItemBoxFlug)
        changed, runSetItemPouchFlug = imgui.checkbox("run itemPouch", runSetItemPouchFlug)
        imgui.tree_pop()
    end
end)

function defPre()
    
end
function defPost(retVal)
    return retVal
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

sdk.hook(sdk.find_type_definition("snow.VillageAreaManager"):get_method("jump"), runSetItemBox, defPost)
sdk.hook(sdk.find_type_definition("snow.data.ItemPouch"):get_method("addItem"), tryConsumeItemPouch,defPost )
sdk.hook(sdk.find_type_definition("snow.player.Bow"):get_method("requestCreateArrow"), tryConsumeBullet,defPost )
sdk.hook(sdk.find_type_definition("snow.player.LightBowgun"):get_method("isShootMove"), tryConsumeBullet,defPost)
sdk.hook(sdk.find_type_definition("snow.player.HeavyBowgun"):get_method("isShootMove"), tryConsumeBullet,defPost)



sdk.hook(sdk.find_type_definition("snow.data.HandMoney"):get_method("addMoney"), nil, moneyUpdate)
sdk.hook(sdk.find_type_definition("snow.data.VillagePoint"):get_method("setPointSnapshot"), nil, villagePointUpdate)




















