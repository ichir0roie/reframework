local allManagersRetrieved = false
local gm = {}
gm.GuiManager = {}
gm.GuiManager.n = "snow.gui.GuiManager"

for i,v in pairs(gm) do
    v.d = sdk.get_managed_singleton(v.n)
end

local HudApi = {}

HudApi.Color = {
    White   = 0xFFFFFFFF,
    Black   = 0xFF000000,
    Gray    = 0xFFAEAEAE,
    Pink    = 0xFFEF73B9,
    Yellow  = 0xFFFFFF71,
    Amber   = 0xFFFFB355,
    Orange  = 0xFFFF7316,
    Red     = 0xFFFF4B0D,
    Green   = 0xFF26E196,
    Purple  = 0xFFA540E1,
    Blue    = 0xFF476EFF,
    Cyan    = 0xFF5AAAFF,
    Skyblue = 0xFFA0CDFF,
    Brown   = 0xFF9B784F,
    Health  = 0xFF77DBA8,
    Dying   = 0xffeb784f,
    Stamina = 0xFFEFCD31,
    BarBack = 0x69000000,
}

local settings = json.load_file("MAPHud Settings.json")
settings = settings and settings or {}
settings.Scale = settings.Scale or 1.5
settings.RightOffset = settings.RightOffset or 0
settings.TopOffset = settings.TopOffset or 0
settings.AlwaysDraw = settings.AlwaysDraw or false
settings.Enabled = settings.Enabled == nil and true or settings.Enabled

local bar = {}
bar.defaultHeight = 210
bar.width = 175
bar.height = 16
bar.innerMargin = 5
bar.outermargin = 0
bar.middlespace = 30

bar.labels = false

HudApi.Images = {}

-- X / Y / W / S / %L / C
HudApi.Gauges = {}
HudApi.Namebar = {}
HudApi.Namebar[1] = 
{
    Draw = true,
    Name = "Name",
    Status = 0,
    x = 0, y = 0,
    s = 1,
}

HudApi.EyeStates = {
    "Yellow",
    "Red",
    "Purple"
}
HudApi.SizeStates = {
    "Small",
    "Big",
    "King"
}

HudApi.TextShadow = 1

--HudApi.Gauges[1] = {500, 500, 200, 1.5, 1, HudApi.Color.STAMINA}

