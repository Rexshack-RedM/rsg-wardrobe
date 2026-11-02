local RSGCore = exports['rsg-core']:GetCoreObject()

local cooldowns = {}

local function notify(src, key, ntype)
    TriggerClientEvent('RSGCore:Client:Notify', src, {
        title = locale('wardrobe_title'),
        description = locale(key),
        type = ntype or 'error',
        duration = 4000,
    })
end

local function hasAcePerms(src)
    if not Config.RequiredPermission or Config.RequiredPermission == '' then return true end
    return IsPlayerAceAllowed(src, 'command.' .. Config.RequiredPermission)
end

-- Shared checks for every command: permission, jail and spam cooldown
local function canUse(src, checkJail)
    if not hasAcePerms(src) then
        notify(src, 'no_permission')
        return nil
    end
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return nil end
    if checkJail and (tonumber(Player.PlayerData.metadata['injail']) or 0) > 0 then
        notify(src, 'jailed')
        return nil
    end
    local now = GetGameTimer()
    if cooldowns[src] and now - cooldowns[src] < Config.CommandCooldown then return nil end
    cooldowns[src] = now
    return Player
end

local function getSavedClothes(citizenid)
    local clothes = MySQL.scalar.await('SELECT clothes FROM playerskins WHERE citizenid = ?', { citizenid })
    clothes = clothes and json.decode(clothes)
    if type(clothes) == 'table' and next(clothes) then return clothes end
    return nil
end

local function dressPlayer(src, Player)
    local clothes = getSavedClothes(Player.PlayerData.citizenid)
    if not clothes then
        notify(src, 'no_outfit', 'inform')
        return
    end
    TriggerClientEvent('rsg-wardrobe:client:dress', src, clothes)
end

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:getPlayerSkin', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    cb(MySQL.scalar.await('SELECT skin FROM playerskins WHERE citizenid = ?', { Player.PlayerData.citizenid }))
end)

----------------------------------------------------------------
-- Commands
----------------------------------------------------------------
local toggleCommands = {
    { cmd = 'hat',             name = 'hat',                 desc = 'sv_text_02' },
    { cmd = 'shirt',           name = 'shirt',               desc = 'sv_text_03' },
    { cmd = 'pants',           name = 'pants',               desc = 'sv_text_04' },
    { cmd = 'boots',           name = 'boots',               desc = 'sv_text_05' },
    { cmd = 'coat',            name = 'coats',               desc = 'sv_text_06' },
    { cmd = 'closedcoat',      name = 'closedcoats',         desc = 'sv_text_07' },
    { cmd = 'gloves',          name = 'glove',               desc = 'sv_text_08' },
    { cmd = 'poncho',          name = 'ponchos',             desc = 'sv_text_09' },
    { cmd = 'vest',            name = 'vest',                desc = 'sv_text_10' },
    { cmd = 'sleeve',          name = 'sleeve',              desc = 'sv_text_11' },
    { cmd = 'eyewear',         name = 'eyewear',             desc = 'sv_text_12' },
    { cmd = 'belt',            name = 'belts',               desc = 'sv_text_13' },
    { cmd = 'cloak',           name = 'cloaks',              desc = 'sv_text_14' },
    { cmd = 'chaps',           name = 'chaps',               desc = 'sv_text_15' },
    { cmd = 'mask',            name = 'masks',               desc = 'sv_text_16' },
    { cmd = 'neckwear',        name = 'neckwear',            desc = 'sv_text_17' },
    { cmd = 'accessories',     name = 'accessories',         desc = 'sv_text_18' },
    { cmd = 'gauntlets',       name = 'gauntlets',           desc = 'sv_text_19' },
    { cmd = 'neckties',        name = 'neckties',            desc = 'sv_text_20' },
    { cmd = 'loadouts',        name = 'loadouts',            desc = 'sv_text_21' },
    { cmd = 'suspenders',      name = 'suspenders',          desc = 'sv_text_22' },
    { cmd = 'satchels',        name = 'satchels',            desc = 'sv_text_23' },
    { cmd = 'gunbelt',         name = 'gunbelts',            desc = 'sv_text_24' },
    { cmd = 'buckle',          name = 'buckles',             desc = 'sv_text_25' },
    { cmd = 'skirt',           name = 'skirts',              desc = 'sv_text_26' },
    { cmd = 'armor',           name = 'armor',               desc = 'sv_text_27' },
    { cmd = 'hairaccessories', name = 'hair_accessories',    desc = 'sv_text_28' },
    { cmd = 'leftring',        name = 'jewelry_rings_left',  desc = 'sv_text_29' },
    { cmd = 'rightring',       name = 'jewelry_rings_right', desc = 'sv_text_30' },
    { cmd = 'leftholster',     name = 'holster_left',        desc = 'sv_text_31' },
    { cmd = 'rightholster',    name = 'holster_right',       desc = 'sv_text_36' },
    { cmd = 'collar1',         name = 'collar1',             desc = 'sv_text_32' },
    { cmd = 'collar2',         name = 'collar2',             desc = 'sv_text_33' },
}

for _, c in ipairs(toggleCommands) do
    RSGCore.Commands.Add(c.cmd, locale(c.desc), {}, false, function(source)
        if not canUse(source, false) then return end
        TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', source, c.name)
    end)
end

