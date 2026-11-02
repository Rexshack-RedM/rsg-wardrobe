# rsg-wardrobe – Technical Documentation

## Contents
1. Architecture
2. Data formats
   - Wardrobe menu (NUI)
   - Persistence
3. Exports
4. Events and callbacks
5. Security model
6. Database
7. How-tos
8. Troubleshooting

## 1. Architecture

| File | Purpose |
|---|---|
| `fxmanifest.lua` | Manifest; locales via `@rsg-core/shared/locale.lua` |
| `shared/config.lua` | Permission, cooldown, clothing slots, skin colour table |
| `server/server.lua` | Commands, permission/jail/cooldown checks, skin callback, server exports |
| `client/client.lua` | Toggle logic, natives, bare body re-apply, hat anim, revive re-apply, client exports |
| `client/menu.lua` | NUI bridge, outfits, clothing care, `/hattip` |
| `html/` | Wardrobe menu (index.html, style.css, app.js) |
| `server/versionchecker.lua` | Checks GitHub for a newer version |
| `locales/*.json` | Player-facing text |

Command flow: player types a command → server checks ACE, jail (for `/dress`/`/undress`) and cooldown → triggers a client event → client removes or restores the item and remembers the removed hash so the next toggle puts back the same item.

Menu flow: `/wardrobe` (server checks ACE) → `rsg-wardrobe:client:openMenu` → `menu.lua` sends locale text, slot labels and state to the NUI → clicks post NUI callbacks → `menu.lua` forwards them to server events/callbacks, which run the same checks as commands → client refreshes the slot state.

When clothing is removed, the bare upper or lower body is re-applied from rsg-character's `GetBodyComponents()` (`{ male, female }`) using the player's `body_size` and `skin_tone` from `playerskins.skin`.

## 2. Data formats

`Config.ClothingComponents` entry:
```lua
{ name = 'hat', comps = 'hats', data = 'currentHat', hash = 2569388135 }
```
- `name` – used by commands and exports
- `comps` – key in `exports['rsg-character']:GetClothesCache()`
- `data` – client state key that stores the removed component hash
- `hash` – ped component category hash (`0` for shirt wearable states)

`Config.SkinColours` entry: `{ body = 1..5, colour = 1..6, index = n }`.

Animation entries (`Config.HatAnimation.Anim`, `Config.Care.BrushAnim`, `Config.Care.DryAnim`):
```lua
{ dict = 'mech_loco@player@zero@generic@streamed_idles@a', clip = 'fidget_dust_off', duration = 4000 }
```
Played upper-body only (flag 31) and skipped when mounted, in a vehicle or dead. Values come from rdr3_discoveries `animations/ingameanims/ingameanims_list.lua`.

`GetClothingState()` / NUI slot entry:
```lua
{ name = 'hat', worn = true, removed = false, available = true }
```
`available` is false when the slot isn't worn, wasn't removed and isn't in the rsg-character clothes cache (greyed out in the menu).

### Wardrobe menu (NUI)

| File | Purpose |
|---|---|
| `html/index.html` | Panel with Clothing / Outfits / Care tabs and a name/confirm modal |
| `html/style.css` | Leather & gold house theme (Roboto, monochrome, no vignette, no native selects) |
| `html/app.js` | Rendering, tab switching, NUI callbacks, drag-to-move |

NUI messages from Lua: `open` (`text`, `labels`, `state`), `state` (refresh), `close`. All text comes from the locale files (`ui_*` and `slot_*` keys); the NUI escapes every string it renders.

The dirt bar reads `_GET_PED_DIRT_LEVEL` (0x0105FEE8F9091255) and colours green < 35%, amber < 70%, red above. Wetness has no getter, so it isn't shown.

### Persistence

| What | Where | Lifetime |
|---|---|---|
| Saved outfits | `playeroutfit` table | Permanent |
| Current outfit | `playerskins.clothes` (updated when wearing an outfit) | Permanent |
| Removed items (for toggling back) | Client memory | Until relog, outfit change or `/undress` |
| Removed slot list | `wardrobeRemoved` replicated state bag | Same as above |
| Menu position | Player's NUI `localStorage` (`rsg-wardrobe:pos`) | Per client, survives restarts |

## 3. Exports

### Server
| Export | Params | Returns | Notes |
|---|---|---|---|
| `TogglePlayerClothing(src, name)` | player id, slot name | – | No permission check |
| `RemovePlayerClothing(src)` | player id | – | Strips all clothing |
| `DressPlayer(src)` | player id | – | Applies saved `playerskins.clothes` |