d2d.register(function()
    HudApi.Images.LeftInner = d2d.Image.new("LeftInner.png")
    HudApi.Images.LeftInnerD = d2d.Image.new("LeftInnerD.png")
    -- 12 x 9
    HudApi.Images.LeftOuter = d2d.Image.new("LeftOuter.png")
    HudApi.Images.LeftOuterD = d2d.Image.new("LeftOuterD.png")
    -- 14 x 16

    HudApi.Images.MidInner = d2d.Image.new("MidInner.png")
    HudApi.Images.MidInnerD = HudApi.Images.MidInner
    -- 14 x 9
    HudApi.Images.MidOuter = d2d.Image.new("MidOuter.png")
    HudApi.Images.MidOuterD = d2d.Image.new("MidOuterD.png")
    -- 10 x 16

    HudApi.Images.RightInner = d2d.Image.new("RightInner.png")
    HudApi.Images.RightInnerD = d2d.Image.new("RightInnerD.png")
    -- 12 x 9
    HudApi.Images.RightOuter = d2d.Image.new("RightOuter.png")
    HudApi.Images.RightOuterD = d2d.Image.new("RightOuterD.png")
    -- 33 x 16

    HudApi.Images.Nameplate = d2d.Image.new("Namebar.png")
    -- 271 x 23
    HudApi.Images.EyeYellow = d2d.Image.new("EyeYellow.png")
    HudApi.Images.EyeRed = d2d.Image.new("EyeRed.png")
    HudApi.Images.EyePurple = d2d.Image.new("EyePurple.png")
    -- 32 x 32

    HudApi.Images.CrownKing = d2d.Image.new("CrownKing.png")
    HudApi.Images.CrownBig = d2d.Image.new("CrownBig.png")
    HudApi.Images.CrownSmall = d2d.Image.new("CrownSmall.png")
    -- 26 x 26

    HudApi.Font = d2d.Font.new("Arial", 20, false)
    HudApi.FontSmall = d2d.Font.new("Arial", 12, false)
end,
function ()
    for i,v in pairs(HudApi.Gauges) do
        local draw,x,y,w,s,l,c,u,cb,label = v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v.label
        cb = cb and cb or HudApi.Color.BarBack
        local cap = u and "D" or ""
        local off = u and 3 or 4
        if draw then
            d2d.image(HudApi.Images["LeftOuter"..cap], x - (14 * s), y - (off * s), 14 * s, 16 * s)
            d2d.image(HudApi.Images["MidOuter"..cap], x, y - (off * s), w, 16 * s)
            d2d.image(HudApi.Images["RightOuter"..cap], x + w, y- (off * s), 33 * s, 16 * s)

            d2d.fill_rect( x - (4 * s) , y + (1 * s), (w)+ (8 * s), ((9 - 2) * s), cb)
            d2d.fill_rect( x - (4 * s) , y + (1 * s), (w * l) + (l * 8 * s), ((9 - 2) * s), c)

            d2d.image(HudApi.Images["LeftInner"..cap], x - (12 * s), y, 12 * s, 9 * s)
            d2d.image(HudApi.Images["MidInner"], x, y, w, 9 * s)
            d2d.image(HudApi.Images["RightInner"..cap], x + w, y, 12 * s, 9 * s)

            if label and (bar.labels or settings.AlwaysDraw) then
                y = y + ((16 * s)/2) - 12
                d2d.text(HudApi.FontSmall, label, x - HudApi.TextShadow, y + HudApi.TextShadow, HudApi.Color.Black)
                d2d.text(HudApi.FontSmall, label, x - HudApi.TextShadow, y - HudApi.TextShadow, HudApi.Color.Black)
                d2d.text(HudApi.FontSmall, label, x + HudApi.TextShadow, y + HudApi.TextShadow, HudApi.Color.Black)
                d2d.text(HudApi.FontSmall, label, x + HudApi.TextShadow, y - HudApi.TextShadow, HudApi.Color.Black)
                d2d.text(HudApi.FontSmall, label, x,y, HudApi.Color.White)
            end
        end
    end
    HudApi.Gauges = {}
    for i,v in pairs(HudApi.Namebar) do
        local Draw, Name, Status, Scale, sizeType, x, y, s = v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8]
        if Draw then
            local StatusBlink = math.sin(os.clock() * 2)
            
            
            d2d.image(HudApi.Images.Nameplate, x, y, 271 * s, 23 * s)
            Status = Status > 3 and 0 or Status
            Status = Status < 0 and 0 or Status

            local DoBlink = Status > 0 and sizeType > 0

            local BlinkType = StatusBlink > 0

            if Status > 0 then
                if DoBlink then
                    if BlinkType then
                        d2d.image(HudApi.Images["Eye"..HudApi.EyeStates[Status]], x + 30, y - 3, 32 * s * 0.8, 32 * s * 0.8)
                    end
                else
                    d2d.image(HudApi.Images["Eye"..HudApi.EyeStates[Status]], x + 30, y - 3, 32 * s * 0.8, 32 * s * 0.8)
                end
            end
            if sizeType > 0 then
                if DoBlink then
                    if not BlinkType then
                        d2d.image(HudApi.Images["Crown"..HudApi.SizeStates[sizeType]], x + 34 * (s/1.5), y + 2, 26 * s * 0.8,26 * s * 0.8)
                    end
                else
                    d2d.image(HudApi.Images["Crown"..HudApi.SizeStates[sizeType]], x + 34 * (s/1.5), y + 2 * (s/1.5), 26 * s * 0.8,26 * s * 0.8)
                end
            end
            if  (bar.labels or settings.AlwaysDraw) and (Scale ~= -64) then
                Name = Name .. " (Size: " .. math.floor(Scale * 100 + 0.5) .. "%)"
            end
            d2d.text(HudApi.Font, Name, x + (60 * s) + HudApi.TextShadow, y + (3 * s) + HudApi.TextShadow, HudApi.Color.Black)
            d2d.text(HudApi.Font, Name, x + (60 * s) + HudApi.TextShadow, y + (3 * s) - HudApi.TextShadow, HudApi.Color.Black)
            d2d.text(HudApi.Font, Name, x + (60 * s) - HudApi.TextShadow, y + (3 * s) + HudApi.TextShadow, HudApi.Color.Black)
            d2d.text(HudApi.Font, Name, x + (60 * s) - HudApi.TextShadow, y + (3 * s) - HudApi.TextShadow, HudApi.Color.Black)
            d2d.text(HudApi.Font, Name, x + (60 * s), y + (3 * s), HudApi.Color.White)
        end
    end
    HudApi.Namebar = {}
