if Config.Framework == 'esx' then    
    ESX = exports['es_extended']:getSharedObject()
    local playerBills = {}
    local playerTotals = {}

    function addToBill(source, itemName, itemPrice)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.identifier
        playerBills[playerId] = playerBills[playerId] or {}
        playerBills[playerId][itemName] = itemPrice
        playerTotals[playerId] = (playerTotals[playerId] or 0) + itemPrice
        TriggerClientEvent('envi-receipts:notify',source, "Basket Updated", ('Item added to your bill: %s - $%d'):format(itemName, itemPrice), "info", 5000)
    end

    RegisterNetEvent('envi-receipts:addItemToBill')
    AddEventHandler('envi-receipts:addItemToBill', function(itemName, itemPrice)
        addToBill(source, itemName, itemPrice)
    end)

    if Config.Inventory == 'qs' then
        function GetItemMetadata(source, item)
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                local inventoryItem = exports['qs-inventory']:GetItemBySlot(source, item.slot)
                if inventoryItem and inventoryItem.name:lower() == item.name:lower() then
                    return inventoryItem.info
                end
            end
            return nil
        end
    end

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

    function giveBill(source, howMany, paid)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.identifier
        local total = 0
        local basket = ""
        if paid then status = "[ PAYMENT SUCCESSFUL ]" else status = "[ PAYMENT OUTSTANDING ]" end
        local metadata = {
            description = ' ',
            type = xPlayer.job.label,
            payment = paid
        }
        local itemCount = 1
        local currentDate = os.date("%x")
        local currentTime = os.date("%H:%M")
        metadata.date = currentDate
        metadata.time = currentTime
        if playerBills[playerId] then
            basket = "PURCHASED GOODS:\n"
            for item, price in pairs(playerBills[playerId]) do
                basket = basket .. ('- %s - $%d\n'):format(item, price)
                metadata["item" .. itemCount] = item
                metadata["price" .. itemCount] = price
                itemCount = itemCount + 1
                total = total + price
            end
        else
            basket = "Your receipt is empty."
        end
        if Config.UseApGovernmentTax then
            local taxType = "Item"
            local tax_rate = exports['ap-government-esx']:TaxAmounts(taxType)
            print(tax_rate)
            local tax_amount = total * tax_rate
            local total_after_tax = total + tax_amount
            metadata.total = total
            metadata.tax_amount = tax_amount
            metadata.total_after_tax = string.format("%.2f", total_after_tax)
            metadata.description = basket..' - '..status
           AddMetadataItem(source, 'receipt', howMany, metadata)
        else
            local tax_rate = Config.TaxPercentage
            local tax_amount = total * tax_rate
            local total_after_tax = total + tax_amount
            metadata.total = total
            metadata.tax_amount = tax_amount
            metadata.total_after_tax = string.format("%.2f", total_after_tax)
            metadata.description = basket..' - '..status
            AddMetadataItem(source, 'receipt', howMany, metadata)
        end
    end

    function clearBill(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.identifier

        if playerBills[playerId] then
            playerBills[playerId] = {}
            playerTotals[playerId] = 0
            TriggerClientEvent('envi-receipts:notify',source, "Basket Cleared", "The current bill has been cleared.", "success", 5000)
        else
            TriggerClientEvent('envi-receipts:notify',source, "Basket Empty", "There is no bill to clear.", "error", 5000)
        end
    end

    RegisterNetEvent('envi-receipts:clearBill')
    AddEventHandler('envi-receipts:clearBill', function()
        clearBill(source)
    end)

    RegisterNetEvent('envi-receipts:showBasket')
    AddEventHandler('envi-receipts:showBasket', function()
        local basket = showBasket(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent('envi-receipts:notify',source, "Shopping Basket", basket, "info", 10000)
    end)

    RegisterNetEvent('envi-receipts:requestBasket')
    AddEventHandler('envi-receipts:requestBasket', function()
        local basketItems = showBasket(source)
        TriggerClientEvent('envi-receipts:showBasket', source, basketItems)
    end)

    function showBasket(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.identifier
        local basket = {}

        if playerBills[playerId] then
            for item, price in pairs(playerBills[playerId]) do
                table.insert(basket, {item = item, price = price})
            end
        end

        return basket
    end

    RegisterNetEvent('envi-receipts:giveBill', function(howMany, paid)
        giveBill(source, howMany, paid)
    end)

    RegisterNetEvent('envi-receipts:editItem')
    AddEventHandler('envi-receipts:editItem', function(itemName, itemPrice, newItemName, newItemPrice)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.identifier

        if playerBills[playerId] then
            for index, itemData in ipairs(playerBills[playerId]) do
                if itemData.item == itemName and itemData.price == itemPrice then
                    playerBills[playerId][index] = {item = newItemName, price = newItemPrice}
                    break
                end
            end
        end
    end)

    RegisterNetEvent('envi-receipts:removeItem')
    AddEventHandler('envi-receipts:removeItem', function(itemName, itemPrice)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.identifier

        if playerBills[playerId] then
            for index, itemData in ipairs(playerBills[playerId]) do
                if itemData.item == itemName and itemData.price == itemPrice then
                    table.remove(playerBills[playerId], index)
                    break
                end
            end
        end
    end)
    if Config.Inventory == 'ox' then
        ESX.RegisterUsableItem('receipt', function(source, item, data)
            local slot = data.slot
            local xPlayer = ESX.GetPlayerFromId(source)
            local item = exports.ox_inventory:GetSlot(source, slot) 
            if item.metadata then
                TriggerClientEvent('envi-receipts:useReceipt', source, item.metadata)
            end
        end)
    elseif Config.Inventory == 'qs' then
        exports['qs-inventory']:CreateUsableItem('receipt', function(source, item)
            local xPlayer = ESX.GetPlayerFromId(source)
            local metadata = GetItemMetadata(source, item)
            if metadata ~= nil then
                TriggerClientEvent('envi-receipts:useReceipt', source, metadata)
            end
        end)
    end

    ESX.RegisterUsableItem('payment_terminal', function(source)
        TriggerClientEvent('envi-receipts:openPayTerminal', source)
    end)

    RegisterNetEvent('envi-receipts:showReceiptToPlayer')
    AddEventHandler('envi-receipts:showReceiptToPlayer', function(target, slot)
        local item = exports.ox_inventory:GetSlot(source, slot) 
        if item.metadata then
            TriggerClientEvent('envi-receipts:useReceipt', source, item.metadata)
            TriggerClientEvent('envi-receipts:useReceipt', target, item.metadata)
        end
    end)
    if Config.UseApGovernmentTax then
        RegisterNetEvent('envi-receipts:checkTax', function()
            local xPlayer = ESX.GetPlayerFromId(source)
            local taxType = "Item"
            local tax = exports['ap-government-esx']:TaxAmounts(taxType)
            TriggerClientEvent('envi-receipts:notify',source, "Tax Rate", "The current tax rate for "..taxType.."s is "..tax.."%", "info", 5000)
        end)
    else
        RegisterNetEvent('envi-receipts:checkTax', function()
            local xPlayer = ESX.GetPlayerFromId(source)
            local tax = Config.TaxPercentage
            TriggerClientEvent('envi-receipts:notify',source, "The current tax rate is "..tax.."%", "info", 5000)
        end)
    end
    function AddMetadataItem(source, item, amount, metadata)
        local xPlayer = ESX.GetPlayerFromId(source)
        if Config.Inventory == 'ox' then
            exports.ox_inventory:AddItem(source, item, amount, metadata)
        elseif Config.Inventory == 'qb' then
            exports['qb-inventory']:AddItem(source, item, amount, metadata)
        elseif Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
        elseif Config.Inventory == 'core' then   --     WORK IN PROGRESS
            xPlayer.addInventoryItem(item, 1, data)
        end
    end
elseif Config.Framework == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()
    local playerBills = {}
    local playerTotals = {}
    if Config.Inventory == 'qb' then
        function GetItemMetadata(source, item)
            local Player = QBCore.Functions.GetPlayer(source)
            if Player then
                local inventoryItem = Player.PlayerData.items[item.slot]
                if inventoryItem and inventoryItem.name:lower() == item.name:lower() then
                    return inventoryItem.info
                end
            end
            return nil
        end
    elseif Config.Inventory == 'qs' then
        function GetItemMetadata(source, item)
            local xPlayer = QBCore.Functions.GetPlayer(source)
            if xPlayer then
                local inventoryItem = exports['qs-inventory']:GetItemBySlot(source, item.slot)
                if inventoryItem and inventoryItem.name:lower() == item.name:lower() then
                    return inventoryItem.info
                end
            end
            return nil
        end
    end

    function addToBill(source, itemName, itemPrice)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
        playerBills[playerId] = playerBills[playerId] or {}
        playerBills[playerId][itemName] = itemPrice
        playerTotals[playerId] = (playerTotals[playerId] or 0) + itemPrice
        TriggerClientEvent('envi-receipts:notify',source, "Basket Updated", ('Item added to your bill: %s - $%d'):format(itemName, itemPrice), "info", 5000)
    end

    RegisterNetEvent('envi-receipts:addItemToBill')
    AddEventHandler('envi-receipts:addItemToBill', function(itemName, itemPrice)
        addToBill(source, itemName, itemPrice)
    end)

    function printBill(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
        return playerTotals[playerId] or 0
    end

    function showBasket(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
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

    function giveBill(source, howMany, paid)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
        local total = 0
        local basket = ""
        if paid then status = "[ PAYMENT SUCCESSFUL ]" else status = "[ PAYMENT OUTSTANDING ]" end
        local metadata = {
            description = ' ',
            type = xPlayer.PlayerData.job.label,
            payment = paid
        }
        local itemCount = 1
        local currentDate = os.date("%x")
        local currentTime = os.date("%H:%M")
        metadata.date = currentDate
        metadata.time = currentTime
        if playerBills[playerId] then
            basket = "PURCHASED GOODS:\n"
            for item, price in pairs(playerBills[playerId]) do
                basket = basket .. ('- %s - $%d\n'):format(item, price)
                metadata["item" .. itemCount] = item
                metadata["price" .. itemCount] = price
                itemCount = itemCount + 1
                total = total + price
            end
        else
            basket = "Your receipt is empty."
        end
        if Config.UseApGovernmentTax then
            local taxType = "Item"
            local tax_rate = exports['ap-government']:TaxAmounts(taxType)
            local tax_amount = total * tax_rate
            local total_after_tax = total + tax_amount
            metadata.total = total
            metadata.tax_amount = string.format("%.2f",tax_amount)
            metadata.total_after_tax = string.format("%.2f", total_after_tax)
            metadata.description = basket..' - '..status
            AddMetadataItem(source, 'receipt', howMany, metadata)
        else
            local tax_rate = Config.TaxPercentage
            local tax_amount = total * tax_rate
            local total_after_tax = total + tax_amount
            metadata.total = total
            metadata.tax_amount = string.format("%.2f",tax_amount)
            metadata.total_after_tax = string.format("%.2f", total_after_tax)
            metadata.description = basket..' - '..status
            AddMetadataItem(source, 'receipt', howMany, metadata)
        end
    end

    function clearBill(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
        if playerBills[playerId] then
            playerBills[playerId] = {}
            playerTotals[playerId] = 0
            TriggerClientEvent('envi-receipts:notify',source, "Basket Cleared", "The current bill has been cleared.", "success", 5000)
        else
            TriggerClientEvent('envi-receipts:notify',source, "Basket Empty", "There is no bill to clear.", "error", 5000)
        end
    end

    RegisterNetEvent('envi-receipts:clearBill')
    AddEventHandler('envi-receipts:clearBill', function()
        clearBill(source)
    end)

    RegisterNetEvent('envi-receipts:showBasket')
    AddEventHandler('envi-receipts:showBasket', function()
        local basket = showBasket(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        TriggerClientEvent('envi-receipts:notify',source, "Shopping Basket", basket, "info", 10000)
    end)

    RegisterNetEvent('envi-receipts:requestBasket')
    AddEventHandler('envi-receipts:requestBasket', function()
        local basketItems = showBasket(source)
        TriggerClientEvent('envi-receipts:showBasket', source, basketItems)
    end)

    function showBasket(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
        local basket = {}
        if playerBills[playerId] then
            for item, price in pairs(playerBills[playerId]) do
                table.insert(basket, {item = item, price = price})
            end
        end
        return basket
    end

    RegisterNetEvent('envi-receipts:giveBill')
    AddEventHandler('envi-receipts:giveBill', function(howMany, paid)
        giveBill(source, howMany, paid)
    end)

    RegisterNetEvent('envi-receipts:editItem')
    AddEventHandler('envi-receipts:editItem', function(itemName, itemPrice, newItemName, newItemPrice)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local playerId = xPlayer.PlayerData.citizenid
        if playerBills[playerId] then
            for index, itemData in ipairs(playerBills[playerId]) do
                if itemData.item == itemName and itemData.price == itemPrice then
                    playerBills[playerId][index] = {item = newItemName, price = newItemPrice}
                    break
                end
            end
        end
    end)

    RegisterNetEvent('envi-receipts:removeItem')
    AddEventHandler('envi-receipts:removeItem', function(itemName, itemPrice)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local playerId = xPlayer.PlayerData.citizenid
        if playerBills[playerId] then
            for index, itemData in ipairs(playerBills[playerId]) do
                if itemData.item == itemName and itemData.price == itemPrice then
                    table.remove(playerBills[playerId], index)
                    break
                end
            end
        end
    end)

    if Config.Inventory == 'ox' then
        -- QBCore.Functions.CreateUseableItem('receipt', function(source, item, data)
        --     local slot = data.slot
        --     local xPlayer = QBCore.Functions.GetPlayer(source)
        --     local item = exports.ox_inventory:GetSlot(source, slot) 
        --     if item.metadata then
        --         TriggerClientEvent('envi-receipts:useReceipt', source, item.metadata)
        --     end
        -- end)                  -- register the item through ox_inventory instead
    elseif Config.Inventory == 'qs' then
        exports['qs-inventory']:CreateUsableItem('receipt', function(source, item)
            local xPlayer = QBCore.Functions.GetPlayer(source)
            local metadata = GetItemMetadata(source, item)
            if metadata ~= nil then
                TriggerClientEvent('envi-receipts:useReceipt', source, metadata)
            end
        end)
    elseif Config.Inventory =='qb' then
        QBCore.Functions.CreateUseableItem('receipt', function(source, item)
            local xPlayer = QBCore.Functions.GetPlayer(source)
            local metadata = GetItemMetadata(source, item)
            if metadata ~= nil then
                TriggerClientEvent('envi-receipts:useReceipt', source, metadata)
            end
        end)
    end

    
    QBCore.Functions.CreateUseableItem('payment_terminal', function(source)
        TriggerClientEvent('envi-receipts:openPayTerminal', source)
    end)
    
    RegisterNetEvent('envi-receipts:showReceiptToPlayer')
    AddEventHandler('envi-receipts:showReceiptToPlayer', function(target, slot)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local item = xPlayer.Functions.GetItemBySlot(slot)
    
        if item and item.info then
            TriggerClientEvent('envi-receipts:useReceipt', source, item.info)
            TriggerClientEvent('envi-receipts:useReceipt', target, item.info)
        end
    end)
    if Config.UseApGovernmentTax then
        RegisterNetEvent('envi-receipts:checkTax')
        AddEventHandler('envi-receipts:checkTax', function()
            local xPlayer = QBCore.Functions.GetPlayer(source)
            local taxType = "Item"
            local tax = exports['ap-government']:TaxAmounts(taxType)
            TriggerClientEvent('envi-receipts:notify',source, "Tax Rate", "The current tax rate for "..taxType.."s is "..tax.."%", "info", 5000)
        end)
    else
        RegisterNetEvent('envi-receipts:checkTax', function()
            local xPlayer = ESX.GetPlayerFromId(source)
            local tax = Config.TaxPercentage
            TriggerClientEvent('envi-receipts:notify',source, "Tax Rate", "The current tax rate is "..tax.."%", "info", 5000)
        end)
    end
    function AddMetadataItem(source, item, amount, metadata)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if Config.Inventory == 'ox' then
            exports.ox_inventory:AddItem(source, item, amount, metadata)
        elseif Config.Inventory == 'qb' then
            exports['qb-inventory']:AddItem(source, item, amount, nil, metadata)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['receipt'], "add")
        elseif Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
        elseif Config.Inventory == 'core' then
            xPlayer.addInventoryItem(item, 1, data)
        end
    end
end

exports('addToBill', addToBill)
exports('clearBill', clearBill)
exports('showBasket', showBasket)
exports('giveBill', giveBill)
--exports('editItem', editItem)      -- unused currently
--exports('removeItem', removeItem)  -- unused currently
