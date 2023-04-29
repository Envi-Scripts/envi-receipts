function updateReceiptHeight() {
    const baseHeight = 300;
    const itemHeight = 20;
    const maxVisibleItems = 8;
  
    const items = document.querySelectorAll('.Receipt .item');
    const itemCount = items.length;
  
    if (itemCount > maxVisibleItems) {
      const extraItems = itemCount - maxVisibleItems;
      const newHeight = baseHeight + (extraItems * itemHeight);
      document.querySelector('.Receipt').style.height = `${newHeight}px`;
    } else {
      document.querySelector('.Receipt').style.height = `${baseHeight}px`;
    }
  }
  
  window.addEventListener('message', function(event) {
    console.log("Received metadata:", event.data.metadata);
    if (event.data.type === "ui") {
        if (event.data.status) {
            updateUI(event.data.metadata);
            display(true);
        } else {
            display(false);
        }
    }
  });
  
  function updateUI(metadata) {
    // Update date and time
    console.log("Received metadata:", metadata);
    $('.header div:nth-child(1)').text('Date: ' + metadata.date);
    $('.header div:nth-child(2)').text('Time: ' + metadata.time);
  
    // Remove existing items
    $('.item').remove();
  
    // Add new items from metadata
    for (var i = 1; metadata['item' + i] && metadata['price' + i]; i++) {
        var itemDiv = $('<div class="item"></div>');
        var descriptionDiv = $('<div class="description"></div>').text(metadata['item' + i]);
        var priceDiv = $('<div class="price"></div>').text('$' + metadata['price' + i]);
  
        itemDiv.append(descriptionDiv);
        itemDiv.append(priceDiv);
        $('.Receipt').append(itemDiv);
    }
  
    // Call the updateReceiptHeight function to adjust the receipt's height
    updateReceiptHeight();
  }
  
  function display(bool) {
    if (bool) {
        $('.Receipt').show();
    } else {
        $('.Receipt').hide();
    }
  }
  
  $(function () {
    display(false);
  
    window.addEventListener('keyup', function (event) {
        if (event.key === 'Escape') {
            console.log("Closing UI");
            window.postMessage({ type: 'closeUI' });
            return;
        }
    });
  });
  
  window.addEventListener('message', (event) => {
    const data = event.data;
  
    if (data.type === 'display') {
        if (data.enable) {
            document.getElementById('container').style.display = 'block';
        } else {
            document.getElementById('container').style.display = 'none';
        }
    }
  });