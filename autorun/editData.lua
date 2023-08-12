-- バックアップ！！

local itemIdArray = {
    { start = 2001, end_ = 2382 },
    { start = 2449, end_ = 2477 },
    { start = 2583, end_ = 2663 },
    { start = 2663, end_ = 2713 },
    { start = 2795, end_ = 3000 },
    { start = 1,    end_ = 1103 },
    -- { start = 2300, end_ = 2450 },
    -- { start = , end_ =  },

}

local item_count_base = 5000
local debug_skip_multiple = 1

function setItemBox()
    print("set item box")
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
            local id_ = idPos * debug_skip_multiple
            if id_ > itemIdArray[itemArrayStep].end_ then
                print("finish id max")
                print(id_)
                return
            end
            if boxPos >= 1800 then
                print('limit box array...')
                print(idPos)
                return
            end


            itemCount = items[boxPos]:get_field("_ItemCount")
            itemCount:set_field("_Id", itemZero + id_)
            itemCount:set_field("_Num", item_count_base + id_ - 1)
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
