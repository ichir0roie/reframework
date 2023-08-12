-- バックアップ！！

local itemIdArray = {
    { start = 1,    end_ = 1103 },
    { start = 2001, end_ = 2383 },
    { start = 2450, end_ = 2478 },
    { start = 2584, end_ = 2592 },
    { start = 2663, end_ = 2713 },
    { start = 2803, end_ = 2806 },
    { start = 2808, end_ = 2808 },
    { start = 2830, end_ = 2832 },
    { start = 2851, end_ = 2873 }
}

function setItemBox()
    local dataManager = sdk.get_managed_singleton("snow.data.DataManager")
    local itemBox = dataManager:get_field("_PlItemBox")
    local inventoryList = itemBox:get_field("_InventoryList")
    local items = inventoryList:get_field("mItems")

    print(#items)
    local itemZero = 68157440
    -- local itemPlaceMax=2999
    -- local place=2001
    local itemCount = nil
    local boxPos = 0
    print(#itemIdArray)
    for itemArrayStep = 1, #itemIdArray, 1 do
        print(itemArrayStep)
        print(itemIdArray[itemArrayStep].start)
        for idPos = itemIdArray[itemArrayStep].start, itemIdArray[itemArrayStep].end_, 1 do
            if boxPos >= 1800 then
                print('limit box array...')
                print(itemZero + idPos)
                return
            end

            itemCount = items[boxPos]:get_field("_ItemCount")
            itemCount:set_field("_Id", itemZero + idPos)
            itemCount:set_field("_Num", 5000 + idPos)
            boxPos = boxPos + 1
        end
    end
    print('finish')
end

-- setItemBox()

local runSetItemBoxFlug = false

function runSetItemBox()
    print('move area')
    if not runSetItemBoxFlug then
        return
    end

    runSetItemBoxFlug = false
    print('item box')
    setItemBox()
end

local runSetItemPouchFlug = true

local itemsNormal = nil
local itemsBullet = nil

function itemPouchInitialize()
    local dataManager = sdk.get_managed_singleton("snow.data.DataManager")
    local itemBox = dataManager:get_field("_ItemPouch")
    local inventoryList = itemBox:get_field("_NormalInventoryList")
    local bulletList = itemBox:get_field('_BulletBottleInventoryList')
    itemsNormal = inventoryList:get_field("mItems")
    itemsBullet = bulletList:get_field("mItems")
end

function itemsMax(items)
    for i = 0, #items - 1, 1 do
        local itemCount = items[i]:get_field("_ItemCount")
        local id = itemCount:get_field("_Id")
        if id ~= 67108864 then
            itemCount:set_field("_Num", 90)
        end
    end
end

function tryConsumeItemPouch()
    if not runSetItemPouchFlug then
        return
    end
    if itemsNormal == nil then
        itemPouchInitialize()
    end
    itemsMax(itemsNormal)
    return
end

function tryConsumeBullet()
    print("try bullet full")
    if not runSetItemPouchFlug then
        return
    end
    if itemsBullet == nil then
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

local data = nil
function moneyUpdate()
    print('set money')
    if data == nil then
        data = sdk.get_managed_singleton("snow.data.DataManager")
    end
    if data == nil then
        return
    end
    local money = data:get_field("_HandMoney")
    money:set_field("_Value", 90000000)
end

function villagePointUpdate()
    print('update vp')
    if data == nil then
        data = sdk.get_managed_singleton("snow.data.DataManager")
    end
    if data == nil then
        return
    end
    local money = data:get_field("<VillagePointData>k__BackingField")
    money:set_field("_Point", 90000000)
end

sdk.hook(sdk.find_type_definition("snow.VillageAreaManager"):get_method("jump"), runSetItemBox, defPost)
sdk.hook(sdk.find_type_definition("snow.data.ItemPouch"):get_method("addItem"), tryConsumeItemPouch, defPost)
sdk.hook(sdk.find_type_definition("snow.player.Bow"):get_method("requestCreateArrow"), tryConsumeBullet, defPost)
sdk.hook(sdk.find_type_definition("snow.player.LightBowgun"):get_method("isShootMove"), tryConsumeBullet, defPost)
sdk.hook(sdk.find_type_definition("snow.player.HeavyBowgun"):get_method("isShootMove"), tryConsumeBullet, defPost)
sdk.hook(sdk.find_type_definition("snow.player.HeavyBowgun"):get_method("addBulletNumFullAuto"), tryConsumeBullet,
    defPost)



sdk.hook(sdk.find_type_definition("snow.data.HandMoney"):get_method("addMoney"), nil, moneyUpdate)
sdk.hook(sdk.find_type_definition("snow.data.VillagePoint"):get_method("setPointSnapshot"), nil, villagePointUpdate)
