local RSGCore = exports['rsg-core']:GetCoreObject()

local ComponentsMale = {}
local ComponentsFemale = {}
local playerSkin = {}

local clothingData =
{
    currentAccessories  = 0,
    currentArmor        = 0,
    currentBadges       = 0,
    currentBelts        = 0,
    currentBoots        = 0,
    currentBuckles      = 0,
    currentChaps        = 0,
    currentCloaks       = 0,
    currentClosedCoats  = 0,
    currentCoats        = 0,
    currentEyewear      = 0,
    currentFoldPants    = 0,
    currentGauntlets    = 0,
    currentGlove        = 0,
    currentGunbelts     = 0,
    currentHair         = 0,
    currentHat          = 0,
    currentHolsterLeft  = 0,
    currentLoadouts     = 0,
    currentMasks        = 0,
    currentNeckties     = 0,
    currentNeckwear     = 0,
    currentPants        = 0,
    currentPonchos      = 0,
    currentSatchels     = 0,
    currentShirt        = 0,
    currentSkirts       = 0,
    currentSleeve       = 0,
    currentSuspenders   = 0,
    currentVest         = 0,
}

local RemoveItemFromPedByCategory = function(ped, clothCategory)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, clothCategory, true, true, true)
end

local IsPedUsingComponent = function(ped, clothCategory)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, clothCategory)
end

local NativeFixMeshIssues = function(ped, categoryHash)
    Citizen.InvokeNative(0x59BD177A1A48600A, ped, categoryHash)
end

local NativeHasPedComponentLoaded = function(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

local NativeGetPedComponentCategory = function(isFemale, componentHash)
    return Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, isFemale, true)
end

local NativeUpdatePedVariation = function(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)

    while not NativeHasPedComponentLoaded(ped) do
        Wait(1)
    end
end

local NativeSetPedComponentEnabled = function(ped, componentHash, immediately, isMp)
    local categoryHash = NativeGetPedComponentCategory(not IsPedMale(ped), componentHash)

    NativeFixMeshIssues(ped, categoryHash)

    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, isMp, true)

    NativeUpdatePedVariation(ped)
end

local UpdateWearableState = function(ped, clothHash, wearableHash, p3, p4 , p5)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, clothHash, wearableHash, p3, p4, p5)

    NativeUpdatePedVariation(ped)
end

local GetSkinColorFromBodySize = function(body, color)
    for i = 1, #Config.SkinColours do
        local skin = Config.SkinColours[i]
        local bodies = skin.body

        if body == bodies then
            local col = skin.colour

            if color == col then
                local index = skin.index

                return index
            end
        end
    end

    if color == 1 then
        return 13
    elseif color == 2 then
        return 16
    elseif color == 3 then
        return 15
    elseif color == 4 then
        return 17
    elseif color == 5 then
        return 14
    elseif color == 6 then
        return 18
    end
end

local LoadUpperBody = function(target, data)
    local output = GetSkinColorFromBodySize(tonumber(data.body_size), tonumber(data.skin_tone))
    local torso = nil

    if not output then return end

    if IsPedMale(target) then
        if ComponentsMale['BODIES_UPPER'] then
            torso = ComponentsMale['BODIES_UPPER'][output]
        end

        if torso then
            NativeSetPedComponentEnabled(target, tonumber(torso), false, true)
        end

        return
    end

    if ComponentsFemale['BODIES_UPPER'] then
        torso = ComponentsFemale['BODIES_UPPER'][output]
    end

    if torso then
        NativeSetPedComponentEnabled(target, tonumber(torso), false, true)
    end
end

local LoadLowerBody = function(target, data)
    local output = GetSkinColorFromBodySize(tonumber(data.body_size), tonumber(data.skin_tone))
    local legs = nil

    if not output then return end

    if IsPedMale(target) then
        if ComponentsMale['BODIES_LOWER'] then
            legs = ComponentsMale['BODIES_LOWER'][output]
        end

        if legs then
            NativeSetPedComponentEnabled(target, tonumber(legs), false, true)
        end

        return
    end

    if ComponentsFemale['BODIES_LOWER'] then
        legs = ComponentsFemale['BODIES_LOWER'][output]
    end

    if legs then
        NativeSetPedComponentEnabled(target, tonumber(legs), false, true)
    end
