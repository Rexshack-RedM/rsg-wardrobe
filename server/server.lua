local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:getPlayerSkin', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local skins = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', {cid})
    cb(skins[1])
end)

RSGCore.Commands.Add('undress', locale('sv_text_35'), {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local jailed = Player.PlayerData.metadata['injail']

    if jailed > 0 then return end

    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', src)
end)

RSGCore.Commands.Add('hat', locale('sv_text_02'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'hat')
end)

RSGCore.Commands.Add('shirt', locale('sv_text_03'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'shirt')
end)

RSGCore.Commands.Add('pants', locale('sv_text_04'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'pants')
end)

RSGCore.Commands.Add('boots', locale('sv_text_05'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'boots')
end)

RSGCore.Commands.Add('coat', locale('sv_text_06'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'coats')
end)

RSGCore.Commands.Add('closedcoat', locale('sv_text_07'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'closedcoats')
end)

RSGCore.Commands.Add('gloves', locale('sv_text_08'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'glove')
end)

RSGCore.Commands.Add('poncho', locale('sv_text_09'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'ponchos')
end)

RSGCore.Commands.Add('vest', locale('sv_text_10'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'vest')
end)

RSGCore.Commands.Add('sleeve', locale('sv_text_11'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'sleeve')
end)

RSGCore.Commands.Add('eyewear', locale('sv_text_12'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'eyewear')
end)

RSGCore.Commands.Add('belt', locale('sv_text_13'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'belts')
end)

RSGCore.Commands.Add('cloak', locale('sv_text_14'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'cloaks')
end)

RSGCore.Commands.Add('chaps', locale('sv_text_15'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'chaps')
end)

RSGCore.Commands.Add('mask', locale('sv_text_16'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'masks')
end)

RSGCore.Commands.Add('neckwear', locale('sv_text_17'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'neckwear')
end)

RSGCore.Commands.Add('accessories', locale('sv_text_18'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'accessories')
end)

RSGCore.Commands.Add('gauntlets', locale('sv_text_19'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'gauntlets')
end)

RSGCore.Commands.Add('neckties', locale('sv_text_20'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'neckties')
end)

RSGCore.Commands.Add('loadouts', locale('sv_text_21'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'loadouts')
end)

RSGCore.Commands.Add('suspenders', locale('sv_text_22'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'suspenders')
end)

RSGCore.Commands.Add('satchels', locale('sv_text_23'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'satchels')
end)

RSGCore.Commands.Add('gunbelt', locale('sv_text_24'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'gunbelts')
end)

RSGCore.Commands.Add('buckle', locale('sv_text_25'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'buckles')
end)

RSGCore.Commands.Add('skirt', locale('sv_text_26'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'skirts')
end)

RSGCore.Commands.Add('armor', locale('sv_text_27'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'armor')
end)

RSGCore.Commands.Add('hairaccessories', locale('sv_text_28'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'hair_accessories')
end)

RSGCore.Commands.Add('leftring', locale('sv_text_29'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'jewelry_rings_left')
end)

RSGCore.Commands.Add('rightring', locale('sv_text_30'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'jewelry_rings_right')
end)

RSGCore.Commands.Add('leftholster', locale('sv_text_31'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'holster_left')
end)

RSGCore.Commands.Add('collar1', locale('sv_text_32'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'collar1')
end)

RSGCore.Commands.Add('collar2', locale('sv_text_33'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, 'collar2')
end)

RSGCore.Commands.Add('dress', locale('sv_text_34'), {}, false, function(source)
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