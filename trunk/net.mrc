;; determine IP type between ipv4 and ipv6 from input. Not really foolproof, but.. meh.
alias ipType {
    if (*.* iswm $1) {
        return IPv4
    }
    elseif (*:* iswm $1) {
        return IPv6
    }
}

;; this is to save time looping through all networks to find the scid for the one you want.
alias scidresolve {
    if ($1 == refresh) {
        var %ticks $ticks
        zLog -net Refreshing ServerConnectionID cache...
        if ($hget(scidresolve) != $null) {
            hfree scidresolve
        }
        var %count 1
        var %total $scon(0)
        while (%count <= %total) {
            var %network $scon(%count).$network
            var %scid $scon(%count)
            zLog -net >> $pad(20, %network) -> %scid
            hadd -m scidresolve %network %scid
            inc %count
        }
        return ServerConnectionID cache refreshed successfully in $+($dur(%ticks).suf,.)
    }
    else {
        return $hget(scidresolve, $1)
    }
}

alias conf_net {
    dialog -m conf_net_main conf_net_main
}

on *:DIALOG:conf_net_*:*:*: {
    if ($dname == conf_net_main) {
        if ($devent == init) {
            zLog -init Initializing network dialog...
            var %dir $scriptdiretc\net\
            zLog -init +1 Configuration directory: %dir
            if ($findfile(%dir, *.ini, 0, 1) == 0) {
                zLog -init +2 No configuration exists, generating defaults.
                var %ini $+(%dir,p2p-net.ini)
                writeini $qt(%ini) servers 1 irc.p2p-network.net
                writeini $qt(%ini) channels 1 #zomgwtfbbq
                flushini
            }
            zLog -init +1 $findfile(%dir, *.ini, 0, 1, did -a $dname 1 $gettok($nopath($1-), 1, 46)) config files found and added.
        }
        elseif ($devent == sclick) {
            if ($did == 2) {
                var %q $?="Enter a name for the new network..."
                if (%q != $null) {
                    var %ini $+($scriptdiretc\net\,%q,.ini)
                    writeini $qt(%ini) servers 1 $+(irc.,%q,.net)
                }
            }
            elseif ($did == 3) {
                did -b $dname 1-7
                dialog -m conf_net_sub conf_net_sub
            }
            elseif ($did == 4) {
                var %net $did($dname, 1, $did($dname, 1).sel).text
                zLog -debug %net
                var %q $?!="Are you sure you want to remove %net and it's configuration?"
                if (%q == $true) {
                    zLog -debug Removing $qt($+($scriptdiretc\net\,%net,.ini))
                    remove $qt($+($scriptdiretc\net\,%net,.ini))
                    did -d $dname 1 $did($dname, 1).sel
                }                
            }
        }
    }
    elseif ($dname == conf_net_sub) {
        var %network $did(conf_net_main, 1, $did(conf_net_main, 1).sel).text
        var %ini $+($scriptdiretc\net\,%network,.ini)
        if ($devent == init) {            
            dialog -t $dname Settings for %network            
            if ($file(%ini) != $null) {
                ;; ---- user info ----
                ;; nickname
                var %mnick $readini(%ini, userinfo, mnick)
                did -a $dname 3 $iif(%mnick != $null, %mnick, $mnick)
                ;; alternate nickname
                var %anick $readini(%ini, userinfo, anick)
                did -a $dname 5 $iif(%anick != $null, %anick, $anick)
                ;; ident
                var %ident $readini(%ini, userinfo, ident)
                did -a $dname 7 $iif(%ident != $null, %ident, zOWBscript)
                ;; real name
                var %rname $readini(%ini, userinfo, rname)
                did -a $dname 8 $iif(%rname != $null, %rname, zOWBscript $readini($scriptdirdat\zscript.ini, core, version_main) $readini($scriptdirdat\zscript.ini, core, version_suf) User)
                ;; ---- network info ----
                ;; Perform on connect
                var %perform $readini(%ini, netinfo, perform)
                did -a $dname 12 %perform
                ;; Password
                var %password $readini(%ini, netinfo, password)
                did -a $dname 14 %password
                ;; Autoconnect
                var %autoconnect $readini(%ini, netinfo, autoconnect)
                did $+(-,$iif(%autoconnect == 1, c, u)) $dname 15
                ;; ---- Servers ----
                var %count 1
                var %total $ini(%ini, servers, 0)
                while (%count <= %total) {
                    did -a $dname 17 $readini(%ini, servers, $ini(%ini, servers, %count))
                    inc %count
                }
                ;; ---- Channels ----
                var %count 1
                var %total $ini(%ini, channels, 0)
                while (%count <= %total) {
                    did -a $dname 21 $readini(%ini, channels, $ini(%ini, channels, %count))
                    inc %count
                }
                ;; ---- join ----
                ;; enabled?
                var %join $readini(%ini, join, enabled)
                did $+(-,$iif(%join == 1, c, u)) $dname 27
                ;; Timeout
                var %timeout $readini(%ini, join, timeout)
                did -a $dname 28 $iif(%timeout != $null, %timeout, 10)
            }
        }
        if ($devent == sclick) {
            zLog -debug $dname $devent $did
            ;; add server
            if ($did == 18) {
                var %server $?="Server address:"
                if (%server != $null) {
                    writeini $qt(%ini) servers %server %server
                    did -a $dname 17 %server
                }
            }
            elseif ($did == 19) {
                var %server $did($dname, 17, $did($dname, 17).sel).text
                var %q $?!="Are you sure you want to remove %server from $+(%network,?) "
                if (%q == $true) {
                    remini $qt(%ini) servers %server
                    did -d $dname 17 $did($dname, 17).sel
                }
            }
            elseif ($did == 22) {
                var %channel $?="Channel name:"
                if (%channel != $null) {
                    writeini $qt(%ini) channels %channel %channel
                    did -a $dname 21 %channel
                }
            }
            elseif ($did == 23) {
                var %channel $did($dname, 21, $did($dname, 21).sel).text
                var %q $?!="Are you sure you want to remove %channel from $+(%network,?) "
                if (%q == $true) {
                    remini $qt(%ini) channels %channel
                    did -d $dname 21 $did($dname, 21).sel
                }
            }
            elseif ($did == 24) {
                dialog -x $dname
            }
        }
        if ($devent == close) {
            did -e conf_net_main 1-7
        }
    }
}

