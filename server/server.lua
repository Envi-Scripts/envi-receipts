ESX = exports['es_extended']:getSharedObject()

local playerBills = {}
local playerTotals = {}

function addToBill(source, itemName, itemPrice)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    playerBills[playerId] = playerBills[playerId] or {}
    playerBills[playerId][itemName] = itemPrice

    playerTotals[playerId] = (playerTotals[playerId] or 0) + itemPrice

    xPlayer.showNotification(('Item added to your bill: %s - $%d'):format(itemName, itemPrice))
end

exports('addToBill', addToBill)

RegisterServerEvent('envi-receipts:addItemToBill')
AddEventHandler('envi-receipts:addItemToBill', function(itemName, itemPrice)
    addToBill(source, itemName, itemPrice)
end)

function printBill(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    return playerTotals[playerId] or 0
end

function showBasket(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    local basket = ""

    if playerBills[playerId] then
        basket = "Your shopping basket:\n"
        for item, price in pairs(playerBills[playerId]) do
            basket = basket .. ('%s $%d\n'):format(item, price)
        end
    else
        basket = "Your shopping basket is empty."
    end

    return basket
end

function giveBill(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    local basket = ""
    local metadata = {
        description = ' ',
        type = xPlayer.job.label
    }
    local itemCount = 1
    local currentDate = os.date("%x")
    local currentTime = os.date("%H:%M")
    metadata.date = currentDate
    metadata.time = currentTime
    if playerBills[playerId] then
        basket = "RECEIPT:\n"
        for item, price in pairs(playerBills[playerId]) do
            basket = basket .. ('%s $%d\n'):format(item, price)
            metadata["item" .. itemCount] = item
            metadata["price" .. itemCount] = price
            itemCount = itemCount + 1
        end
    else
        basket = "Your receipt is empty."
    end
    metadata.description = basket
    exports.ox_inventory:AddItem(source, 'receipt', 1, metadata)
end

function clearBill(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    if playerBills[playerId] then
        playerBills[playerId] = {}
        playerTotals[playerId] = 0
        print("Your bill has been cleared.")
    else
        print("There is no bill to clear.")
    end
end

RegisterServerEvent('envi-receipts:clearBill')
AddEventHandler('envi-receipts:clearBill', function()
    clearBill(source)
end)

RegisterServerEvent('envi-receipts:showBasket')
AddEventHandler('envi-receipts:showBasket', function()
    local basket = showBasket(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(basket)
end)

RegisterServerEvent('envi-receipts:giveBill')
AddEventHandler('envi-receipts:giveBill', function()
    giveBill(source)
end)

-- ESX.RegisterUsableItem('receipt', function(source)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     local receipt, receiptSlot = exports.ox_inventory:GetItem(source, 'receipt', nil, false)
--     local playerItems = exports.ox_inventory:GetInventoryItems(source)
--     for _, item in ipairs(playerItems) do
--         if item.name == 'receipt' then
--             local metadata = item.metadata
--             if metadata then
--                 TriggerClientEvent('envi-receipts:useReceipt', source, metadata)
--                 break
--             end
--         end
--     end

--     -- if receipt and receipt.count > 0 then
--     --     local metadata = receipt.metadata
--     --     print("Sending metadata to client:", json.encode(metadata))
--     --     TriggerClientEvent('envi-receipts:useReceipt', source, metadata)
--     -- else
--     --     xPlayer.showNotification('You do not have a receipt.')
--     -- end
-- end)
ESX.RegisterUsableItem('receipt', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventory = exports.ox_inventory:GetInventory(source)
    
    for slot = 1, inventory.slots do
        local item = exports.ox_inventory:GetSlot(source, slot)
        
        if item and item.name == 'receipt' then
            print("Receipt item:", item)
            print("Receipt metadata:", item.metadata)
            
            if item.metadata then
                TriggerClientEvent('envi-receipts:useReceipt', source, item.metadata)
                print("Encoded metadata:", json.encode(item.metadata))
                break
            end
        end
    end
end)



-- function giveBill(source)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     local playerId = xPlayer.identifier
--     local basket = ""
--     if playerBills[playerId] then
--         basket = "RECEIPT:\n"
--         for item, price in pairs(playerBills[playerId]) do
--             basket = basket .. ('%s $%d\n'):format(item, price)
--         end
--     else
--         basket = "Your receipt is empty."
--     end
--     local metadata = {
--         description = basket,
--         type = 'Cyber Garage', -- placeholder
--     }
--     exports.ox_inventory:AddItem(source, 'bread', 1, metadata)
-- end

exports('giveBill', giveBill)
exports('addToBill', addToBill)
exports('printBill', printBill)
exports('showBasket', showBasket)
exports('clearBill', clearBill)