end

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded')
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    Wait(3000)

    RSGCore.Functions.TriggerCallback('rsg-wardrobe:server:getPlayerSkin', function(result)
        local ped = PlayerPedId()
        local male = IsPedMale(ped)

        if male then
            local bodyComponents = exports['rsg-appearance']:GetBodyComponents()
            ComponentsMale = bodyComponents[1]
            playerSkin = json.decode(result.skin)

            return
        end

        local bodyComponents = exports['rsg-appearance']:GetBodyComponents()
        ComponentsFemale= bodyComponents[1]
        playerSkin = json.decode(result.skin)
    end)
end)

RegisterNetEvent('rsg-wardrobe:client:OnOffClothing', function(clothingName)
    local playerPed = PlayerPedId()

    for i = 1, #Config.ClothingComponents do
        local category = Config.ClothingComponents[i]
        local name = category.name
        local comps = category.comps
        local hash = category.hash
        local data = category.data

        if clothingName == name then
            if name == 'pants' then
                local male = IsPedMale(playerPed)

                if not male then
                    NativeSetPedComponentEnabled(playerPed, 4726031, false, true) -- Temporary skirt
                    Citizen.InvokeNative(0xD710A5007C2AC539, playerPed, 2699275135, 0) -- Skirts
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, playerPed, 0, 1, 1, 1, 0)
                end

                -- Need to remove boot as well to avoid blank lower body
                if clothingData['currentBoots'] == 0 then
                    clothingData['currentBoots'] = exports['rsg-clothes']:GetClothesCurrentComponentHash('boots')
                    local isWearingComps = IsPedUsingComponent(playerPed, 2004797167)

                    if isWearingComps then
                        RemoveItemFromPedByCategory(playerPed, 2004797167)
                    end
                else
                    NativeSetPedComponentEnabled(playerPed, clothingData['currentBoots'], false, true)

                    clothingData['currentBoots'] = 0
                end

                if clothingData[data] == 0 then
                    clothingData[data] = exports['rsg-clothes']:GetClothesCurrentComponentHash(comps)
                    local isWearingComps = IsPedUsingComponent(playerPed, hash)

                    if isWearingComps then
                        RemoveItemFromPedByCategory(playerPed, hash)

                        Wait(10)

                        LoadLowerBody(playerPed, playerSkin)
                    end
                else
                    NativeSetPedComponentEnabled(playerPed, clothingData[data], false, true)

                    clothingData[data] = 0
                end

                goto continue
            end

            if name == 'sleeve' then
                if clothingData[data] == 0 then
                    clothingData[data] = exports['rsg-clothes']:GetClothesCurrentComponentHash(comps)

                    UpdateWearableState(playerPed, clothingData[data], `Closed_Collar_Rolled_Sleeve`, 0, true , 1)
                else
                    UpdateWearableState(playerPed, clothingData[data], `BASE`, 0, true , 1)

                    clothingData[data] = 0
                end

                goto continue
            end

            if clothingData[data] == 0 then
                clothingData[data] = exports['rsg-clothes']:GetClothesCurrentComponentHash(comps)
                local isWearingComps = IsPedUsingComponent(playerPed, hash)

                if isWearingComps then
                    RemoveItemFromPedByCategory(playerPed, hash)

                    if name == 'pants'
                    or name == 'eyewear'
                    or name == 'belts'
                    or name == 'cloaks'
                    or name == 'chaps'
                    or name == 'masks'
                    or name == 'neckwear'
                    or name == 'accessories'
                    or name == 'gauntlets'
                    or name == 'neckties'
                    or name == 'loadouts'
                    or name == 'suspenders'
                    or name == 'satchels'
                    or name == 'gunbelts'
                    or name == 'buckles'
                    or name == 'skirts'
                    or name == 'armor'
                    or name == 'hair_accessories'
                    then
                        Wait(10)

                        LoadUpperBody(playerPed, playerSkin)
                    end
                end
            else
                NativeSetPedComponentEnabled(playerPed, clothingData[data], false, true)

                clothingData[data] = 0
            end

            ::continue::
        end
    end
end)

-- Remove all clothing
RegisterNetEvent('rsg-wardrobe:client:removeAllClothing', function()
    local ped = PlayerPedId()
    local male = IsPedMale(ped)

    TriggerServerEvent('rsg-weapons:server:RemoveAllObjects')

    for i = 1, #Config.ClothingComponents do
        local category = Config.ClothingComponents[i]
        local comps = category.hash

        if comps ~= 0 then
            local wearing = IsPedUsingComponent(ped, comps)

            if wearing then
                RemoveItemFromPedByCategory(ped, comps)
            end

            if not male and comps == 2699275135 then
                NativeSetPedComponentEnabled(ped, 4726031, false, true) -- Temporary skirt
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, 2699275135, 0) -- Skirts
                Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
            end
        end
    end
end)