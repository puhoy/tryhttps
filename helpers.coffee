getList = (listname) ->
  listname = 'tryhttps_' + listname
  list = []
  try
    l = localStorage[listname]
    list = JSON.parse(l)
  catch e
    console.log("error loading list #{listname}! #{e}")
  lists[listname] = list


saveList = (listname, list) ->
  listname = 'tryhttps_' + listname
  console.log('saving ' + listname + ': ' + list)
  #chrome.storage.local.set({listname: list})
  localStorage[listname] = JSON.stringify(list)


query = {active: true, currentWindow: true};



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
    console.log(typeof lists['httpslist'])
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

_getProtocol_Domain_Path = (url) ->
  arr = url.split('/')
  #console.log(arr)
  prot = arr[0]
  dom = arr[2]
  path = arr[3..]
  return [prot, dom, path.join('/')]

forward_to = (newUrl, tabId) ->
  console.log('forwarding tab ' + tabId + ' to ' + newUrl)
  chrome.tabs.update(tabId, {url: newUrl});


