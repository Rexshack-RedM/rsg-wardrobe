<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🧥 rsg-wardrobe
**Wardrobe and clothing toggle system for RedM using RSG Core and RSG Appearance.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Allows players to remove or equip specific clothing parts using simple commands.  
> Fully integrated with RSG Appearance and RSG Core.

---

## 🛠️ Dependencies
- **rsg-core** (framework)  
- **rsg-appearance** (character clothing system)  
- **ox_lib** (notifications, locales)

**Locales included:** `en`, `fr`, `es`, `it`, `pt-br`, `el`, `ro`  
**License:** GPL‑3.0

---

## ✨ Features
- 👕 **Individual clothing control:** players can toggle or remove specific outfit parts.  
- 🧳 **Works with RSG Appearance:** modifies current outfit without resetting ped.  
- 🌍 **Multi-language** via `lib.locale()`.

---

## ⚙️ Configuration (`config.lua`)

### `Config.ClothingComponents`
List of clothing components that the script can toggle. Each entry contains:
- `name` — command/key name (e.g., `hat`, `boots`, `vest`, `closedcoats`, `leftholster`, `jewelry_rings_left`, etc.)
- `comps` — the appearance component name used by RSG Appearance
- `data` — the player skin field the script reads/writes (e.g., `currentHat`, `currentBoots`, ...)
- `hash` — numeric identifier for the component

```lua
Config.ClothingComponents = {
  { name = 'accessories', comps = 'accessories', data = 'currentAccessories', hash = 2044190614 },
  { name = 'armor',       comps = 'armor',       data = 'currentArmor',       hash = 1927737204 },
  { name = 'belts',       comps = 'belts',       data = 'currentBelts',       hash = 2798728390 },
  { name = 'boots',       comps = 'boots',       data = 'currentBoots',       hash = 2004797167 },
  { name = 'buckles',     comps = 'belt_buckles',data = 'currentBuckles',     hash = 4209578111 },
  -- ... (see full list in config.lua including coats, closedcoats, eyewear, gloves, poncho, vest, sleeve, chaps, mask,
  -- neckwear, gauntlets, necktie, suspenders, satchels, gunbelt, buckles, skirts, hairaccessories, leftring, rightring, leftholster, collar, etc.)
}
```

### `Config.SkinColours`
Mapping table used by the script when interacting with skin/colour indices. Each row contains:
- `body` — body region index
- `colour` — colour slot
- `index` — resulting index value

```lua
Config.SkinColours = {
  { body = 1, colour = 1, index = 7 },
  { body = 1, colour = 2, index = 10 },
  { body = 1, colour = 3, index = 9 },
  -- ...
}
```

---

## 🧢 Commands
Each command toggles or removes the corresponding clothing element:

`/undress`, `/hat`, `/shirt`, `/pants`, `/boots`, `/coat`, `/closedcoat`, `/gloves`, `/poncho`, `/vest`, `/sleeve`, `/eyewear`, `/belts`, `/cloak`, `/chaps`, `/mask`, `/neckwear`, `/accessories`, `/gauntlets`, `/necktie`, `/loadouts`, `/suspenders`, `/satchels`, `/gunbelt`, `/buckles`, `/skirts`, `/armor`, `/hairaccessories`, `/leftring`, `/rightring`, `/leftholster`, `/collar`

---

## 💾 Data Storage
- Reads player skin data from the `playerskins` table via `citizenid`.  
- Updates are applied through RSG Appearance component fields referenced in `Config.ClothingComponents`.

---

## 📂 Installation
1. Add `rsg-wardrobe` to `resources/[rsg]`.  
2. Ensure `rsg-core` and `rsg-appearance` are installed.  
3. In your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure rsg-core
   ensure rsg-appearance
   ensure rsg-wardrobe
   ```
4. Restart your server.

---

## 💎 Credits
- **AdlanDzulkfali** — original resource & permission to use code  
  🔗 https://github.com/AdlanDzulkfali/addz_qr_clothing  
- **RSG / Rexshack-RedM** — framework integration & localization support  
- Community translator
- License: GPL‑3.0  