end
)

local function RGBToHSV( red, green, blue )
	-- Returns the HSV equivalent of the given RGB-defined color
	-- (adapted from some code found around the web)

	local hue, saturation, value;

	local min_value = math.min( red, green, blue );
	local max_value = math.max( red, green, blue );

	value = max_value;

	local value_delta = max_value - min_value;

	-- If the color is not black
	if max_value ~= 0 then
		saturation = value_delta / max_value;
        
	-- If the color is purely black
	else
		saturation = 0;
		hue = -678;
		return hue, saturation, value;
	end;
    
    if min_value == 255 then
        saturation = 0
        hue = -678
        return hue, saturation, value
    end
    if value_delta == 0 then
        hue = -678/60
    elseif red == max_value then
		hue = ( green - blue ) / value_delta;
	elseif green == max_value then
		hue = 2 + ( blue - red ) / value_delta;
	else
		hue = 4 + ( red - green ) / value_delta;
	end;

	hue = hue * 60;
	if hue < 0 and hue ~= -678 then
		hue = hue + 360;
	end;
    saturation = math.max(saturation, 0)
    saturation = math.min(saturation, 1)
	return hue, saturation, value;
end;
function HSVToRGB( hue, saturation, value )
	-- Returns the RGB equivalent of the given HSV-defined color
	-- (adapted from some code found around the web)

	-- If it's achromatic, just return the value
	if saturation <= 0 or saturation == 0.0 then
		return value, value, value;
	end;

	-- Get the hue sector
	local hue_sector = math.floor( hue / 60 );
	local hue_sector_offset = ( hue / 60 ) - hue_sector;

	local p = value * ( 1 - saturation );
	local q = value * ( 1 - saturation * hue_sector_offset );
	local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) );

	if hue_sector == 0 then
		return value, t, p;
	elseif hue_sector == 1 then
		return q, value, p;
	elseif hue_sector == 2 then
		return p, value, t;
	elseif hue_sector == 3 then
		return p, q, value;
	elseif hue_sector == 4 then
		return t, p, value;
	elseif hue_sector == 5 then
		return value, p, q;
	end;
end;

