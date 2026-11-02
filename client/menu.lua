local RSGCore = exports['rsg-core']:GetCoreObject()
local menuOpen = false
local careBusy = false

local function notify(key, ntype)
    RSGCore.Functions.Notify({ title = locale('wardrobe_title'), description = locale(key), type = ntype or 'inform', duration = 4000 })
end

-- Dirt level 0..100 (_GET_PED_DIRT_LEVEL 0x0105FEE8F9091255, natives/db/PED.md)
local function getDirt()
    local d = Citizen.InvokeNative(0x0105FEE8F9091255, PlayerPedId(), true, Citizen.ResultAsFloat()) or 0.0
    return math.floor(math.max(0.0, math.min(1.0, d)) * 100)
end

local function labels()
    local t = {}
    for i = 1, #Config.ClothingComponents do
        local n = Config.ClothingComponents[i].name
        t[n] = locale('slot_' .. n)
    end
    return t
end

local function uiText()
    local keys = {
        'wardrobe_title', 'ui_subtitle', 'ui_tab_clothing', 'ui_tab_outfits', 'ui_tab_care', 'ui_undress', 'ui_dress',
        'ui_worn', 'ui_off', 'ui_none', 'ui_save_outfit', 'ui_outfit_name', 'ui_save', 'ui_cancel', 'ui_wear', 'ui_delete',
        'ui_default', 'ui_no_outfits', 'ui_dirt', 'ui_brush', 'ui_brush_desc', 'ui_dry', 'ui_dry_desc', 'ui_hattip',
        'ui_hattip_desc', 'ui_delete_confirm', 'ui_confirm',
    }
    local t = {}
    for _, k in ipairs(keys) do t[k] = locale(k) end
    return t
end

local function state()
    return {
        slots = exports['rsg-wardrobe']:GetClothingState(),
        dirt = getDirt(),
        care = Config.Care.Enabled,
        outfits = Config.Outfits.Enabled,
    }
end

local function closeMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('rsg-wardrobe:client:openMenu', function()
    if menuOpen or IsEntityDead(PlayerPedId()) then return end
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', text = uiText(), labels = labels(), state = state() })
end)

local function refresh() SendNUIMessage({ action = 'state', state = state() }) end

RegisterNUICallback('close', function(_, cb) closeMenu() cb('ok') end)

RegisterNUICallback('toggle', function(data, cb)
    cb('ok')
    if type(data.name) ~= 'string' then return end
    -- server applies permission + cooldown, then sends the toggle back
    TriggerServerEvent('rsg-wardrobe:server:toggle', data.name)
    SetTimeout(900, refresh)
end)

RegisterNUICallback('undress', function(_, cb)
    cb('ok')
    TriggerServerEvent('rsg-wardrobe:server:undress')
    SetTimeout(900, refresh)
end)

RegisterNUICallback('dress', function(_, cb)
    cb('ok')
    TriggerServerEvent('rsg-wardrobe:server:dress')
    SetTimeout(1500, refresh)
end)

----------------------------------------------------------------
-- Outfits (stored in rsg-character's playeroutfit table)
----------------------------------------------------------------
RegisterNUICallback('getOutfits', function(_, cb)
    cb(RSGCore.Functions.AwaitCallback('rsg-wardrobe:server:getOutfits', 5000) or {})
end)

RegisterNUICallback('saveOutfit', function(data, cb)
    cb(RSGCore.Functions.AwaitCallback('rsg-wardrobe:server:saveOutfit', 5000, tostring(data.name or '')) or false)
end)

RegisterNUICallback('deleteOutfit', function(data, cb)
    cb(RSGCore.Functions.AwaitCallback('rsg-wardrobe:server:deleteOutfit', 5000, tonumber(data.id)) or false)
end)

RegisterNUICallback('wearOutfit', function(data, cb)
    local ok = RSGCore.Functions.AwaitCallback('rsg-wardrobe:server:wearOutfit', 5000, tonumber(data.id))
    cb(ok and true or false)
    if ok then SetTimeout(1500, refresh) end
end)

----------------------------------------------------------------
-- Clothing care (anims from rdr3_discoveries ingameanims_list.lua)
----------------------------------------------------------------
local function brushOff()
    if careBusy then return end
    careBusy = true
    WardrobePlayAnim(Config.Care.BrushAnim)
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x6585D955A68452A5, ped)                    -- CLEAR_PED_ENV_DIRT
    Citizen.InvokeNative(0xE3144B932DFDFF65, ped, 0.0, -1, true, true) -- _SET_PED_DIRT_CLEANED
    if Config.Care.BrushClearsBlood then
        Citizen.InvokeNative(0x8FE22675A5A45817, ped)                -- CLEAR_PED_BLOOD_DAMAGE
    end
    ClearPedSecondaryTask(ped)
    notify('care_brushed', 'success')
    careBusy = false
end

local function dryOff()
    if careBusy then return end
    careBusy = true
    WardrobePlayAnim(Config.Care.DryAnim)
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x9C720776DAA43E7E, ped)                    -- CLEAR_PED_WETNESS
    ClearPedSecondaryTask(ped)
    notify('care_dried', 'success')
    careBusy = false
end

local function hatTip()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then return end
    -- TASK_PLAY_EMOTE_WITH_HASH 0xB31A277C1AC7B7FF; emote from kit_emotes_list.lua
    Citizen.InvokeNative(0xB31A277C1AC7B7FF, ped, 0, 0, joaat(Config.HatAnimation.TipEmote), true, true, false, false, false)
end

RegisterNUICallback('care', function(data, cb)
    cb('ok')
    if not Config.Care.Enabled then return end
    if data.action == 'brush' then
        closeMenu() brushOff()
    elseif data.action == 'dry' then
        closeMenu() dryOff()
    elseif data.action == 'hattip' then
        closeMenu() hatTip()
    end
end)

if Config.Care.Enabled then
    RegisterCommand(Config.Care.BrushCommand, brushOff, false)
    RegisterCommand(Config.Care.DryCommand, dryOff, false)
end
if Config.HatAnimation.TipCommand then
    RegisterCommand(Config.HatAnimation.TipCommand, hatTip, false)
end

exports('CleanClothes', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x6585D955A68452A5, ped)
    Citizen.InvokeNative(0xE3144B932DFDFF65, ped, 0.0, -1, true, true)
    Citizen.InvokeNative(0x9C720776DAA43E7E, ped)
end)
exports('OpenWardrobe', function() TriggerEvent('rsg-wardrobe:client:openMenu') end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and menuOpen then SetNuiFocus(false, false) end
end)
