blacklist = []
httpslist = []
httplist = []


addToHttpsList = (url)->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in httpslist
    httpslist.push(domain)
    #console.log('new httpslist')
    console.log(httpslist...)


addToHttpList = (url)->
  domain = _getProtocol_Domain_Path(url)[1]
  if domain not in httplist
    httplist.push(domain)
    #console.log('new httplist')
    console.log(httplist...)

_tryDomain = (domain, path, tabId, forward=true)->
  xhr = new XMLHttpRequest();
  xhr.open("GET", "https://" + domain, true); # async
  got_200 = false
  xhr.onreadystatechange = () ->
    if (xhr.readyState == 2)  # got headers
      if xhr.status == 200
        got_200 = true
        addToHttpsList('https://' + domain)
        if forward
          forward_to('https://' + [domain, path].join('/'), tabId)
  xhr.timeout = 10000; # 10s
  xhr.ontimeout = () ->
    got_200 = false
    addToHttpList('http://' + domain)
  xhr.send();
  return got_200



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
    if protocol == 'https:'
      if (domain in httpslist)
        return false
      else
        _tryDomain(domain, path, tabId, false)
        return false

    #console.log('here we go, trying protocols and stuff..')
    if protocol == 'http:'
      if (domain in httplist)
        console.log('already tried, no https for ' + domain)
        return false

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
);

chrome.tabs.onCreated.addListener((tabId, changeInfo, tab) ->
  if changeInfo
    if changeInfo.url
      tryHttps(changeInfo.url, tabId)
);