local function LinearGradient(ax,bx,t)

    t = (math.sin(math.deg(t*360))+1)/2
    ax = string.format("%8x", ax)
    local alpha,r,g,b = tonumber(ax:sub(1,2), 16), tonumber(ax:sub(3,4), 16), tonumber(ax:sub(5,6), 16), tonumber(ax:sub(7,8), 16)
    local av = {}
    av.h,av.s,av.v = RGBToHSV(r,g,b)
    bx = string.format("%8x", bx)
    
    local blpha,r,g,b = tonumber(bx:sub(1,2), 16), tonumber(bx:sub(3,4), 16), tonumber(bx:sub(5,6), 16), tonumber(bx:sub(7,8), 16)
    local bv = {}
    bv.h,bv.s,bv.v = RGBToHSV(r,g,b)
    if bv.h <= -678 then bv.h = av.h end
    if av.h <= -678 then av.h = bv.h end
    local cv = {}
    cv.h = av.h * (1-t) + bv.h * t
    cv.s = av.s * (1-t) + bv.s * t
    cv.v = av.v * (1-t) + bv.v * t
    cv.s = math.max(cv.s, 0)
    cv.s = math.min(cv.s, 1)
    cv.a = alpha * (1-t) + blpha * t
    cv.r, cv.g, cv.b = HSVToRGB(cv.h, cv.s, cv.v)
    if cv.r > 250 then cv.r = 250 end
    if cv.g > 250 then cv.g = 250 end
    if cv.b > 250 then cv.b = 250 end
    if cv.a > 250 then cv.a = 250 end
    if cv.r <= 0 then cv.r = 0 end
    if cv.g <= 0 then cv.g = 0 end
    if cv.b <= 0 then cv.b = 0 end
    if cv.a <= 0 then cv.a = 0 end
    return tonumber("0x".. string.format("%02x", math.floor(cv.a)) .. 
    string.format("%02x", math.floor(cv.r)) .. 
    string.format("%02x", math.floor(cv.g)) .. 
    string.format("%02x", math.floor(cv.b)))
end

-- 1 = head
-- 2 = back
-- 3 = left wing/foreleg
-- 4 = right wing/foreleg
-- 5 = left leg
-- 6 = right leg
-- 7 = tail

local enemyData = {}

--local enemyManager = sdk.get_managed_singleton("snow.enemy.EnemyManager")

local text = {}
text.txtcolor = 0xffffffff
text.bgcolor = 0xff000000

statuscolors = {
    Poison       = HudApi.Color.Purple,
    Stun         = HudApi.Color.Yellow,
    Paralysis    = HudApi.Color.Amber,
    Sleep        = HudApi.Color.Skyblue,
    Blast        = HudApi.Color.Orange,
    Exhaust      = HudApi.Color.Blue,
    Fireblight   = HudApi.Color.Red,
    Waterblight  = HudApi.Color.Blue,
    Thunderblight= HudApi.Color.Yellow,
    Iceblight    = HudApi.Color.White,
    Wyvernride   = HudApi.Color.Skyblue
}





-- X / Y / W / S / %L / C

