# scrp_blackmarket
Made for redem_roleplay and redemrp_inventory

# Installation
1. Clone this repository.
2. Extract the zip.
3. Put scrp_blackmarket to your resource folder.
4. Add "start scrp_blackmarket" in your "server.cfg".
5. In redemrp_inventory/Config.lua add weapons and ammos

- For Redemrp_inventory2 (weapon example)

```
["cattleman_w"] = {
        label = "Cattleman",
        description = "",
        weight = 0.9,
        canBeDropped = true,
        requireLvl = 0,
        weaponHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN"),
        imgsrc = "items/Cattleman.png",
        type = "item_weapon",
    },
```
 
- For Redemrp_inventory2 (ammo example)
```
["revolver_ammo"] = {
        label = "Ammo Revolver",
        description = "",
        weight = 0.02,
        canBeDropped = true,
        canBeUsed = false,
        requireLvl = 0,
        limit = 64,
        imgsrc = "items/ammo.png",
        type = "item_standard",
    },
```
5. Profit

# Required resource
- redem_roleplay
- redemrp_inventory
- redemrp_notification
- redemrp_menu_base