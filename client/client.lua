local display = false

RegisterCommand("nui", function(source, args)
    SetDisplay(not display)
end)

RegisterNUICallback("closeUI", function()
    SetDisplay(false)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

RegisterNetEvent('envi-receipts:notify', function(header, message, type, time)
    Notify(header, message, type, time)
end)

RegisterNetEvent('envi-receipts:showReceiptToClosestPlayer')
AddEventHandler('envi-receipts:showReceiptToClosestPlayer', function(slot)
    local ped = cache.ped
    local playerCoords = GetEntityCoords(ped)
    local maxDistance = 3.0
    local closestPlayer, closestPlayerPedId, closestPlayerCoords = lib.getClosestPlayer(playerCoords, maxDistance, false)
    if not closestPlayer or closestPlayer == ped or #(playerCoords - closestPlayerCoords) > maxDistance then
        Notify('Receipt','Nobody is nearby', 'error', 2500)
        return
    end
    TriggerServerEvent('envi-receipts:showReceiptToPlayer', GetPlayerServerId(closestPlayer), slot)
end)

RegisterNetEvent('envi-receipts:spawnProp', function()
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    lib.requestModel('bzzz_prop_payment_terminal', 300)
    lib.requestAnimDict('cellphone@', 100)
    payTerminal = CreateObject(`bzzz_prop_payment_terminal`, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(payTerminal, ped, GetPedBoneIndex(ped, 57005), 0.18, 0.01, 0.0, -54.0, 220.0, 43.0, false, false, false, false, 1, true)
    TaskPlayAnim(ped, 'cellphone@', 'cellphone_text_read_base', 8.0, 1.0, -1, 49, 0, false, false, false)
end)

RegisterNetEvent('envi-receipts:removeProp', function()
    local ped = cache.ped
    DeleteEntity(payTerminal)
    ClearPedTasks(ped)
end)

RegisterNetEvent('envi-receipts:useReceipt')
AddEventHandler('envi-receipts:useReceipt', function(metadata)
    print(json.encode(metadata))
    SendNUIMessage({
        type = "ui",
        status = true,
        metadata = metadata
    })
    Wait(10000)
    SetDisplay(false)
end)

lib.registerContext({
    id = 'main_menu',
    title = 'Payment Terminal',
    onExit = function()
        TriggerEvent('envi-receipts:removeProp')
    end,
    options = {
        {
            title = 'Add to Bill',
            onSelect = function()
                local input = lib.inputDialog('Add Item to Receipt', {
                    {type = 'input', label = 'Item Name', required = true},
                    {type = 'number', label = 'Price', required = true, min = 1},
                })

                if input then
                    local itemName = input[1]
                    local itemPrice = tonumber(input[2])
                    TriggerServerEvent('envi-receipts:addItemToBill', itemName, itemPrice)
                    lib.showContext('main_menu')
                else
                    TriggerEvent('envi-receipts:removeProp')
                end
            end
        },
        {
            title = 'View Basket',
            onSelect = function()
                TriggerServerEvent('envi-receipts:requestBasket')
            end
        },
        {
            title = 'Print Receipt',
            onSelect = function()
                local input = lib.inputDialog('Ready to Print?', {
                    {type = 'number', label = 'Number of Copies', required = true, min = 1},
                    {type = 'checkbox', label = 'PAID IN FULL'},
                })

                if input then
                    local howMany = tonumber(input[1])
                    local paid = input[2]
                    TriggerServerEvent('envi-receipts:giveBill', howMany, paid)
                    local alert = lib.alertDialog({
                        header = 'Receipt Printed',
                        content = 'Would you like to clear the current basket?',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then 
                        TriggerServerEvent('envi-receipts:clearBill')
                    end
                else
                    TriggerEvent('envi-receipts:removeProp')
                end
                TriggerEvent('envi-receipts:removeProp')
            end
        },
    }
})

RegisterNetEvent('envi-receipts:showBasket')
AddEventHandler('envi-receipts:showBasket', function(basketItems)
    local basketOptions = {}
    for _, itemData in ipairs(basketItems) do
        basketOptions[#basketOptions + 1] = {
            title = itemData.item,
            description = ('$%d'):format(itemData.price),
            disabled = true
        }
    end
    if #basketOptions == 0 then
        basketOptions[#basketOptions + 1] = {
            title = 'No items in the basket',
            disabled = true
        }
    end
    basketOptions[#basketOptions + 1] = {
        title = 'Clear Basket',
        onSelect = function()
            TriggerServerEvent('envi-receipts:clearBill')
            TriggerServerEvent('envi-receipts:requestBasket')
        end
    }
    lib.registerContext({
        id = 'basket_menu',
        title = 'Shopping Basket',
        menu = 'main_menu',
        onExit = function()
            TriggerEvent('envi-receipts:removeProp')
        end,
        options = basketOptions
    })
    lib.showContext('basket_menu')
end)

RegisterNetEvent('envi-receipts:openPayTerminal', function()
    TriggerEvent('envi-receipts:spawnProp')
    lib.showContext('main_menu')
end)

RegisterCommand('taxcheck', function()
    TriggerServerEvent('envi-receipts:checkTax')
end)

RegisterNetEvent('envi-receipts:quickPrint', function()
    TriggerEvent('envi-receipts:spawnProp')
    local input = lib.inputDialog('Ready to Print?', {
        {type = 'number', label = 'Number of Copies', required = true, min = 1},
        {type = 'checkbox', label = 'PAID IN FULL'},
    })

    if input then
        local howMany = tonumber(input[1])
        local paid = input[2]
        TriggerServerEvent('envi-receipts:giveBill', howMany, paid)
        local alert = lib.alertDialog({
            header = 'Receipt Printed',
            content = 'Would you like to clear the current basket?',
            centered = true,
            cancel = true
        })
        if alert == 'confirm' then 
            TriggerServerEvent('envi-receipts:clearBill')
        end
    else
        TriggerEvent('envi-receipts:removeProp')
    end
    TriggerEvent('envi-receipts:removeProp')
end)

-- RegisterCommand('receipt', function()    -- uncomment if you'd rather just use a command
--     lib.showContext('main_menu')
--     TriggerEvent('envi-receipts:spawnProp')
-- end)