local function drawInfoHud(data)
    local linearT = os.clock()/2000

    local sceneman = sdk.get_native_singleton("via.SceneManager")
    if not sceneman then 
        return
    end

    local sceneview = sdk.call_native_func(sceneman, sdk.find_type_definition("via.SceneManager"), "get_MainView")
    if not sceneview then
        return
    end

    local size = sceneview:call("get_Size")
    if not size then
        return
    end

    local screen_w = size:get_field("w")
    if not screen_w then
        return
    end
    -- == Top == --
    local curry = (bar.defaultHeight + settings.TopOffset)
    local rightMargin = screen_w - 60 - 185 + settings.RightOffset
    local sizeType
    data.size = data.size or -64
    if data.sizeSmall then
        sizeType = 
            data.size <= data.sizeSmall and 1 or
            data.size >= data.sizeKing and 3 or
            data.size >= data.sizeBig and 2 or
            0
    else
        sizeType = 0
    end

    -- Nameplate --
    if #HudApi.Namebar == 0 then

        table.insert(HudApi.Namebar, 
        {
            true, 
            data.name, 
            data.state,
            data.size or -64,
            sizeType,
            rightMargin - 275 + (25 * settings.Scale), curry,
            settings.Scale
        }
        )

    end

    if #HudApi.Gauges > 0 then return end

    curry = curry + 23 + (20 * settings.Scale)
    -- Health --
    local info = data.hpinfo
    local percent = info.current/info.max
    local textual = "Health: "..math.floor(info.current) .. "/" .. math.floor(info.max)
    local capturable = info.current <= info.capture

    textual = capturable and textual .. " (Capturable)" or textual
    --curry = curry + 20
    local color = capturable and HudApi.Color.Dying or HudApi.Color.Health
    table.insert(HudApi.Gauges,{true, rightMargin - bar.width, curry, (bar.width * 2) + 10, settings.Scale, percent, color, label = textual})
    curry = curry + (bar.height * settings.Scale)

    local info = data.staminfo
    local textual = "Stamina: " .. math.floor(info.current+0.5) .. "/" .. math.floor(info.max+0.5)
    local percent
    if info.status == 0 then
        percent = info.current/info.max
    else
        percent = (info.timer)/info.duration
    end
    percent = percent > 1 and 1 or (percent < 0 and 0 or percent)
    local color = info.status == 0 and HudApi.Color.Stamina or LinearGradient(HudApi.Color.Red, HudApi.Color.Stamina,linearT)
    table.insert(HudApi.Gauges,{true, rightMargin - bar.width, curry, (bar.width * 2) + 10, settings.Scale, percent, color, true, label = textual})
    curry = curry + (bar.height * settings.Scale) + bar.outermargin

    -- == Left Side  == --
    -- Init --
    local curry = (bar.defaultHeight + settings.TopOffset) + 20 * settings.Scale + (bar.height * settings.Scale) + bar.outermargin + 23 + 20
    local rightMargin = screen_w - 60 - 185 + settings.RightOffset

    -- Anger --
    local info = data.angerinfo
    local percent
    local textual
    if info.status == 0 then
        percent = info.current/info.max
        textual = "Rage: " .. math.floor(info.current+0.5) .. "/" .. math.floor(info.max+0.5)
    else
        percent = (info.duration-info.timer)/info.duration
        textual = "Rage: " .. math.floor(info.duration+0.5) .. "/" .. math.floor(info.timer+0.5)
    end
    percent = percent > 1 and 1 or (percent < 0 and 0 or percent)
    local color = info.status == 0 and HudApi.Color.Red or LinearGradient(HudApi.Color.Red, HudApi.Color.White,linearT)
    table.insert(HudApi.Gauges,{true, rightMargin-bar.width, curry, bar.width - bar.middlespace, settings.Scale, percent, color, label = textual})

    curry = curry + (bar.height * settings.Scale) + bar.outermargin

    -- Status --
    for i,info in pairs(data.statusdat) do
        if info.activeTimer == 0 then
            percent = info.stocks.player/info.limits.player
        else
            percent = (info.activeTimer)/info.activeTime
        end
        if percent > 0 then
            local textual
            if info.activeTimer == 0 then
                textual = info.name..": " .. math.floor(info.stocks.player+0.5) .. "/" .. math.floor(info.limits.player+0.5)
            else
                textual = info.name..": " .. math.floor(info.activeTimer+0.5) .. "/" .. math.floor(info.activeTime+0.5)
            end
            if info.activeTimer == 0 and info.cooldown == 0 then
                table.insert(HudApi.Gauges,{true, rightMargin-bar.width, curry, bar.width - bar.middlespace, settings.Scale, percent, statuscolors[info.name], label = textual})
            elseif info.name == "Wyvernride" and info.cooldown > 0 then
                percent = info.cooldown/300
                table.insert(HudApi.Gauges,{true, rightMargin-bar.width, curry, bar.width - bar.middlespace, settings.Scale, percent, LinearGradient(statuscolors[info.name], HudApi.Color.Blue,linearT), label = textual})
            else
                table.insert(HudApi.Gauges,{true, rightMargin-bar.width, curry, bar.width - bar.middlespace, settings.Scale, percent, LinearGradient(statuscolors[info.name], HudApi.Color.White,linearT), label = textual})
            end
            curry = curry + (bar.height * settings.Scale) + bar.outermargin
        end
    end


    -- == Right Side == --
    -- Init --
    local curry = (bar.defaultHeight + settings.TopOffset) + 20 * settings.Scale + (bar.height * settings.Scale) + bar.outermargin + 23 + 20
    local rightMargin = screen_w - 60 + bar.middlespace + settings.RightOffset

    -- Parts --
    
    for i,info in pairs(data.parts) do
        local percent = (info.current*(info.breaklevelmax-info.breaklevel))/(info.max*info.breaklevelmax)
        local textual = info.name .. ": ".. math.floor(info.current*(info.breaklevelmax-info.breaklevel)+0.5) .. "/" .. math.floor(info.max*info.breaklevelmax + 0.5)
        table.insert(HudApi.Gauges, {true, rightMargin-bar.width, curry, bar.width - bar.middlespace, settings.Scale, percent, HudApi.Color.Gray, true, label = textual})
        curry = curry + (bar.height * settings.Scale) + bar.outermargin
    end