RSGCore.Commands.Add('undress', locale('sv_text_35'), {}, false, function(source)
    if not canUse(source, true) then return end
    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', source)
end)

RSGCore.Commands.Add('dress', locale('sv_text_34'), {}, false, function(source)
    local Player = canUse(source, true)
    if not Player then return end
    dressPlayer(source, Player)
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

----------------------------------------------------------------
-- Wardrobe menu
----------------------------------------------------------------
local validSlots = {}
for _, c in ipairs(toggleCommands) do validSlots[c.name] = true end

RSGCore.Commands.Add(Config.Menu.Command, locale('cmd_wardrobe'), {}, false, function(source)
    if not hasAcePerms(source) then return notify(source, 'no_permission') end
    TriggerClientEvent('rsg-wardrobe:client:openMenu', source)
end)

RegisterNetEvent('rsg-wardrobe:server:toggle', function(name)
    local src = source
    if type(name) ~= 'string' or not validSlots[name] then return end
    if not canUse(src, false) then return end
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', src, name)
end)

RegisterNetEvent('rsg-wardrobe:server:undress', function()
    local src = source
    if not canUse(src, true) then return end
    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', src)
end)

RegisterNetEvent('rsg-wardrobe:server:dress', function()
    local src = source
    local Player = canUse(src, true)
    if Player then dressPlayer(src, Player) end
end)

----------------------------------------------------------------
-- Outfits: uses rsg-character's playeroutfit table (id, citizenid, name, clothes, is_default)
-- Only outfits the player already owns/wears can be saved, so nothing here can create free clothing.
----------------------------------------------------------------
local function outfitPlayer(src, checkJail)
    if not Config.Outfits.Enabled or not hasAcePerms(src) then return nil end
    return canUse(src, checkJail)
end

local function cleanName(name)
    if type(name) ~= 'string' then return '' end
    return (name:gsub('[%c<>]', ''):gsub('^%s+', ''):gsub('%s+$', '')):sub(1, 40)
end

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:getOutfits', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player or not Config.Outfits.Enabled then return cb({}) end
    local rows = MySQL.query.await('SELECT id, name, is_default FROM playeroutfit WHERE citizenid = ? ORDER BY is_default DESC, id', { Player.PlayerData.citizenid }) or {}
    for i = 1, #rows do rows[i].is_default = rows[i].is_default == 1 or rows[i].is_default == true end
    cb(rows)
end)

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:saveOutfit', function(source, cb, name)
    local Player = outfitPlayer(source, true)
    if not Player then return cb(false) end
    local citizenid = Player.PlayerData.citizenid
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM playeroutfit WHERE citizenid = ? AND is_default = 0', { citizenid }) or 0
    if count >= Config.Outfits.MaxOutfits then
        notify(source, 'outfit_limit')
        return cb(false)
    end
    -- copy what the player currently owns/wears (never clothing sent by the client)
    local clothes = MySQL.scalar.await('SELECT clothes FROM playerskins WHERE citizenid = ?', { citizenid })
    if not clothes or clothes == '' or clothes == '[]' or clothes == '{}' then
        notify(source, 'no_outfit')
        return cb(false)
    end
    name = cleanName(name)
    if name == '' then name = locale('outfit_auto_name', count + 1) end
    MySQL.insert.await('INSERT INTO playeroutfit (citizenid, name, clothes, is_default) VALUES (?, ?, ?, 0)', { citizenid, name, clothes })
    notify(source, 'outfit_saved', 'success')
    cb(true)
end)

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:deleteOutfit', function(source, cb, id)
    id = tonumber(id)
    local Player = id and outfitPlayer(source, false)
    if not Player then return cb(false) end
    local affected = MySQL.update.await('DELETE FROM playeroutfit WHERE id = ? AND citizenid = ? AND is_default = 0', { id, Player.PlayerData.citizenid })
    if affected and affected > 0 then notify(source, 'outfit_deleted', 'success') end
    cb(affected and affected > 0)
end)

RSGCore.Functions.CreateCallback('rsg-wardrobe:server:wearOutfit', function(source, cb, id)
    id = tonumber(id)
    local Player = id and outfitPlayer(source, true)
    if not Player then return cb(false) end
    local citizenid = Player.PlayerData.citizenid
    local clothes = MySQL.scalar.await('SELECT clothes FROM playeroutfit WHERE id = ? AND citizenid = ?', { id, citizenid })
    local ok, decoded = pcall(json.decode, clothes or '')
    if not ok or type(decoded) ~= 'table' or not next(decoded) then return cb(false) end
    MySQL.update.await('UPDATE playerskins SET clothes = ? WHERE citizenid = ?', { clothes, citizenid })
    TriggerClientEvent('rsg-wardrobe:client:dress', source, decoded)
    cb(true)
end)

----------------------------------------------------------------
-- Exports (server-side, trusted callers only)
----------------------------------------------------------------
exports('TogglePlayerClothing', function(source, name)
    if type(name) ~= 'string' then return end
    TriggerClientEvent('rsg-wardrobe:client:OnOffClothing', source, name)
end)

exports('RemovePlayerClothing', function(source)
    TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', source)
end)

exports('DressPlayer', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    local clothes = getSavedClothes(Player.PlayerData.citizenid)
    if clothes then TriggerClientEvent('rsg-wardrobe:client:dress', source, clothes) end
end)
