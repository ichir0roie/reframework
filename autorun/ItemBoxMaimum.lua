-- バックアップ！！

function setItemBox()
    local dataManager=sdk.get_managed_singleton("snow.data.DataManager")
    local itemBox=dataManager:get_field("_PlItemBox")
    local inventoryList= itemBox:get_field("_InventoryList")
    local items=inventoryList:get_field("mItems")

    print(#items)
    local itemOneNumber=68157441
    for i=0,1800-1,1 do
        local itemCount=items[i]:get_field("_ItemCount")
        local id=itemCount:get_field("_Id")
        local num=itemCount:get_field("_Num")
        print(tostring(id).." : "..tostring(num))
        itemCount:set_field("_Id",itemOneNumber+i)
        itemCount:set_field("_Num",9000)
    end
end

local runSetItemBoxFlug=false

function runSetItemBox()
    print('move area')
    if not runSetItemBoxFlug then
        return
    end

    print('item box')
    setItemBox()

    runSetItemBoxFlug=false
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



sdk.hook(sdk.find_type_definition("snow.VillageAreaManager"):get_method("jump"), runSetItemBox, defPost)
sdk.hook(sdk.find_type_definition("snow.data.ItemPouch"):get_method("addItem"), tryConsumeItemPouch,defPost )
sdk.hook(sdk.find_type_definition("snow.player.Bow"):get_method("requestCreateArrow"), tryConsumeBullet,defPost )





















