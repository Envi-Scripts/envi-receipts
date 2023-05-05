# Receipt System Documentation

## Table of Contents

1. [Installation](#installation)
    1. [Add Items into qb-core](#11-add-items-into-qb-core)
    2. [Add Metadata to Display in App.js](#12-add-metadata-to-display-in-appjs)
    3. [Ensure You Have ox_lib v3 Installed](#13-ensure-you-have-ox_lib-v3-installed)
2. [Usage](#usage)
    1. [Simple Method](#21-simple-method)
    2. [Advanced Usage](#22-advanced-usage)

## Installation

### 1.1. Add Items into qb-core

Before using the Receipt System, ensure that you have added the necessary items into the qb-core resource. This will enable the system to recognize and process the items needed.

### 1.2. Add Metadata to Display in App.js

To display the item information, insert the following code into your app.js file:

``js
} else if (itemData.name == "receipt") {
  var items = "";
  var i = 1;
  while (itemData.info["item" + i]) {
    items += "<p><strong>Item " + i + ": </strong><span>" + itemData.info["item" + i] + " - $" + itemData.info["price" + i] + "</span></p>";
    i++;
  }
  $(".item-info-title").html("<p>" + itemData.label + "</p>");
  $(".item-info-description").html(
    "<p><strong>Date: </strong><span>" + itemData.info.date + "</span></p>" +
    "<p><strong>Time: </strong><span>" + itemData.info.time + "</span></p>" +
    items +
    "<p><strong>Total: </strong><span>$" + itemData.info.total + "</span></p>" +
    "<p><strong>Tax Amount: </strong><span>$" + itemData.info.tax_amount + "</span></p>" +
    "<p><strong>Total After Tax: </strong><span>$" + itemData.info.total_after_tax + "</span></p>" +
    "<p><strong>Status: </strong><span>" + itemData.info.description.split(' - ')[1] + "</span></p>"
  )
}``

### 1.3. Ensure You Have ox_lib v3 Installed

Make sure you have ox_lib installed on your server. This library is required for the Receipt System to work correctly.

## 2. Usage

### 2.1. Simple Method

The simple method of using the Receipt System involves the following steps:

1. **Trigger menu via item**: To open the Receipt System menu, interact with the in-game item.
2. **Add items manually**: Once the menu is open, you can add items to the receipt by entering their details in the provided menu.
3. **Show Basket**: You can review the items added to the receipt and their prices by checking the basket. If you need to remove any items, simply click the "Clear Basket" button.
4. **Print Receipt**: After finalizing the items and their prices, click the "Print Receipt" button. You will be prompted to select whether the bill is paid in full or not and the number of receipt copies you want to print.

### 2.2. Advanced Usage

To integrate the Receipt System into other resources or utilize server exports for more advanced functionality. 

**addToBill**
This server-side export allows you to add an item to a player's bill:

```lua
-- addToBill(player, itemName, itemPrice)
exports['envi-receipts']:addToBill(source, itemName, itemPrice)```


**clearBill**
This server-side export allows you to clear a player's bill:

```lua
-- clearBill(player)
exports['envi-receipts']:clearBill(source)```


**showBasket**
This server-side export allows you to get a player's bill as a table of items and their prices:

```lua
-- showBasket(player)
local basket = exports['envi-receipts']:showBasket(source)```


**giveBill**
This server-side export allows you to give a receipt to a player with the bill's contents:

```lua
-- giveBill(player, howMany, paid)
exports['envi-receipts']:giveBill(source, 1, true)```


When you want to give a receipt for a single item, you can follow this sequence:
> Clear the bill.
> Add the item to the bill.
> Give the bill to the player.
> Clear the bill again.


Here's an example of how to do this after a QBCore.Function.AddItem in another script:

```lua
RegisterServerEvent('burger:example', function(source)
 local Player = QB.Functions.GetPlayer(source)
 Player.Functions.AddItem("burger", 1)
 exports['envi-receipts']:clearBill(source)      -- clears any old data
 exports['envi-receipts']:addToBill(source, "Burger", 50)   -- adds it to the total bill
 exports['envi-receipts']:giveBill(source, 1, true)  -- prints the items currently added and rewards receipt item
 exports['envi-receipts']:clearBill(source)      -- clear the bill again for good measure
end)```

You can also add as many items as you like/ choose when to print the bill via the item. 
**Lots of possibilities!** 
