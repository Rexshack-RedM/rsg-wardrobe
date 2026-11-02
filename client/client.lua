local RSGCore = exports['rsg-core']:GetCoreObject()

-- Body components from rsg-character ({ male, female })
local BodyComponents = { {}, {} }
local playerSkin = {}
local busy = false

-- Hash of each item we took off, keyed by Config.ClothingComponents[].data (0 = not removed by us)
local clothingData = {}
local componentsByName = {}

for i = 1, #Config.ClothingComponents do
    local c = Config.ClothingComponents[i]
    clothingData[c.data] = 0
    componentsByName[c.name] = c
end

local SHIRT_HASH  = 539411565
local BOOTS_HASH  = 2004797167
local SKIRTS_HASH = 2699275135
local TEMP_SKIRT  = 4726031

-- Shirt wearable states toggled by /sleeve, /collar1, /collar2
local WearableStates = {
    sleeve  = `closed_collar_rolled_sleeve`,
    collar1 = `open_collar_rolled_sleeve`,
    collar2 = `open_collar_full_sleeve`,
}

-- Removing these exposes the legs / torso, so the bare body part is re-applied
local ReloadLower = { chaps = true, skirts = true, boots = true }
local ReloadUpper = {
    eyewear = true, belts = true, cloaks = true, masks = true, neckwear = true, accessories = true,
    gauntlets = true, neckties = true, loadouts = true, suspenders = true, satchels = true,
    gunbelts = true, buckles = true, armor = true, hair_accessories = true,
    jewelry_rings_left = true, jewelry_rings_right = true, holster_left = true, holster_right = true,
}

----------------------------------------------------------------
-- Natives
----------------------------------------------------------------
local function GetCachedHash(comps)
    local cache = exports['rsg-character']:GetClothesCache()
    local entry = cache and cache[comps]
    if entry and entry.hash and entry.hash ~= 0 then return entry.hash end
    return nil
end

local function ResetClothingData()
    for k in pairs(clothingData) do clothingData[k] = 0 end
    LocalPlayer.state:set('wardrobeRemoved', {}, true)
end

local function RemoveItemFromPedByCategory(ped, category)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, category, true, true, true)
end

local function IsPedUsingComponent(ped, category)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, category)
end

local function UpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    local timeout = GetGameTimer() + 2000
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) and GetGameTimer() < timeout do
        Wait(1)
    end
end

local function SetPedComponentEnabled(ped, componentHash)
    local category = Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, not IsPedMale(ped), true)
    Citizen.InvokeNative(0x59BD177A1A48600A, ped, category)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, false, true, true)
    UpdatePedVariation(ped)
end

local function UpdateWearableState(ped, clothHash, wearableHash)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, clothHash, wearableHash, 0, true, 1)
    UpdatePedVariation(ped)
end

local function ApplyTemporarySkirt(ped)
    SetPedComponentEnabled(ped, TEMP_SKIRT)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, SKIRTS_HASH, 0)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

----------------------------------------------------------------
-- Bare body parts
----------------------------------------------------------------
local function GetSkinIndex(body, colour)
    for i = 1, #Config.SkinColours do
        local s = Config.SkinColours[i]
        if s.body == body and s.colour == colour then return s.index end
    end
    -- unknown body size: fall back to body 3 for this colour
    for i = 1, #Config.SkinColours do
        local s = Config.SkinColours[i]
        if s.body == 3 and s.colour == colour then return s.index end
    end
end

local function LoadBodyPart(ped, part)
    local index = GetSkinIndex(tonumber(playerSkin.body_size), tonumber(playerSkin.skin_tone))
    if not index then return end
    local comps = BodyComponents[IsPedMale(ped) and 1 or 2]
    local hash = comps and comps[part] and comps[part][index]
    if hash then SetPedComponentEnabled(ped, tonumber(hash)) end
end

local function LoadPlayerSkin()
    RSGCore.Functions.TriggerCallback('rsg-wardrobe:server:getPlayerSkin', function(skin)
        if not skin then return end
        BodyComponents = exports['rsg-character']:GetBodyComponents() or { {}, {} }
        playerSkin = json.decode(skin) or {}
    end)
end

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    Wait(3000)
    ResetClothingData()
    LoadPlayerSkin()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() or not LocalPlayer.state.isLoggedIn then return end
    Wait(1000)
    LoadPlayerSkin()
end)

-- Any outfit applied by rsg-character makes our toggle memory stale
AddEventHandler('rsg-character:client:ApplyClothes', ResetClothingData)

----------------------------------------------------------------
-- Toggling
----------------------------------------------------------------
-- Takes off (and remembers) or puts back a single category. Returns true if it took something off.
local function ToggleCategory(ped, c, noEquip)
    if clothingData[c.data] ~= 0 then
        SetPedComponentEnabled(ped, clothingData[c.data])
        clothingData[c.data] = 0
        return false
    end
    if IsPedUsingComponent(ped, c.hash) then
        clothingData[c.data] = GetCachedHash(c.comps) or 0
        RemoveItemFromPedByCategory(ped, c.hash)
        return true
    end
    -- not wearing it and nothing remembered: re-equip the outfit's item if there is one
    if noEquip then return false end
    local cached = GetCachedHash(c.comps)
    if cached then SetPedComponentEnabled(ped, cached) end
    return false
end

