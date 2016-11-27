lists = {}
lists['blacklist'] = getList('blacklist')
lists['httpslist'] = getList('httpslist')
lists['httplist'] = []


chrome.runtime.onMessage.addListener((request, sender, callback) ->
  if (request.type == 'blacklist')
    console.log('blacklisting...')
    _blacklistUrl()
  if (request.type == 'unblacklist')
    console.log('unblacklisting...')
    _unblacklistUrl()
);

_tryDomain = (domain, path, tabId, forward = true)->
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

