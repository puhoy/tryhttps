lists = {}
lists['blacklist'] = getList('blacklist')

chrome.tabs.query(query,
  (tabs) ->
    currentTab = tabs[0]
    console.log(currentTab.url)
    domain = _getProtocol_Domain_Path(currentTab.url)[1]
    if domain in lists["blacklist"]
      element = document.getElementById("blacklist");

      document.getElementById('unblacklist').addEventListener('click', () ->
        chrome.runtime.sendMessage({
            type: 'unblacklist',
            name: 'ubl'
        }, null)
      );
    else
      element = document.getElementById("unblacklist");
      document.getElementById('blacklist').addEventListener('click', () ->
            chrome.runtime.sendMessage({
                type: 'blacklist',
                name: 'bl'
            }, null)
        );
    element.outerHTML = "";
)

