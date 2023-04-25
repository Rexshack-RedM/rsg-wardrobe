local RSGCore = exports['rsg-core']:GetCoreObject()

local ComponentsMale = {}
local ComponentsFemale = {}
local playerSkin = {}

local clothingData = {
    currentHat = "",
    currentShirt = "",
    currentPants = "",
    currentBoots = "",
    currentCoats = "",
    currentClosedCoats = "",
    currentGlove = "",
    currentVest = "",
    currentPonchos = "",
    currentSleeve = "",
    currentFoldPants = "",
    currentEyewear = "",
    currentBelts = "",
    currentCloaks = "",
    currentChaps = "",
    currentBadges = "",
    currentMasks = "",
    currentNeckwear = "",
    currentAccessories = "",
    currentGauntlets = "",
    currentNeckties = "",
    currentLoadouts = "",
    currentSuspenders = "",
    currentSatchels = "",
    currentGunbelts = "",
    currentBuckles = "",
    currentSkirts = "",
    currentArmor = "",
    currentHair = "",  
}

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded')
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    RSGCore.Functions.TriggerCallback('rsg-wardrobe:server:getPlayerSkin', function(result)
        local ped = PlayerPedId()
        if IsPedMale(ped) then
            local bodyComponents = exports['rsg-appearance']:GetBodyComponents()
            ComponentsMale = bodyComponents[1]
        else
            local bodyComponents = exports['rsg-appearance']:GetBodyComponents()
            ComponentsFemale= bodyComponents[1]
        end
        playerSkin = json.decode(result.skin)
    end)
end)

