

getList = (listname) ->
  listname = 'tryhttps_' + listname
  list = localStorage[listname]
  if list
    console.log('loaded list ' + listname + ': ', list)
    lists[listname] = list
  else
    lists[listname] = []
  #)

lists = {}
lists['blacklist'] = getList('blacklist')
lists['httpslist'] = getList('httpslist')
lists['httplist'] = []


saveList = (listname, list) ->
  listname = 'tryhttps_' + listname
  console.log('saving ' + listname + ': ' + list)
  #chrome.storage.local.set({listname: list})
  localStorage[listname] = list


chrome.runtime.onMessage.addListener((request, sender, callback) ->
    if (request.type == 'blacklist')
      console.log('blacklisting...')
      _blacklistUrl()
    if (request.type == 'unblacklist')
      console.log('unblacklisting...')
      _unblacklistUrl()
);

query = { active: true, currentWindow: true };

_unblacklistUrl = () ->
  chrome.tabs.query(query,
    (tabs) ->
      currentTab = tabs[0]
      console.log(currentTab)
      console.log('unblacklisting ' + currentTab.url)
      unblacklistUrl(currentTab.url)
  )

_blacklistUrl = () ->
  chrome.tabs.query(query,
    (tabs) ->
      currentTab = tabs[0]
      console.log(currentTab)
      blacklistUrl(currentTab.url)
  )

unblacklistUrl = (url) ->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain in lists['blacklist']
    console.log('filtering...')
    index = lists['blacklist'].indexOf(domain)
    lists['blacklist'].splice(index, 1 if index isnt -1)
    saveList('blacklist', lists['blacklist'])
    console.log('new blacklist', lists['blacklist']...)
    alert('unblacklisted ' + domain)
    return
  else
    console.log('not in blacklist')

blacklistUrl = (url) ->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in lists['blacklist']
    lists['blacklist'].push(domain)
    saveList('blacklist', lists['blacklist'])
    console.log('new blacklist', lists['blacklist']...)
    alert('blacklisted ' + domain)
    return
  else
    console.log('already in blacklist')



addToHttpsList = (url)->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in lists['httpslist']
    lists['httpslist'].push(domain)
    saveList('httpslist', lists['httpslist'])
    console.log('new httpslist', lists['httpslist']...)
    return


addToHttpList = (url)->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in lists['httplist']
    lists['httplist'].push(domain)
    #console.log('new httplist')
    console.log(lists['httplist']...)

_tryDomain = (domain, path, tabId, forward=true)->
  xhr = new XMLHttpRequest();
  xhr.open("GET", "https://" + domain, true); # async
  got_2xx = false
  xhr.onreadystatechange = () ->
    if (xhr.readyState == 2)  # got headers
      if xhr.status >= 200 and xhr.status < 300
        got_2xx = true
        addToHttpsList('https://' + domain)
        if forward
          forward_to('https://' + [domain, path].join('/'), tabId)
  xhr.timeout = 10000; # 10s
  xhr.ontimeout = () ->
    got_2xx = false
    console.log('no https for ' + domain)
    addToHttpList('http://' + domain)
  xhr.send();
  return got_2xx



_getProtocol_Domain_Path = (url) ->
  arr = url.split('/')
  #console.log(arr)
  prot = arr[0]
  dom = arr[2]
  path = arr[3..]
  return [prot, dom, path.join('/')]

tryHttps = (url, tabId) ->
  #return url + '?'
  pdm = _getProtocol_Domain_Path(url)
  protocol = pdm[0]
  domain = pdm[1]
  path = pdm[2]

  # wenn nicht blacklisted:
  if domain in lists['blacklist']
    #console.log(domain + 'is blacklisted, wont redirect')
    return false

  #console.log('here we go, trying protocols and stuff..')
  if protocol == 'http:'
    if (domain in lists['httplist'])
      console.log('already tried, no https for ' + domain)
      return false
    if (domain in lists['httpslist'])
      forward_to('https://' + [domain, path].join('/'), tabId)

    else
      #return 'https://' + [domain, path].join('/')
      if _tryDomain(domain, path, tabId)
        return true
      else
        return false

forward_to = (newUrl, tabId) ->
  console.log('forwarding tab ' + tabId + ' to ' + newUrl)
  chrome.tabs.update(tabId, {url: newUrl});


chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) ->
    if changeInfo
      if changeInfo.url
        tryHttps(changeInfo.url, tabId)
)

chrome.tabs.onCreated.addListener((tabId, changeInfo, tab) ->
    if changeInfo
      if changeInfo.url
        tryHttps(changeInfo.url, tabId)
)

