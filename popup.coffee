document.getElementById('blacklist').addEventListener('click', () ->
    chrome.runtime.sendMessage({
        type: 'blacklist',
        name: 'bl'
    }, null)
);

document.getElementById('unblacklist').addEventListener('click', () ->
  chrome.runtime.sendMessage({
      type: 'unblacklist',
      name: 'ubl'
  }, null)
);