RegisterNetEvent('rsg-wardrobe:client:OnOffClothing', function(clothingName)
    local playerPed = PlayerPedId()
    if clothingName == "hat" then
        if clothingData.currentHat == "" then
            clothingData.currentHat = exports['rsg-clothes']:GetClothesCurrentComponentHash("hats")
            local isWearHat = IsPedUsingComponent(playerPed, Config.ClothingCategory.Hat)
            if isWearHat then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Hat)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentHat, false, true)
            clothingData.currentHat = ""
        end
    elseif clothingName == "shirt" then
        if clothingData.currentShirt == "" then
            clothingData.currentShirt = exports['rsg-clothes']:GetClothesCurrentComponentHash("shirts_full")
            local isWearShirt = IsPedUsingComponent(playerPed, Config.ClothingCategory.Shirt)
            if isWearShirt then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Shirt)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentShirt, false, true)
            clothingData.currentShirt = ""
        end
    elseif clothingName == "pants" then
        if not IsPedMale(playerPed) then
            NativeSetPedComponentEnabled(playerPed, 0x00481D0F, false, true) -- Temporary skirt
            Citizen.InvokeNative(0xD710A5007C2AC539, playerPed, 0xA0E3AB7F, 0) -- Skirts
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerPed, 0, 1, 1, 1, 0)
        end
        --need to remove boot as well to avoid blank lower body
        if clothingData.currentBoots == "" then
            clothingData.currentBoots = exports['rsg-clothes']:GetClothesCurrentComponentHash("boots")
            local isWearBoots = IsPedUsingComponent(playerPed, Config.ClothingCategory.Boots)
            if isWearBoots then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Boots)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentBoots, false, true)
            clothingData.currentBoots = ""
        end
        if clothingData.currentPants == "" then
            clothingData.currentPants = exports['rsg-clothes']:GetClothesCurrentComponentHash("pants")
            local isWearPants = IsPedUsingComponent(playerPed, Config.ClothingCategory.Pants)
            if isWearPants then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Pants)
                Wait(10)
                LoadLowerBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentPants, false, true)
            clothingData.currentPants = ""
        end
    elseif clothingName == "boots" then
        if clothingData.currentBoots == "" then
            clothingData.currentBoots = exports['rsg-clothes']:GetClothesCurrentComponentHash("boots")
            local isWearBoots = IsPedUsingComponent(playerPed, Config.ClothingCategory.Boots)
            if isWearBoots then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Boots)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentBoots, false, true)
            clothingData.currentBoots = ""
        end
    elseif clothingName == "coats" then
        if clothingData.currentCoats == "" then
            clothingData.currentCoats = exports['rsg-clothes']:GetClothesCurrentComponentHash("coats")
            local isWearCoats = IsPedUsingComponent(playerPed, Config.ClothingCategory.Coats)
            if isWearCoats then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Coats)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentCoats, false, true)
            clothingData.currentCoats = ""
        end
    elseif clothingName == "closedcoats" then
        if clothingData.currentClosedCoats == "" then
            clothingData.currentClosedCoats = exports['rsg-clothes']:GetClothesCurrentComponentHash("coats_closed")
            local isWearClosedCoats = IsPedUsingComponent(playerPed, Config.ClothingCategory.ClosedCoats)
            if isWearClosedCoats then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.ClosedCoats)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentClosedCoats, false, true)
            clothingData.currentClosedCoats = ""
        end
    elseif clothingName == "glove" then
        if clothingData.currentGlove == "" then
            clothingData.currentGlove = exports['rsg-clothes']:GetClothesCurrentComponentHash("gloves")
            local isWearGloves = IsPedUsingComponent(playerPed, Config.ClothingCategory.Gloves)
            if isWearGloves then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Gloves)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentGlove, false, true)
            clothingData.currentGlove = ""
        end
    elseif clothingName == "ponchos" then
        if clothingData.currentPonchos == "" then
            clothingData.currentPonchos = exports['rsg-clothes']:GetClothesCurrentComponentHash("ponchos")
            local isWearPonchos = IsPedUsingComponent(playerPed, Config.ClothingCategory.Ponchos)
            if isWearPonchos then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Ponchos)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentPonchos, false, true)
            clothingData.currentPonchos = ""
        end
    elseif clothingName == "vest" then
        if clothingData.currentVest == "" then
            clothingData.currentVest = exports['rsg-clothes']:GetClothesCurrentComponentHash("vests")
            local isWearVest = IsPedUsingComponent(playerPed, Config.ClothingCategory.Vest)
            if isWearVest then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Vest)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentVest, false, true)
            clothingData.currentVest = ""
        end
    elseif clothingName == "sleeve" then

        if clothingData.currentSleeve == "" then
            clothingData.currentSleeve = exports['rsg-clothes']:GetClothesCurrentComponentHash("shirts_full")
            UpdateWearableState(playerPed, clothingData.currentSleeve, GetHashKey("Closed_Collar_Rolled_Sleeve"), 0, true , 1)
        else
            UpdateWearableState(playerPed, clothingData.currentSleeve, GetHashKey('BASE'), 0, true , 1)
            clothingData.currentSleeve = ""
        end
    elseif clothingName == "eyewear" then
        if clothingData.currentEyewear == "" then
            clothingData.currentEyewear = exports['rsg-clothes']:GetClothesCurrentComponentHash("eyewear")
            local isWearEyewear = IsPedUsingComponent(playerPed, Config.ClothingCategory.Eyewear)
            if isWearEyewear then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Eyewear)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentEyewear, false, true)
            clothingData.currentEyewear = ""
        end
    elseif clothingName == "belts" then
        if clothingData.currentBelts == "" then
            clothingData.currentBelts = exports['rsg-clothes']:GetClothesCurrentComponentHash("belts")
            local isWearBelts = IsPedUsingComponent(playerPed, Config.ClothingCategory.Belts)
            if isWearBelts then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Belts)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentBelts, false, true)
            clothingData.currentBelts = ""
        end
    elseif clothingName == "cloaks" then
        if clothingData.currentCloaks == "" then
            clothingData.currentCloaks = exports['rsg-clothes']:GetClothesCurrentComponentHash("cloaks")
            local isWearCloaks = IsPedUsingComponent(playerPed, Config.ClothingCategory.Cloaks)
            if isWearCloaks then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Cloaks)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentCloaks, false, true)
            clothingData.currentCloaks = ""
        end
    elseif clothingName == "chaps" then
        if clothingData.currentChaps == "" then
            clothingData.currentChaps = exports['rsg-clothes']:GetClothesCurrentComponentHash("chaps")
            local isWearChaps = IsPedUsingComponent(playerPed, Config.ClothingCategory.Chaps)
            if isWearChaps then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Chaps)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentChaps, false, true)
            clothingData.currentChaps = ""
        end
    elseif clothingName == "masks" then
        if clothingData.currentMasks == "" then
            clothingData.currentMasks = exports['rsg-clothes']:GetClothesCurrentComponentHash("masks")
            local isWearMasks = IsPedUsingComponent(playerPed, Config.ClothingCategory.Masks)
            if isWearMasks then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Masks)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentMasks, false, true)
            clothingData.currentMasks = ""
        end
    elseif clothingName == "neckwear" then
        if clothingData.currentNeckwear == "" then
            clothingData.currentNeckwear = exports['rsg-clothes']:GetClothesCurrentComponentHash("neckwear")
            local isWearNeckwear = IsPedUsingComponent(playerPed, Config.ClothingCategory.Neckwear)
            if isWearNeckwear then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Neckwear)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentNeckwear, false, true)
            clothingData.currentNeckwear = ""
        end
    elseif clothingName == "accessories" then
        if clothingData.currentAccessories == "" then
            clothingData.currentAccessories = exports['rsg-clothes']:GetClothesCurrentComponentHash("accessories")
            local isWearAccessories = IsPedUsingComponent(playerPed, Config.ClothingCategory.Accessories)
            if isWearAccessories then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Accessories)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentAccessories, false, true)
            clothingData.currentAccessories = ""
        end
    elseif clothingName == "gauntlets" then
        if clothingData.currentGauntlets == "" then
            clothingData.currentGauntlets = exports['rsg-clothes']:GetClothesCurrentComponentHash("gauntlets")
            local isWearGauntlets = IsPedUsingComponent(playerPed, Config.ClothingCategory.Gauntlets)
            if isWearGauntlets then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Gauntlets)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentGauntlets, false, true)
            clothingData.currentGauntlets = ""
        end
    elseif clothingName == "neckties" then
        if clothingData.currentNeckties == "" then
            clothingData.currentNeckties = exports['rsg-clothes']:GetClothesCurrentComponentHash("neckties")
            local isWearNeckties = IsPedUsingComponent(playerPed, Config.ClothingCategory.Neckties)
            if isWearNeckties then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Neckties)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentNeckties, false, true)
            clothingData.currentNeckties = ""
        end
    elseif clothingName == "loadouts" then
        if clothingData.currentLoadouts == "" then
            clothingData.currentLoadouts = exports['rsg-clothes']:GetClothesCurrentComponentHash("loadouts")
            local isWearLoadouts = IsPedUsingComponent(playerPed, Config.ClothingCategory.Loadouts)
            if isWearLoadouts then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Loadouts)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentLoadouts, false, true)
            clothingData.currentLoadouts = ""
        end
    elseif clothingName == "suspenders" then
        if clothingData.currentSuspenders == "" then
            clothingData.currentSuspenders = exports['rsg-clothes']:GetClothesCurrentComponentHash("shirts_full")
            local isWearSuspenders = IsPedUsingComponent(playerPed, Config.ClothingCategory.Suspenders)
            if isWearSuspenders then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Suspenders)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentSuspenders, false, true)
            clothingData.currentSuspenders = ""
        end
    elseif clothingName == "satchels" then
        if clothingData.currentSatchels == "" then
            clothingData.currentSatchels = exports['rsg-clothes']:GetClothesCurrentComponentHash("satchels")
            local isWearSatchels = IsPedUsingComponent(playerPed, Config.ClothingCategory.Satchels)
            if isWearSatchels then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Satchels)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentSatchels, false, true)
            clothingData.currentSatchels = ""
        end
    elseif clothingName == "gunbelts" then
        if clothingData.currentGunbelts == "" then
            clothingData.currentGunbelts = exports['rsg-clothes']:GetClothesCurrentComponentHash("gunbelts")
            local isWearGunbelts = IsPedUsingComponent(playerPed, Config.ClothingCategory.Gunbelts)
            if isWearGunbelts then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Gunbelts)
                Wait(10)
                LoadLowerBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentGunbelts, false, true)
            clothingData.currentGunbelts = ""
        end
    elseif clothingName == "buckles" then
        if clothingData.currentBuckles == "" then
            clothingData.currentBuckles = exports['rsg-clothes']:GetClothesCurrentComponentHash("belt_buckles")
            local isWearBuckles = IsPedUsingComponent(playerPed, Config.ClothingCategory.Buckles)
            if isWearBuckles then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Buckles)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentBuckles, false, true)
            clothingData.currentBuckles = ""
        end
    elseif clothingName == "skirts" then
        if clothingData.currentSkirts == "" then
            clothingData.currentSkirts = exports['rsg-clothes']:GetClothesCurrentComponentHash("skirts")
            local isWearSkirts = IsPedUsingComponent(playerPed, Config.ClothingCategory.Skirts)
            if isWearSkirts then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Skirts)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentSkirts, false, true)
            clothingData.currentSkirts = ""
        end
    elseif clothingName == "armor" then
        if clothingData.currentArmor == "" then
            clothingData.currentArmor = exports['rsg-clothes']:GetClothesCurrentComponentHash("armor")
            local isWearArmor = IsPedUsingComponent(playerPed, Config.ClothingCategory.Armor)
            if isWearArmor then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Armor)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentArmor, false, true)
            clothingData.currentArmor = ""
        end
    elseif clothingName == "hair_accessories" then
        if clothingData.currentHair == "" then
            clothingData.currentHair = exports['rsg-clothes']:GetClothesCurrentComponentHash("hair_accessories")
            local isWearArmor = IsPedUsingComponent(playerPed, Config.ClothingCategory.Hair)
            if isWearArmor then
                RemoveItemFromPedByCategory(playerPed, Config.ClothingCategory.Hair)
                Wait(10)
                LoadUpperBody(playerPed, playerSkin)
            end
        else
            NativeSetPedComponentEnabled(playerPed, clothingData.currentHair, false, true)
            clothingData.currentHair = ""
        end
    end