end

function getParamArray(param, func)
    local data = param:call(func);
    local datas = {};

    if data ~= nil then
        for i = 0, (data:get_size() - 1), 1 do
            local label = i == 0 and "player" or "wirebug"
            datas[label] = data:get_element(i):get_field("mValue");
        end
    end

    return datas;
end

-- Just a wrapper around call, was going to be something more eventually but ended up not needing, too lazy to refactor it
function getParamValue(param, func)
    local data = param:call(func);

    return data;
end

-- Retrieves all the relevant data for a given status damage field in one easy to get table
function getStatusData(damageField, statusName, statusId) 
    local param = damageField:get_field(statusName);

    if param == nil then
        return {}
    end
    
    local results = {
        name          = statusId,
        names         = statusName,
        cooldown      = 0,
        stocks        = getParamArray(param, "get_Stock"),         -- Stock is the current status damage to the target
        limits        = getParamArray(param, "get_Limit"),         -- Limit is the current threshold at which the status will trigger
        activeTime    = getParamValue(param, "get_ActiveTime"),    -- How long the status will be active
        activeTimer   = getParamValue(param, "get_ActiveTimer"),   -- If the status is active, contains a countdown until inactive
    };
    return results
end

local inform = {}
inform.parts = {}
inform.hpinfo = {}
inform.angerinfo = {}
inform.staminfo = {}
inform.statusdat = {}
inform.marioinf = {}

