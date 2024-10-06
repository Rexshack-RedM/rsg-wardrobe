local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:getPlayerSkin', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local skins = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', {cid})
    cb(skins[1])
end)

RSGCore.Commands.Add("undress", "removes all clothing", {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local jailed = Player.PlayerData.metadata['injail']

    if jailed > 0 then return end

    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', src)
end)

RSGCore.Commands.Add("hat", "hat on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "hat")
end)

RSGCore.Commands.Add("shirt", "shirt on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "shirt")
end)

RSGCore.Commands.Add("pants", "pants on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "pants")
end)

RSGCore.Commands.Add("boots", "boots on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "boots")
end)

RSGCore.Commands.Add("coat", "coat on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "coats")
end)

RSGCore.Commands.Add("closedcoat", "closed coat on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "closedcoats")
end)

RSGCore.Commands.Add("gloves", "gloves on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "glove")
end)

RSGCore.Commands.Add("poncho", "ponchos on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "ponchos")
end)

RSGCore.Commands.Add("vest", "vest on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "vest")
end)

RSGCore.Commands.Add("sleeve", "sleeve shirt on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "sleeve")
end)

RSGCore.Commands.Add("eyewear", "eyewear on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "eyewear")
end)

RSGCore.Commands.Add("belt", "belts on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "belts")
end)

RSGCore.Commands.Add("cloak", "cloaks on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "cloaks")
end)

RSGCore.Commands.Add("chaps", "chaps on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "chaps")
end)

RSGCore.Commands.Add("mask", "masks on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "masks")
end)

RSGCore.Commands.Add("neckwear", "neckwear on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "neckwear")
end)

RSGCore.Commands.Add("accessories", "accessories on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "accessories")
end)

RSGCore.Commands.Add("gauntlets", "gauntlets on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "gauntlets")
end)

RSGCore.Commands.Add("neckties", "neckties on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "neckties")
end)

RSGCore.Commands.Add("loadouts", "loadouts on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "loadouts")
end)

RSGCore.Commands.Add("suspenders", "suspenders on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "suspenders")
end)

RSGCore.Commands.Add("satchels", "satchels on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "satchels")
end)

RSGCore.Commands.Add("gunbelt", "gunbelt on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "gunbelts")
end)

RSGCore.Commands.Add("buckle", "buckles on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "buckles")
end)

RSGCore.Commands.Add("skirt", "skirts on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "skirts")
end)

RSGCore.Commands.Add("armor", "armor on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "armor")
end)

RSGCore.Commands.Add("hairaccessories", "hair accessories on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "hair_accessories")
end)

RSGCore.Commands.Add("leftring", "left rings on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "jewelry_rings_left")
end)

RSGCore.Commands.Add("rightring", "right rings on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "jewelry_rings_right")
end)

RSGCore.Commands.Add("leftholster", "left holster on/off", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "holster_left")
end)

RSGCore.Commands.Add("collar1", "collar with sleeves up", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "collar1")
end)

RSGCore.Commands.Add("collar2", "collar with sleeves down", {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, "collar2")
end)

RSGCore.Commands.Add("dress", "Wear all clothing", {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local jailed = Player.PlayerData.metadata['injail']

    if jailed > 0 then return end

    local citizenid = Player.PlayerData.citizenid
    local _clothes =  MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', { citizenid })

    if _clothes[1] then
        _clothes = json.decode(_clothes[1].clothes)
    else
        _clothes = {}
    end

    if _clothes then
        TriggerClientEvent('rsg-appearance:client:ApplyClothes', src, _clothes)
    end
end)
