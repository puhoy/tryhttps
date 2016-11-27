blacklist = []
httpslist = []
httplist = []

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
  if domain in blacklist
    console.log('filtering...')
    index = blacklist.indexOf(domain)
    blacklist.splice(index, 1 if index isnt -1)
    console.log('new blacklist', blacklist...)
    alert('unblacklisted ' + domain)
    return
  else
    console.log('not in blacklist')

blacklistUrl = (url) ->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in blacklist
    blacklist.push(domain)
    console.log('new blacklist', blacklist...)
    alert('blacklisted ' + domain)
    return
  else
    console.log('already in blacklist')



addToHttpsList = (url)->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in httpslist
    httpslist.push(domain)
    console.log('new httpslist', httpslist...)
    return


addToHttpList = (url)->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in httplist
    httplist.push(domain)
    #console.log('new httplist')
    console.log(httplist...)

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
  if url not in blacklist
    if domain in blacklist
      #console.log(domain + 'is blacklisted, wont redirect')
      return false

    # if https, get this in the httpslist if its not in
    #if protocol == 'https:'
    #  if (domain in httpslist)
    #    return false
    #  else
    #    _tryDomain(domain, path, tabId, false)
    #    return false

    #console.log('here we go, trying protocols and stuff..')
    if protocol == 'http:'
      if (domain in httplist)
        console.log('already tried, no https for ' + domain)
        return false
      if (domain in httpslist)
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

