local gunsmiths = {
    { x = 436.75, y = 2260.25, z = 251.28 }, --Indian Reservation Blackmarket
}

local active = false
local ShopPrompt
local hasAlreadyEnteredMarker, lastZone
local currentZone = nil

MenuData = {}
TriggerEvent("redemrp_menu_base:getData",function(call)
    MenuData = call
end)

function SetupShopPrompt()
    Citizen.CreateThread(function()
        local str = 'Open Shop'
        ShopPrompt = PromptRegisterBegin()
        PromptSetControlAction(ShopPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(ShopPrompt, str)
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
        PromptSetHoldMode(ShopPrompt, true)
        PromptRegisterEnd(ShopPrompt)

    end)
end

AddEventHandler('scrp_blackmarket:hasEnteredMarker', function(zone)
    currentZone     = zone
end)

AddEventHandler('scrp_blackmarket:hasExitedMarker', function(zone)
    if active == true then
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
        active = false
    end
    WarMenu.CloseMenu()
	currentZone = nil
end)

Citizen.CreateThread(function()
    SetupShopPrompt()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local isInMarker, currentZone = false

        for k,v in ipairs(gunsmiths) do
            if (Vdist(coords.x, coords.y, coords.z, v.x, v.y, v.z) < 1.5) then
                isInMarker  = true
                currentZone = 'gunsmiths'
                lastZone    = 'gunsmiths'
            end
        end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('scrp_blackmarket:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('scrp_blackmarket:hasExitedMarker', lastZone)
		end

    end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if currentZone then
            if active == false then
                PromptSetEnabled(ShopPrompt, true)
                PromptSetVisible(ShopPrompt, true)
                active = true
            end
            if PromptHasHoldModeCompleted(ShopPrompt) then
                ShopMenu()
                PromptSetEnabled(ShopPrompt, false)
                PromptSetVisible(ShopPrompt, false)
                active = false

				currentZone = nil
			end
        else
			Citizen.Wait(500)
		end
	end
end)

function ShopMenu()
    MenuData.CloseAll()
    local elements = {
            {label = "Blackmarket", value = 'pistols'},
            {label = "Empty", value = 'longguns'},
            {label = "Empty", value = 'handguns'},
            {label = "Empty", value = 'ammo'}
    }
    MenuData.Open('default', GetCurrentResourceName(), 'weaponshop_main', {
        title    = 'Weapon Shop',
        subtext    = 'choose a category',
        align    = 'top-left',
        elements = elements,
    }, function(data, menu)
        local elements2 = {}
        local OpenSub = false
        local category = data.current.value
        if category == 'pistols' then
            elements2 = {
                {label = "Stick of Explosives 175.50", value = 'throwing_w', weapon = 'WEAPON_THROWN_DYNAMITE', price = 175.50, lvl = 1, subtext = "$175.50 LvL 1"},               
                {label = "Molotov 103.86", value = 'throwing_w', weapon = 'WEAPON_THROWN_MOLOTOV', price = 103.86, lvl = 1, subtext = "$103.86 LvL 1"}
            }
            OpenSub = true
        elseif category == 'longguns' then
            elements2 = {
            }
            OpenSub = true
        elseif category == 'handguns' then
            elements2 = {                
            }
            OpenSub = true
        elseif category == 'ammo' then
            local options = {
                {label = 'Pistols', value = 'pistols'},
                {label = 'Long Guns', value = 'longgunsammo'},
                {label = 'Melee Weapons', value = 'handgunsammo'},
            }
            MenuData.Open('default', GetCurrentResourceName(), 'weaponshop_ammo', {
                title    = 'Ammo Shop',
                align    = 'top-left',
                elements = options,
            }, function(data2, menu2)
                local choice = data2.current.value
                local ammochoices = {}

                if choice == 'pistols' then
                    ammochoices = {
                    }
                elseif choice == 'longgunsammo' then
                    ammochoices = {
                    }
                elseif choice == 'handgunsammo' then
                    ammochoices = {
                    }
                end

                MenuData.Open('default', GetCurrentResourceName(), 'weaponshop_'..category, {
                    title    = category..' Shop',
                    align    = 'top-left',
                    elements = ammochoices,
                }, function(data3, menu3)
                    local item = data3.current.value
                    local price = data3.current.price
                    TriggerServerEvent("scrp_blackmarket:buyammo", tonumber(price), item)
                end, function(data3, menu3)
                    menu3.close()
                end)
            end, function(data3, menu3)
                menu3.close()
            end) 
        end

        if OpenSub == true then
            OpenSub = false
            MenuData.Open('default', GetCurrentResourceName(), 'weaponshop_'..category, {
                title    = category..' Shop',
                align    = 'top-left',
                elements = elements2,
            }, function(data2, menu2)
                local weapon = data2.current.weapon
                local item = data2.current.value
                local price = data2.current.price
                local lvl = data2.current.lvl
                TriggerServerEvent("scrp_blackmarket:buygun", item, tonumber(price), weapon,  tonumber(lvl))
            end, function(data2, menu2)
                menu2.close()
            end) 
        end
    end, function(data, menu)
        menu.close()
    end) 
end

RegisterNetEvent('scrp_blackmarket:alert')	
AddEventHandler('scrp_blackmarket:alert', function(txt)
    SetTextScale(0.5, 0.5)
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", txt, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xFA233F8FE190514C, str)
    Citizen.InvokeNative(0xE9990552DEC71600)
end)

RegisterNetEvent('scrp_blackmarket:giveammo')
AddEventHandler('scrp_blackmarket:giveammo', function(type)
    local player = GetPlayerPed()
    local ammo = GetHashKey(type)
    SetPedAmmo(player, ammo, 100)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PromptSetEnabled(ShopPrompt, false)
        PromptSetVisible(ShopPrompt, false)
    end
end)