local function updateEnemies()

    local cameraManager = sdk.get_managed_singleton("snow.CameraManager")
    if cameraManager == nil then
        debug = "no camm"
        return
    end
    local targetCam = cameraManager:call("get_RefTargetCameraManager")
    if targetCam == nil then
        debug = "no tcamm"
        return
    end

    local enemyManager = sdk.get_managed_singleton("snow.enemy.EnemyManager")
    if not enemyManager then 
        debug = "noEnemyManager"
        return 
    end

    local enemy = targetCam:call("GetTargetEnemy")
    if enemy == nil then
        debug = "no enemy"
        return
    end

    local damageField = enemy:get_field("<DamageParam>k__BackingField");
    if damageField == nil then
        debug = "no dmg"
        return
    end

    local physField = enemy:call("get_PhysicalParam")
    if physField == nil then
        debug = "no phy"
        return
    end

    local statField = enemy:call("get_StatusParam")
    if statField == nil then
        debug = "no stat"
        return
    end

    local angField = enemy:call("get_AngerParam")
    if angField == nil then
        debug = "no ang"
        return
    end
    local stamField = enemy:call("get_StaminaParam")
    if stamField == nil then
        debug = "no sta"
        return
    end
    local marField = enemy:call("get_MarioParam")
    if marField == nil then
        debug = "no mar"
        return
    end

    local messageManager = sdk.get_managed_singleton("snow.gui.MessageManager");
    if not messageManager then
        debug = "no mes"
        return
    end

    local enemy_type = enemy:get_field("<EnemyType>k__BackingField")
    if not enemy_type then
        debug = "no typ"
        return
    end

    local userdatas = enemy:get_field("<RefEmUserData>k__BackingField")
    if not userdatas then
        debug = "no usd"
        return
    end

    local partloss = enemy:get_field("<RefPartsLossHagiPopBehavior>k__BackingField")
    if not partloss then
        debug = "no prt"
        return
    end
    debug = "Success"
    
    inform.name = tostring(messageManager:call("getEnemyNameMessage", enemy_type))
    
    inform.state = statField:call("get_Mode")
    
    local sizeData = enemyManager:call("findEnemySizeInfo", enemy_type)
    inform.size = enemy:call("get_MonsterListRegisterScale")
    if sizeData then
        inform.sizeBase = sizeData:call("get_BaseSize")
        inform.sizeSmall = sizeData:call("get_SmallBorder")
        inform.sizeBig = sizeData:call("get_BigBorder")
        inform.sizeKing = sizeData:call("get_KingBorder")
    end

    local anginfo = {}
    anginfo.max = angField:get_field("<LimitAnger>k__BackingField")
    anginfo.current = angField:get_field("<AngerPoint>k__BackingField")
    anginfo.duration = angField:get_field("<TimerAnger>k__BackingField")
    anginfo.timer = angField:get_field("<Timer>k__BackingField")
    anginfo.status = angField:get_field("<StateParam>k__BackingField")
    inform.angerinfo = anginfo

    local stam = {}
    stam.max = stamField:get_field("<DefaultStamina>k__BackingField")
    stam.current = stamField:get_field("<Stamina>k__BackingField")
    stam.duration = stamField:get_field("<TiredSec>k__BackingField")
    stam.timer = stamField:get_field("<Timer>k__BackingField")
    stam.status = stamField:get_field("<StateParam>k__BackingField")
    inform.staminfo = stam

    local breakdata = userdatas:get_field("_enemyBreakRewardData"):get_field("EnemyPartsBreakRewardInfos"):get_elements()
    local partsDamage = {}
    local vitalparam = physField:call("getVital", 0, 0)
    if not vitalparam then return end
    local partInfo = damageField:get_field("_EnemyPartsDamageInfo"):call("get_PartsInfo"):get_elements()
    
    local hpinfo = {}
    hpinfo.current = vitalparam:call("get_Current")
    hpinfo.max = vitalparam:call("get_Max")
    hpinfo.capture = physField:call("get_CaptureHpVital")

    inform.hpinfo = hpinfo
    
    for i = 1,16 do
        breaklevel = partInfo[i]:call("get_PartsBreakDamageLevel")
        breaklevelmax = partInfo[i]:call("get_PartsBreakDamageMaxLevel")
        if breaklevelmax >= 0 then
            local partVitalParam = physField:call("getVital", 2, i-1)
            local partId
            for ix,v in pairs(breakdata) do
                if not partId and v then
                    local conditionList = v
                        :get_field("PartsBreakConditionList")
                        :get_elements()
                    if conditionList then
                        for ixx,vx in pairs(conditionList) do
                            if vx:get_field("_PartsGroup") == i-1 then
                                partId = v:get_field("_BrokenPartsType")
                            end
                        end
                    end
                end
            end
            local partname_guid = messageManager:call("getEnemyBrokenTypeMessage", partId, enemy_type, true)
            --partname_guid = messageManager:call("getOtomoAirouMovementTargetExplain", 1)
            local partname = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid, via.Language)"):call(nil, partname_guid, 1)
            
            if breaklevelmax > 0 then
                local info = {}
                if partname == "Broke {0}'s head" then partname = "Breakable Object" end
                info.name = partname
                info.current = partVitalParam:call("get_Current")
                info.max = partVitalParam:call("get_Max")
                info.breaklevel = breaklevel
                info.breaklevelmax = breaklevelmax
                table.insert(inform.parts, info)
            end
        end
    end

    for i = 1,16 do
        local partVitalParam = physField:call("getVital", 3, i-1)
        if partVitalParam:call("get_Max") > 0 then
            local breaklevel = partloss:call("get_Item",0)
            breaklevel = (breaklevel:call("get_IsStart")) and 1 or 0 
            local breaklevelmax = 1
            local info = {}
            info.name = "Tail (Severable)"
            info.current = partVitalParam:call("get_Current")
            info.max = partVitalParam:call("get_Max")
            info.breaklevel = tonumber(breaklevel)
            info.breaklevelmax = breaklevelmax
            table.insert(inform.parts, info)
        end
    end

    statusinf = {
        getStatusData(damageField, "_PoisonParam",      "Poison"        ),
        getStatusData(damageField, "_StunParam",        "Stun"          ),
        getStatusData(damageField, "_ParalyzeParam",    "Paralysis"     ),
        getStatusData(damageField, "_SleepParam",       "Sleep"         ),
        getStatusData(damageField, "_BlastParam",       "Blast"         ),
        getStatusData(damageField, "_StaminaParam",     "Exhaust"       ),
        getStatusData(damageField, "_FireParam",        "Fireblight"    ),
        getStatusData(damageField, "_WaterParam",       "Waterblight"   ),
        getStatusData(damageField, "_ThunderParam",     "Thunderblight" ),
        getStatusData(damageField, "_IceParam",         "Iceblight"     ),
    };
    mariodat = getStatusData(damageField, "_MarionetteStartParam",  "Wyvernride")
    mariodat.cooldown = marField:get_field("<MarioCoolTimerSec>k__BackingField")
    table.insert(statusinf, mariodat)
    inform.statusdat = statusinf
