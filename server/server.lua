local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local function hasAcePerms(player)
    if not Config.RequiredPermission or Config.RequiredPermission == '' then return true end
    return IsPlayerAceAllowed(player, 'command.' .. Config.RequiredPermission)
end

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:getPlayerSkin', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end
    local cid = Player.PlayerData.citizenid
    local skins = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', {cid})
    cb(skins[1])
end)

local function registerClothingCommand(cmdName, clothingName, desc)
    RSGCore.Commands.Add(cmdName, desc, {}, false, function(source)
        local src = source
        if not hasAcePerms(src) then return end
        TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, clothingName)
    end)
end

local toggleCommands = {
    { cmd = 'hat',              name = 'hat',               desc = 'sv_text_02' },
    { cmd = 'shirt',            name = 'shirt',             desc = 'sv_text_03' },
    { cmd = 'pants',            name = 'pants',             desc = 'sv_text_04' },
    { cmd = 'boots',            name = 'boots',             desc = 'sv_text_05' },
    { cmd = 'coat',             name = 'coats',             desc = 'sv_text_06' },
    { cmd = 'closedcoat',       name = 'closedcoats',       desc = 'sv_text_07' },
    { cmd = 'gloves',           name = 'glove',             desc = 'sv_text_08' },
    { cmd = 'poncho',           name = 'ponchos',           desc = 'sv_text_09' },
    { cmd = 'vest',             name = 'vest',              desc = 'sv_text_10' },
    { cmd = 'sleeve',           name = 'sleeve',            desc = 'sv_text_11' },
    { cmd = 'eyewear',          name = 'eyewear',           desc = 'sv_text_12' },
    { cmd = 'belt',             name = 'belts',             desc = 'sv_text_13' },
    { cmd = 'cloak',            name = 'cloaks',            desc = 'sv_text_14' },
    { cmd = 'chaps',            name = 'chaps',             desc = 'sv_text_15' },
    { cmd = 'mask',             name = 'masks',             desc = 'sv_text_16' },
    { cmd = 'neckwear',         name = 'neckwear',          desc = 'sv_text_17' },
    { cmd = 'accessories',      name = 'accessories',       desc = 'sv_text_18' },
    { cmd = 'gauntlets',        name = 'gauntlets',         desc = 'sv_text_19' },
    { cmd = 'neckties',         name = 'neckties',          desc = 'sv_text_20' },
    { cmd = 'loadouts',         name = 'loadouts',          desc = 'sv_text_21' },
    { cmd = 'suspenders',       name = 'suspenders',        desc = 'sv_text_22' },
    { cmd = 'satchels',         name = 'satchels',          desc = 'sv_text_23' },
    { cmd = 'gunbelt',          name = 'gunbelts',          desc = 'sv_text_24' },
    { cmd = 'buckle',           name = 'buckles',           desc = 'sv_text_25' },
    { cmd = 'skirt',            name = 'skirts',            desc = 'sv_text_26' },
    { cmd = 'armor',            name = 'armor',             desc = 'sv_text_27' },
    { cmd = 'hairaccessories',  name = 'hair_accessories',  desc = 'sv_text_28' },
    { cmd = 'leftring',         name = 'jewelry_rings_left', desc = 'sv_text_29' },
    { cmd = 'rightring',        name = 'jewelry_rings_right', desc = 'sv_text_30' },
    { cmd = 'leftholster',      name = 'holster_left',      desc = 'sv_text_31' },
    { cmd = 'rightholster',     name = 'holster_right',     desc = 'sv_text_36' },
    { cmd = 'collar1',          name = 'collar1',           desc = 'sv_text_32' },
    { cmd = 'collar2',          name = 'collar2',           desc = 'sv_text_33' },
}

for _, c in ipairs(toggleCommands) do
    registerClothingCommand(c.cmd, c.name, locale(c.desc))
end

RSGCore.Commands.Add('undress', locale('sv_text_35'), {}, false, function(source)
    local src = source
    if not hasAcePerms(src) then return end
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local jailed = Player.PlayerData.metadata['injail']
    if jailed > 0 then return end
    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', src)
end)

RSGCore.Commands.Add('dress', locale('sv_text_34'), {}, false, function(source)
    local src = source
    if not hasAcePerms(src) then return end
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local jailed = Player.PlayerData.metadata['injail']
    if jailed > 0 then return end
    local citizenid = Player.PlayerData.citizenid
    local _clothes = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', { citizenid })
    if _clothes[1] then
        _clothes = json.decode(_clothes[1].clothes)
    else
        _clothes = {}
    end
    if _clothes and next(_clothes) then
        TriggerClientEvent('rsg-appearance:client:ApplyClothes', src, _clothes)
    end
end)

exports('TogglePlayerClothing', function(source, name)
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', source, name)
end)

exports('RemovePlayerClothing', function(source)
    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', source)
end)

exports('DressPlayer', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local _clothes = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', { citizenid })
    if _clothes[1] then
        _clothes = json.decode(_clothes[1].clothes)
    else
        _clothes = {}
    end
    if _clothes and next(_clothes) then
        TriggerClientEvent('rsg-appearance:client:ApplyClothes', source, _clothes)
    end
end)