end)

----------------------------------------------------------------------------------------------

-- Remove all clothing
RegisterNetEvent('rsg-wardrobe:client:removeAllClothing', function()
    local ped = PlayerPedId()
    local male = IsPedMale(ped)

    for _, v in pairs(Config.ClothingCategory) do
        local wearing = IsPedUsingComponent(ped, v)

        if wearing then
            RemoveItemFromPedByCategory(ped, v)
        end

        if not male and v == 2699275135 then
            NativeSetPedComponentEnabled(ped, 0x00481D0F, false, true) -- Temporary skirt
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0xA0E3AB7F, 0) -- Skirts
            Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
        end
    end
end)

----------------------------------------------------------------------------------------------

function UpdateWearableState(ped, clothHash, wearableHash, p3, p4 , p5)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, clothHash, wearableHash, p3, p4, p5)
    NativeUpdatePedVariation(ped)
end

function RemoveItemFromPedByCategory(ped, clothCategory)
    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, ped, clothCategory, true, true, true)
end

function IsPedUsingComponent(ped, clothCategory)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, clothCategory)
end

function NativeSetPedComponentEnabled(ped, componentHash, immediately, isMp)
    local categoryHash = NativeGetPedComponentCategory(not IsPedMale(ped), componentHash)
    NativeFixMeshIssues(ped, categoryHash)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, isMp, true)
    NativeUpdatePedVariation(ped)