end




local typedef = sdk.find_type_definition("snow.enemy.EnemyCharacterBase")
local update_method = typedef:get_method("update")

local called_this_frame = false

sdk.hook(update_method, 
function(args)
    if called_this_frame == false then
        called_this_frame = true
        updateEnemies()
    end
end)
local enabled = true

local getSlider = sdk.find_type_definition("snow.gui.GuiManager"):get_method("get_ItemSliderState")

re.on_frame(function()
    if allManagersRetrieved == false then
        local success = true
        for i,v in pairs(gm) do
            v.d = sdk.get_managed_singleton(v.n)
            if v.d == nil then success = false end
        end
        allManagersRetrieved = success
    end

    if inform.hpinfo.current and enabled and allManagersRetrieved and called_this_frame and settings.Enabled then
        --if gm.GuiManager.d:get_field("InvisibleAllGUI") == false then
            bar.labels = getSlider:call(gm.GuiManager.d) == 1 and true or false
            drawInfoHud(inform)
            inform = {}
            inform.parts = {}
            inform.hpinfo = {}
            inform.angerinfo = {}
            inform.staminfo = {}
            inform.statusdat = {}
            inform.marioinf = {}
        --end
    end
    called_this_frame = false
end)

re.on_draw_ui(function()
    if imgui.tree_node("MAPHud") then
        _,settings.Scale =          imgui.slider_float("Scale", settings.Scale, 0.5, 2, string.format("%.1f", settings.Scale))
        _,settings.RightOffset =    imgui.slider_int("Right offset", settings.RightOffset, -200, 200)
        _,settings.TopOffset =      imgui.slider_int("Top offset", settings.TopOffset, -200, 200)
        _,settings.AlwaysDraw =     imgui.checkbox("Always detailed version", settings.AlwaysDraw)
        _,settings.Enabled =        imgui.checkbox("Enabled", settings.Enabled)
        imgui.tree_pop();
    end
end)

re.on_config_save(function()
    json.dump_file("MAPHud Settings.json", settings)
end)