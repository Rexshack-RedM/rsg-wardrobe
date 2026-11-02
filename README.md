# rsg-wardrobe

**Version 3.2.0** · RSG Framework (RedM)

Take individual clothing items off and put them back on from a wardrobe menu or chat commands, switch between saved outfits, keep your clothes clean and dry, and tip your hat. Works on top of the clothing stored by rsg-character.

Full technical documentation: [DOCS.md](DOCS.md)

## Dependencies

- [rsg-core](https://github.com/Rexshack-RedM/rsg-core) (locales, notify, callbacks, commands)
- [rsg-character](https://github.com/Rexshack-RedM/rsg-character) (clothes cache, body components, `playerskins` table)
- [oxmysql](https://github.com/overextended/oxmysql)

Optional integrations: rsg-medic (keeps removed items off after revive), rsg-bathing (undresses/dresses through this script), rsg-weapons (holster props removed on undress).

ox_lib is **no longer required**.

## Features

- **Wardrobe menu** (`/wardrobe`): leather & gold NUI with Clothing, Outfits and Care tabs; shows which slots are worn, off or empty
- **Saved outfits**: save what you're wearing, wear or delete outfits anywhere; shares rsg-character's `playeroutfit` table so outfits bought in clothing stores appear too (Default outfit is protected)
- **Animated hat**: taking the hat off or putting it on plays a hand-to-hat animation; `/hattip` greets with a hat tip
- **Clothing care**: `/brushoff` removes dirt and blood, `/dryoff` shakes off water, with a dirt meter in the menu
- **Kept after revive**: items you took off stay off after rsg-medic revives you; removed slots are shared in the `wardrobeRemoved` state bag
- 33 toggle commands, one per clothing slot, that remember what you took off and put back the same item
- Shirt styles: rolled sleeves, open collar with sleeves up/down
- Bare body parts are re-applied when clothing is removed (no missing torso/legs), for both male and female characters
- Removing pants also removes boots (and puts them back with the pants)
- `/undress` and `/dress` (blocked while in jail)
- Optional ACE permission for all commands
- Per-player command cooldown and client-side busy lock to stop spam
- Server and client exports for other resources
- Notifications through rsg-core, all text in JSON locales

## Installation

1. Place `rsg-wardrobe` in your resources folder.
2. Ensure it **after** `rsg-core` and `rsg-character`:
   ```cfg
   ensure rsg-core
   ensure rsg-character
   ensure rsg-wardrobe
   ```
3. No database setup needed: the script uses the existing `playerskins` and `playeroutfit` tables from rsg-character.

## Configuration (`shared/config.lua`)

| Option | Default | Description |
|---|---|---|
| `Config.RequiredPermission` | `''` | ACE name; e.g. `'wardrobe'` requires `command.wardrobe`. Empty = everyone |
| `Config.CommandCooldown` | `750` | Milliseconds between wardrobe commands per player |
| `Config.KeepRemovedOnRevive` | `true` | Re-remove toggled-off items after an rsg-medic revive |
| `Config.Menu.Command` | `'wardrobe'` | Command that opens the menu |
| `Config.Outfits.Enabled` | `true` | Outfits tab and outfit callbacks |
| `Config.Outfits.MaxOutfits` | `30` | Saved outfits per character (excluding Default) |
| `Config.HatAnimation.Enabled` | `true` | Animate hat on/off |
| `Config.HatAnimation.Anim` / `SwapAt` / `FinishAfter` | see config | Anim dict/clip and timings |
| `Config.HatAnimation.TipEmote` / `TipCommand` | `KIT_EMOTE_GREET_HAT_TIP_1` / `'hattip'` | Hat tip emote and command (`false` disables) |
| `Config.Care.Enabled` | `true` | Care tab and commands |
| `Config.Care.BrushCommand` / `DryCommand` | `'brushoff'` / `'dryoff'` | Care commands |
| `Config.Care.BrushClearsBlood` | `true` | Brushing also clears blood |
| `Config.Care.BrushAnim` / `DryAnim` | see config | Care animations |
| `Config.ClothingComponents` | — | Clothing slots: `name`, rsg-character cache key `comps`, state key `data`, category `hash` |
| `Config.SkinColours` | — | Body size + skin tone → bare body component index |

ACE example:
```cfg
add_ace group.user command.wardrobe allow
```

## Commands

| Command | Action |
|---|---|
| `/wardrobe` | Open the wardrobe menu |
| `/hattip` | Tip your hat |
| `/brushoff` | Brush dirt and blood off your clothes |
| `/dryoff` | Shake water out of your clothes |

Clothing toggles:

| Command | Toggles | | Command | Toggles |
|---|---|---|---|---|
| `/hat` | Hat | | `/neckties` | Necktie |
| `/shirt` | Shirt | | `/loadouts` | Loadout |
| `/pants` | Pants (+ boots) | | `/suspenders` | Suspenders |
| `/boots` | Boots | | `/satchels` | Satchel |
| `/coat` | Coat | | `/gunbelt` | Gun belt |
| `/closedcoat` | Closed coat | | `/buckle` | Buckle |
| `/gloves` | Gloves | | `/skirt` | Skirt |
| `/poncho` | Poncho | | `/armor` | Armor |
| `/vest` | Vest | | `/hairaccessories` | Hair accessories |
| `/sleeve` | Rolled sleeves | | `/leftring` / `/rightring` | Rings |
| `/eyewear` | Eyewear | | `/leftholster` / `/rightholster` | Holsters |
| `/belt` | Belt | | `/collar1` | Open collar, sleeves up |
| `/cloak` | Cloak | | `/collar2` | Open collar, sleeves down |
| `/chaps` | Chaps | | `/undress` | Remove everything |
| `/mask` | Mask | | `/dress` | Wear saved outfit |
| `/neckwear` | Neckwear | | `/accessories` | Accessories |
| `/gauntlets` | Gauntlets | | | |

## How to use

1. Type `/wardrobe` to open the menu (or use any of the commands below).
2. **Clothing tab:** click a slot to take it off or put it back on. Pills show *Worn*, *Off* (you took it off) or *None* (not in your outfit, greyed out). **Undress** strips everything, **Dress** puts your saved outfit back on.
3. **Outfits tab:** **Save current outfit** stores what you're wearing under a name; **Wear** switches to an outfit anywhere; **Delete** removes it (asks to confirm; Default can't be deleted).
4. **Care tab:** the dirt bar shows how dirty you are; **Brush off**, **Dry off** and **Tip hat** play an animation and close the menu.
5. **Move the menu:** drag the title bar; the position is remembered. Double-click the title bar to reset it.
6. Press **Esc** or the ✕ button to close.

`/dress`, `/undress`, Dress/Undress and wearing/saving outfits are blocked while in jail.

## Developer examples

```lua
-- server
exports['rsg-wardrobe']:TogglePlayerClothing(src, 'hat')
exports['rsg-wardrobe']:RemovePlayerClothing(src)
exports['rsg-wardrobe']:DressPlayer(src)

-- client
exports['rsg-wardrobe']:ToggleClothing('masks')
local wearingMask = exports['rsg-wardrobe']:IsWearing('masks')
exports['rsg-wardrobe']:OpenWardrobe()
exports['rsg-wardrobe']:CleanClothes()
local slots = exports['rsg-wardrobe']:GetClothingState()

-- any side: which slots a player has taken off
local removed = Player(src).state.wardrobeRemoved
```

## Locales

`en`, `de`, `el`, `es`, `fr`, `ja`, `nl`, `pl`, `pt-br`, `ro` (plus `cs`, `it`). Set the language with `setr rsg:locale de`.

---

Support: https://buymeacoffee.com/rexshack
