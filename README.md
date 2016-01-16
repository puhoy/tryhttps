# tryhttps

a chrome plugin that tries the https version of the site you are on and, if possible, redirect you.
builds a local db while browsing, containing which sites support https and which not.

pretty early version, but i already use it, seems to work.

## installation

 clone it to some place
 
    git clone git@github.com:puhoy/tryhttps.git
   
 in chrome, open extensions, activate developer mode and choose "load unpacked extensions" 
 

## planned for when i have more time

 * right now all sites are stored in variables at runtime, needs a db
 * blacklist sites from redirecting
 * do something with the button (like show/edit blacklist, clear db...)
