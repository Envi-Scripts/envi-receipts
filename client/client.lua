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

RegisterNetEvent('envi-receipts:useReceipt')
AddEventHandler('envi-receipts:useReceipt', function(metadata)
    print('metadata', metadata)
    print('encoded metadata', json.encode(metadata))
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
    options = {
        {
            title = 'Add to Bill',
            onSelect = function()
                lib.showContext('add_item_menu')
            end
        },
        {
            title = 'View Basket',
            onSelect = function()
                TriggerServerEvent('envi-receipts:showBasket')
            end
        },
        {
            title = 'Clear Basket',
            onSelect = function()
                TriggerServerEvent('envi-receipts:clearBill')
            end
        },
        {
            title = 'Print Receipt',
            onSelect = function()
                TriggerServerEvent('envi-receipts:giveBill')
            end
        },
    }
})

lib.registerContext({
    id = 'add_item_menu',
    title = 'Add Item to Receipt',
    menu = 'main_menu',
    options = {
        {
            title = 'Add to Bill',
            onSelect = function()
                local input = lib.inputDialog('Add Item to Receipt', {
                    {type = 'input', label = 'Item Name', required = true},
                    {type = 'number', label = 'Price', required = true, min = 1}
                })

                if input then
                    local itemName = input[1]
                    local itemPrice = tonumber(input[2])
                    TriggerServerEvent('envi-receipts:addItemToBill', itemName, itemPrice)
                end
            end
        },
    }
})

RegisterCommand('receipt', function()
    lib.showContext('main_menu')
end)

-- RegisterCommand('addtobill', function()
--     local input = lib.inputDialog('Add Item to Receipt', {
--         {type = 'input', label = 'Item Name', required = true},
--         {type = 'number', label = 'Item Price', required = true, min = 1}
--     })

--     if input then
--         local itemName = input[1]
--         local itemPrice = tonumber(input[2])
--         TriggerServerEvent('envi-receipts:addItemToBill', itemName, itemPrice)
--     end
-- end)



-- CreateThread(function()
--     while display do
--         Wait(0)
--         DisableControlAction(0, 1, display)
--         DisableControlAction(0, 2, display)
--         DisableControlAction(0, 142, display)
--         DisableControlAction(0, 18, display)
--         DisableControlAction(0, 322, display)
--         DisableControlAction(0, 106, display)
--     end
-- end)