dialog conf_net_main {
    title "NetworkManager"
    size -1 -1 110 114
    option dbu
    list 1, 1 1 69 103, size
    button "Add...", 2, 72 2 37 12
    button "Edit...", 3, 72 15 37 12
    button "Remove", 4, 72 28 37 12
    button "Connect", 5, 71 79 37 12
    button "Close", 6, 71 92 37 12
    check "Autoconnect on startup", 7, 1 104 69 10
}

dialog conf_net_sub {
    title "Settings for :network:"
    size -1 -1 207 141
    option dbu
    box "User info", 1, 1 1 126 49
    text "Nick", 2, 6 9 25 8
    edit "", 3, 34 7 90 10
    text "Alt nick", 4, 6 19 25 8
    edit "", 5, 34 17 90 10
    text "Ident", 6, 6 29 25 8
    edit "", 7, 34 27 90 10
    edit "", 8, 34 37 90 10
    text "Real name", 9, 6 39 25 8
    box "Network info", 10, 1 50 126 40
    text "Perform", 11, 6 59 25 8
    edit "", 12, 34 57 90 10
    text "Password", 13, 6 68 25 8
    edit "", 14, 34 67 90 10, pass
    check "Autoconnect to this network", 15, 34 78 89 10
    box "Servers", 16, 1 90 126 50
    list 17, 4 98 105 39, sort size extsel
    button "+", 18, 111 98 13 12
    button "-", 19, 111 111 13 12
    box "Channels", 20, 129 1 77 126
    list 21, 132 8 71 88, sort size
    button "+", 22, 175 97 13 12
    button "-", 23, 189 97 13 12
    button "Cancel", 24, 129 128 37 12
    button "Ok", 25, 168 128 38 12
    box "", 26, 130 108 75 4
    check "Join after", 27, 133 114 33 10
    edit "", 28, 167 113 15 10
    text "seconds", 29, 183 115 21 8
}