### Client
| Export | Params | Returns |
|---|---|---|
| `ToggleClothing(name)` | slot name | – |
| `RemoveAllClothing()` | – | – |
| `IsWearing(name)` | slot name | native result (truthy when worn) |
| `GetClothingState()` | – | `{ { name, worn, removed, available }, ... }` |
| `OpenWardrobe()` | – | – |
| `CleanClothes()` | – | clears dirt and wetness (no anim) |

State bag: `wardrobeRemoved` (replicated) – array of slot names the player has taken off.

## 4. Events and callbacks

| Name | Side | Payload |
|---|---|---|
| `rsg-wardrobe:client:OnOffClothing` | client | slot name |
| `rsg-wardrobe:client:removeAllClothing` | client | – |
| `rsg-wardrobe:client:dress` | client | clothes table |
| `rsg-wardrobe:server:getPlayerSkin` | callback | returns `playerskins.skin` JSON string |
| `rsg-wardrobe:client:openMenu` | client | – |
| `rsg-wardrobe:server:toggle` | server | slot name (validated against the command list) |
| `rsg-wardrobe:server:undress` / `:dress` | server | – |
| `rsg-wardrobe:server:getOutfits` | callback | `{ id, name, is_default }[]` |
| `rsg-wardrobe:server:saveOutfit` | callback | name → bool |
| `rsg-wardrobe:server:wearOutfit` | callback | id → bool (also sends `client:dress`) |
| `rsg-wardrobe:server:deleteOutfit` | callback | id → bool |

NUI callbacks: `close`, `toggle`, `undress`, `dress`, `getOutfits`, `saveOutfit`, `wearOutfit`, `deleteOutfit`, `care` (`brush`/`dry`/`hattip`).

Also listens to `rsg-medic:client:revive` to keep removed items off.

Listens to `rsg-character:client:ApplyClothes` (resets remembered items) and triggers `rsg-weapons:server:RemoveAllObjects` when undressing.

## 5. Security model

- No money or items are handled.
- All commands check `Config.RequiredPermission` and a per-player cooldown (`Config.CommandCooldown`).
- `/dress` and `/undress` are blocked while `metadata.injail > 0`.
- `/dress` reads the outfit from the database on the server; the client never sends clothing data.
- Client events only change the caller's own ped, so triggering them from a cheat client has no effect on others.
- Menu events go through the same permission/jail/cooldown checks as commands; slot names are checked against the server's command list.
- Outfits: saving copies the player's current `playerskins.clothes` on the server, never client data, so outfits can't create clothing the player doesn't own. Wear/delete only touch rows with the player's `citizenid`; the Default outfit can't be deleted. Names are trimmed to 40 chars with control characters and `<>` removed, and the NUI escapes all text.
- Clothing care and hat animations are purely visual (client-only).
- Server exports perform no permission checks; calling resources must do their own.

## 6. Database

No tables of its own. Uses rsg-character's tables:
- `playerskins` (`citizenid`, `skin`, `clothes`) – read; `clothes` updated when wearing an outfit
- `playeroutfit` (`id`, `citizenid`, `name`, `clothes`, `is_default`) – read/insert/delete

## 7. How-tos

- **Restrict to a group:** set `Config.RequiredPermission = 'wardrobe'` and `add_ace group.vip command.wardrobe allow`.
- **Remove a command:** delete its line from `toggleCommands` in `server/server.lua`.
- **Change language:** `setr rsg:locale fr`.
- **Disable a feature:** set `Config.Outfits.Enabled`, `Config.Care.Enabled` or `Config.HatAnimation.Enabled` to `false` (the menu tab hides automatically).
- **Open from another script:** `exports['rsg-wardrobe']:OpenWardrobe()` (e.g. from an rsg-target option on a wardrobe prop).
- **Change animations:** look up dict/clip in rdr3_discoveries `animations/ingameanims/ingameanims_list.lua` and set them in config.

## 8. Troubleshooting

| Problem | Cause / fix |
|---|---|
| Missing torso/legs after removing an item | Player skin not loaded yet; it loads 3 s after login or on resource restart |
| Toggle does nothing | Item isn't in rsg-character's clothes cache (not part of the saved outfit) |
| "No saved outfit" on `/dress` | Player has no `clothes` row in `playerskins` |
| Commands ignored when spammed | Cooldown working as intended |
| Menu doesn't open | Check `ui_page` files are present and no other NUI has focus |
| Outfits tab empty | rsg-character too old (no `playeroutfit.is_default` column); update rsg-character |
| Hat anim looks odd on women | The clip is from the male rig; set `Config.HatAnimation.Enabled = false` or swap the anim |
| `/hattip` does nothing | Emote not supported on the current ped/state (mounted, armed); test on foot |
| Locale keys showing instead of text | rsg-core too old for `@rsg-core/shared/locale.lua` |

---

Support: https://buymeacoffee.com/rexshack