-- Plays an anim (from Config) on the upper body and waits `waitMs`. Skipped on horseback, in vehicles or when dead.
function WardrobePlayAnim(anim, waitMs)
    local ped = PlayerPedId()
    if not anim or IsPedOnMount(ped) or IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then return end
    RequestAnimDict(anim.dict)
    local timeout = GetGameTimer() + 2000
    while not HasAnimDictLoaded(anim.dict) and GetGameTimer() < timeout do Wait(10) end
    if not HasAnimDictLoaded(anim.dict) then return end
    TaskPlayAnim(ped, anim.dict, anim.clip, 4.0, -4.0, anim.duration or -1, 31, 0.0, false, false, false)
    Wait(waitMs or anim.duration or 1000)
    RemoveAnimDict(anim.dict)
end

local function toggleClothing(clothingName)
    local c = componentsByName[clothingName]
    if not c or busy then return end
    busy = true
    local ped = PlayerPedId()

    -- animated hat on/off (anim from rdr3_discoveries ingameanims_list.lua)
    local hatAnim = c.name == 'hat' and Config.HatAnimation.Enabled
        and (clothingData[c.data] ~= 0 or IsPedUsingComponent(ped, c.hash))
    if hatAnim then
        WardrobePlayAnim(Config.HatAnimation.Anim, Config.HatAnimation.SwapAt)
    end

    local state = WearableStates[c.name]
    if state then
        if clothingData[c.data] == 0 then
            local cached = GetCachedHash(c.comps)
            if cached and IsPedUsingComponent(ped, SHIRT_HASH) then
                clothingData[c.data] = cached
                UpdateWearableState(ped, cached, state)
            end
        else
            UpdateWearableState(ped, clothingData[c.data], `BASE`)
            clothingData[c.data] = 0
        end

    elseif c.name == 'pants' then
        if not IsPedMale(ped) then ApplyTemporarySkirt(ped) end
        -- boots go with the pants to avoid a blank lower body
        ToggleCategory(ped, componentsByName.boots, true)
        if ToggleCategory(ped, c, true) then
            Wait(10)
            LoadBodyPart(ped, 'BODIES_LOWER')
        end

    elseif ToggleCategory(ped, c) then
        Wait(10)
        if ReloadLower[c.name] then
            LoadBodyPart(ped, 'BODIES_LOWER')
        elseif ReloadUpper[c.name] then
            LoadBodyPart(ped, 'BODIES_UPPER')
        end
    end

    if hatAnim then
        Wait(Config.HatAnimation.FinishAfter or 0)
        ClearPedSecondaryTask(ped)
    end

    -- share which slots are off (other resources / UI can read it)
    local removed = {}
    for name, comp in pairs(componentsByName) do
        if clothingData[comp.data] ~= 0 then removed[#removed + 1] = name end
    end
    LocalPlayer.state:set('wardrobeRemoved', removed, true)

    busy = false
end

-- Per-slot state for the wardrobe menu
exports('GetClothingState', function()
    local ped = PlayerPedId()
    local out = {}
    for i = 1, #Config.ClothingComponents do
        local c = Config.ClothingComponents[i]
        local removed = clothingData[c.data] ~= 0
        local worn
        if WearableStates[c.name] then
            worn = removed -- shirt style toggles are "on" when active
        else
            worn = c.hash ~= 0 and IsPedUsingComponent(ped, c.hash) and true or false
        end
        out[#out + 1] = { name = c.name, worn = worn, removed = removed, available = worn or removed or GetCachedHash(c.comps) ~= nil }
    end
    return out
end)

-- Keep removed items off after being revived (rsg-medic re-applies the outfit)
RegisterNetEvent('rsg-medic:client:revive', function()
    if not Config.KeepRemovedOnRevive then return end
    local toRemove = {}
    for name, comp in pairs(componentsByName) do
        if clothingData[comp.data] ~= 0 and not WearableStates[name] then toRemove[#toRemove + 1] = name end
    end
    if #toRemove == 0 then return end
    Wait(2500)
    local ped = PlayerPedId()
    for i = 1, #toRemove do
        local c = componentsByName[toRemove[i]]
        clothingData[c.data] = 0
        if c.hash ~= 0 and IsPedUsingComponent(ped, c.hash) then toggleClothing(c.name) end
    end
end)

RegisterNetEvent('rsg-wardrobe:client:OnOffClothing', toggleClothing)
exports('ToggleClothing', toggleClothing)

local function removeAllClothing()
    local ped = PlayerPedId()
    local male = IsPedMale(ped)

    TriggerServerEvent('rsg-weapons:server:RemoveAllObjects')

    for i = 1, #Config.ClothingComponents do
        local hash = Config.ClothingComponents[i].hash
        if hash ~= 0 then
            if IsPedUsingComponent(ped, hash) then RemoveItemFromPedByCategory(ped, hash) end
            if not male and hash == SKIRTS_HASH then ApplyTemporarySkirt(ped) end
        end
    end

    ResetClothingData()
end

local function dressPlayer(clothes)
    if type(clothes) ~= 'table' or not next(clothes) then return end
    removeAllClothing()
    Wait(100)
    TriggerEvent('rsg-character:client:ApplyClothes', clothes)
end

RegisterNetEvent('rsg-wardrobe:client:dress', dressPlayer)
RegisterNetEvent('rsg-wardrobe:client:removeAllClothing', removeAllClothing)
exports('RemoveAllClothing', removeAllClothing)

exports('IsWearing', function(name)
    local c = componentsByName[name]
    if not c or c.hash == 0 then return false end
    return IsPedUsingComponent(PlayerPedId(), c.hash)
end)