end

function NativeGetPedComponentCategory(isFemale, componentHash)
    return Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, isFemale, true)
end

function NativeFixMeshIssues(ped, categoryHash)
    Citizen.InvokeNative(0x59BD177A1A48600A, ped, categoryHash)
end

function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function NativeUpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    while not NativeHasPedComponentLoaded(ped) do
        Wait(1)
    end
end

function LoadUpperBody(target, data)
    local output = GetSkinColorFromBodySize(tonumber(data.body_size), tonumber(data.skin_tone))
    local torso = nil

    if not output then return end

    if IsPedMale(target) then
        if ComponentsMale["BODIES_UPPER"] then
            torso = ComponentsMale["BODIES_UPPER"][output]
        end

        if torso then
            NativeSetPedComponentEnabled(target, tonumber(torso), false, true)
        end

        return
    end

    if ComponentsFemale["BODIES_UPPER"] then
        torso = ComponentsFemale["BODIES_UPPER"][output]
    end

    if torso then
        NativeSetPedComponentEnabled(target, tonumber(torso), false, true)
    end
end

function LoadLowerBody(target, data)
    local output = GetSkinColorFromBodySize(tonumber(data.body_size), tonumber(data.skin_tone))
    local legs = nil

    if not output then return end

    if IsPedMale(target) then
        if ComponentsMale["BODIES_LOWER"] then
            legs = ComponentsMale["BODIES_LOWER"][output]
        end

        if legs then
            NativeSetPedComponentEnabled(target, tonumber(legs), false, true)
        end

        return
    end

    if ComponentsFemale["BODIES_LOWER"] then
        legs = ComponentsFemale["BODIES_LOWER"][output]
    end

    if legs then
        NativeSetPedComponentEnabled(target, tonumber(legs), false, true)
    end
end

function GetSkinColorFromBodySize(body, color)
    if body == 1 then
        if color == 1 then
            return 7
        elseif color == 2 then
            return 10
        elseif color == 3 then
            return 9
        elseif color == 4 then
            return 11
        elseif color == 5 then
            return 8
        elseif color == 6 then
            return 12
        end
    elseif body == 2 then
        if color == 1 then
            return 1
        elseif color == 2 then
            return 4
        elseif color == 3 then
            return 3
        elseif color == 4 then
            return 5
        elseif color == 5 then
            return 2
        elseif color == 6 then
            return 6
        end
    elseif body == 3 then
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
    elseif body == 4 then
        if color == 1 then
            return 19
        elseif color == 2 then
            return 22
        elseif color == 3 then
            return 21
        elseif color == 4 then
            return 23
        elseif color == 5 then
            return 20
        elseif color == 6 then
            return 24
        end
    elseif body == 5 then
        if color == 1 then
            return 25
        elseif color == 2 then
            return 28
        elseif color == 3 then
            return 27
        elseif color == 4 then
            return 29
        elseif color == 5 then
            return 26
        elseif color == 6 then
            return 30
        end
    else
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
end
