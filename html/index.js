window.addEventListener('message', function (event) {
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
  $('.header div:nth-child(1)').text('Date: ' + metadata.date);
  $('.header div:nth-child(2)').text('Hour: ' + metadata.time);
  if (metadata.type && metadata.type !== null) {
    $('.business-name').text(metadata.type);
  } else {
    $('.business-name').text('');
  }
  $('.item').remove();
  for (var i = 1; metadata['item' + i] && metadata['price' + i]; i++) {
    var itemDiv = $('<div class="item"></div>');
    var descriptionDiv = $('<div class="description"></div>').text(metadata['item' + i]);
    var priceDiv = $('<div class="price"></div>').text(metadata['price' + i] + ' $');
    itemDiv.append(descriptionDiv);
    itemDiv.append(priceDiv);
    $('.items').append(itemDiv);
  }
  let totalCost = 0;
  for (var i = 1; metadata['price' + i]; i++) {
    totalCost += parseFloat(metadata['price' + i]);
  }

  $('.sub-total').text('Sub Total: ' + totalCost.toFixed(2) + ' $');
  $('.tax-amount').text('Tax: ' + metadata.tax_amount + ' $');
  $('.grand-total').text('Total: ' + metadata.total_after_tax + ' $');
}
function display(bool) {
  if (bool) {
    $('.Receipt').fadeIn(350);
  } else {
    $('.Receipt').fadeOut(350);
  }
}

$(function () {
  display(false);

  window.addEventListener('keyup', function (event) {
    if (event.key === 'Escape') {
      $.post(`https://${GetParentResourceName()}/closeUI`);
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