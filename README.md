# Envi-Receipts

Envi-Receipts is a free open-source resource for ESX or QB-Core
This script utilizes item metadata and a simple UI to create an immersive shopping experience!

**NOW SUPPORTS OX INVENTORY, QB-INVENTORY AND QS-INVENTORY V2**

## Features:

1. **Integration with ESX/QB-Core**: The system is compatible with popular frameworks, ensuring seamless functionality with your existing setup.
2. **Customizable item display**: You can easily add metadata to display item information in our realistic user interface.
3. **Ox_lib Support**: The Receipt System requires and supports ox_lib v3 for a clean user experience.
4. **Simple and Advanced Usage**: The system provides both simple and advanced methods for using the Receipt System, catering to users with different needs and skill levels.
5. **Server-side exports**: Several server-side exports are available for integrating the Receipt System with other resources or utilizing more advanced functionality.
6. **User-friendly Menus**: The Receipt System offers an intuitive in-game menu for adding, reviewing, and managing items and receipts.
7. **Flexible receipt printing**: Users can print receipts with customizable details, such as payment status and the number of copies.
8. **Add items to receipt**: The Receipt System allows users to easily add items to the bill by entering their details in the provided menu.
9. **Clear receipt**: Users can clear the bill to remove all items and start fresh.
10. **Show receipt**: The Receipt System provides a feature to review the items added to the receipt and their prices.
11. **Print receipt**: The system allows users to give a receipt to a player with the bill's contents.
12. **Multiple item management**: You can add as many items as needed via simple or advanced methods, and choose to print the bill via the item, providing a lot of flexibility and possibilities.
13. **Realistic UI**: View the receipts and all it's info including tax, sub-total, itemised list and more!
14. **Tax System**: Will allow you to set your own tax percentage in the config file.
15. **AP-Government Compatibility**: Easy linked with AP Script's Government system to automatically calculate current item tax!
16. **Custom Prop from BzZz**: Payment terminal prop from the amazingly talented BzZz! - https://bzzz.tebex.io


Preview:
https://youtu.be/srlHgmRgGWY

## Table of Contents

1. [Installation](#installation)
    1. [Add Items into inventory/ qb-core](#11-add-items-into-qb-core)
    2. [Add Metadata to Display in App.js](#12-add-metadata-to-display-in-appjs)
    3. [Ensure You Have ox_lib v3 Installed](#13-ensure-you-have-ox_lib-v3-installed)
2. [Usage](#usage)
    1. [Simple Method](#21-simple-method)
    2. [Advanced Usage](#22-advanced-usage)

## Installation

### 1.1. Add Items into your qb-core or ox_inventory! ('receipt' and 'payment_terminal')

### 1.1.2 Set up your items like this for additonal functionality! **(OX INVENTORY ONLY)**
```lua
['receipt'] = {
	label = 'Receipt',
	weight = 20, 
	stack = false,
	close = true,
	description = nil,
	buttons = {
		{
			label = 'Show Receipt',
			action = function(slot)
				TriggerEvent('envi-receipts:showReceiptToClosestPlayer', slot)
			end
		}
	}
},

['payment_terminal'] = {
	label = 'Receipt Printer',
	weight = 2000, 
	stack = false,
	close = true,
	description = 'A handy device for printing receipts on-the-go!',
	buttons = {
		{
			label = 'Print Receipt',
			action = function()
				TriggerEvent('envi-receipts:quickPrint')
			end
		}
	}
},
```

Before using the Receipt System, ensure that you have added the necessary items into the appropriate resource. This will enable the system to recognize and process the items needed.

### 1.2. Add Metadata to Display in App.js **(QB-INVENTORY ONLY)**

To display the item information, insert the following code into your app.js file:

```js
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
    "<p><strong>Status: </strong><span>" + itemData.info.description.split(' - ').pop() + "</span></p>"
  )
}
```
### 1.2.2. Add Metadata to Display in qs-inventory/config/metadata.js **(QS-INVENTORY ONLY)**
```js
        } else if (itemData.name == "receipt") {
            $(".item-info-title").html("<p>" + itemData.label + "</p>");
            $(".item-info-description").html(
              "<p><strong>Date: </strong><span>" + itemData.info.date + "</span></p>" +
              "<p><strong>Heure: </strong><span>" + itemData.info.time + "</span></p>" +
              "<p><strong>Total: </strong><span>$" + itemData.info.total + "</span></p>" +
              "<p><strong>Tax: </strong><span>$" + itemData.info.tax_amount + "</span></p>" +
              "<p><strong>Total après Tax: </strong><span>$" + itemData.info.total_after_tax + "</span></p>" +
              "<p><strong>Status: </strong><span>" + itemData.info.description + "</span></p>"
            );
```

### 1.2.3. Register The Receipt Item in your Ox_Inventory (**ONLY IF YOU ARE USING OX WITH QB-CORE!!**)

Add this to *ox_inventory > modules > items > client.lua*
```lua
Item('receipt', function(data, slot)
    TriggerEvent("envi-receipts:useReceipt", slot.metadata)
end)
```

### 1.3. Ensure You Have ox_lib Installed

Make sure you have ox_lib installed on your server. This library must be started before envi-receipts.

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
exports['envi-receipts']:addToBill(source, itemName, itemPrice)
```


**clearBill**
This server-side export allows you to clear a player's bill:

```lua
-- clearBill(player)
exports['envi-receipts']:clearBill(source)
```


**showBasket**
This server-side export allows you to get a player's bill as a table of items and their prices:

```lua
-- showBasket(player)
local basket = exports['envi-receipts']:showBasket(source)
```


**giveBill**
This server-side export allows you to give a receipt to a player with the bill's contents:

```lua
-- giveBill(player, howMany, paid)
exports['envi-receipts']:giveBill(source, 1, true)
```


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
end)
```

You can also add as many items as you like/ choose when to print the bill via the item. 
**Lots of possibilities!** 
