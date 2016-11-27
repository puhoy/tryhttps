// Generated by CoffeeScript 1.9.3
var lists,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

lists = {};

lists['blacklist'] = getList('blacklist');

chrome.tabs.query(query, function(tabs) {
  var currentTab, domain, element;
  currentTab = tabs[0];
  console.log(currentTab.url);
  domain = _getProtocol_Domain_Path(currentTab.url)[1];
  if (indexOf.call(lists["blacklist"], domain) >= 0) {
    element = document.getElementById("blacklist");
    document.getElementById('unblacklist').addEventListener('click', function() {
      return chrome.runtime.sendMessage({
        type: 'unblacklist',
        name: 'ubl'
      }, null);
    });
  } else {
    element = document.getElementById("unblacklist");
    document.getElementById('blacklist').addEventListener('click', function() {
      return chrome.runtime.sendMessage({
        type: 'blacklist',
        name: 'bl'
      }, null);
    });
  }
  return element.outerHTML = "";
});

//# sourceMappingURL=popup.js.map
