on *:SIGNAL:$($nopath($script)): {
    if ($hget(tmp, zSplash) != 0) {
        hadd zs status_text Initializing $+($nopath($script),...)
        .signal -n zSplash update
    }
    if ($1 == init) {
        var %ini $scriptdiretc\away.ini
        if ($file(%ini) == $null) {
            var %ticks $ticks
            zLog -conf $init(conf, gen, %ini, core, awaynotice=1 awaynotice.timeout=3600 autoaway=0)
            zLog -conf +2 Defaults for $script generated in $+($dur(%ticks).suf,.)
            noop $sleep(500)
            .signal -n $nopath($script) init
        }
        else {
            var %ticks.total $ticks
            zLog -init +2 Initializing settings for $+($script,.)
            var %ini $scriptdiretc\away.ini
            zLog -init +3 $init(conf, load, %ini, core, zAway, 5)
            zLog -init +2 Initialization for $script completed in $+($dur(%ticks.total).suf,.)
        }
    }
}

alias away {
    if ($isid == $false) {
        if (($1 == -awaynotice) && ($3 == $null)) {
            if ($hget(zAway, awaynotice) == 1) {
                if ($hget(zAway.data, $+(awaynotice.,$2)) == $null) {
                    hadd $+(-mu,$hget(zAway, awaynotice.timeout)) zAway.data $+(awaynotice.,$2) 1
                    return I am currently away: $hget(zAway.data, $+($network,.reason)) - Gone since $asctime($hget(zAway.data, $+($network,.ctime)), $hget(zCore, asctime_full) zzz) $+($chr(40),$duration($hget(zAway.data, $+($network,.ctime))),$chr(32),ago,$chr(41),.)
                }
            }
        }
        elseif ($1 == $null) {
            .!away
            hdel zAway.data $+($network,.*)
        }
        else {
            hadd -m zAway.data $+($network,.reason) $1-
            hadd -m zAway.data $+($network,.ctime) $ctime
            .!away $hget(zAway.data, $+($network,.reason)) - Gone since $asctime($ctime, $hget(zCore, asctime_full) zzz)
        }
    }
    else {
        if ($awaymsg == $null) {
            return $false
        }
        else {
            return $true
        }
    }
}

alias conf_away {
    dialog -m conf_away conf_away
}

on *:DIALOG:conf_away:*:*: {
    if ($devent == init) {
        if ($hget(zAway, autoaway.enabled) == 1) {
            did -c $dname 2
        }
        else {
            did -b $dname 3-8
        }
        if ($hget(zAway, autoaway.timeout) != $null) {
            did -a $dname 4 $hget(zAway, autoaway.timeout)
        }
        noop $dPopulateCombo($dname, 5).tUnits
        did $dCheck($hget(zAway, autoaway.ReturnOnActivity)) $dname 6
        if ($hget(zAway, autoaway.msg) != $null) {
            did -a $dname 8 $hget(zAway, autoaway.msg)
        }
        ;;--
        if ($hget(zAway, defaultmsg) != $null) {
            did -a $dname 11 $hget(zAway, defaultmsg)
        }
        did $dCheck($hget(zAway, awaynotice.channel)) $dname 12
        if ($hget(zAway, awaynotice.channel.timeout) != $null) {
            did -a $dname 17 $hget(zAway, awaynotice.channel.timeout)
        }
        noop $dPopulateCombo($dname, 18).tUnits
        did $dCheck($hget(zAway, awaynotice.query)) $dname 13
        if ($hget(zAway, awaynotice.query.timeout) != $null) {
            did -a $dname 21 $hget(zAway, awaynotice.query.timeout)
        }
        noop $dPopulateCombo($dname, 22).tUnits
    }
    elseif ($devent == close) {
        var %q $?!="Do you wish to save any changes?"
        if (%q == $true) {
            conf_away_save
        }
    }
    elseif ($devent == sclick) {
        if ($did == 15) {
            conf_away_save
        }
    }
}

alias conf_away_save {
    var %dname conf_away
    var %ini $scriptdiretc\away.ini
    var %error.count 0
    writeini $qt(%ini) core autoaway.enabled $did(%dname, 2).state
    if ($did(%dname, 4).text isnum) {
        writeini $qt(%ini) core autoaway.timeout $did(%dname, 4).text
    }
    else {
        inc %error.count
    }
    writeini $qt(%ini) core autoaway.ReturnOnActivity   $did(%dname, 6).state
    writeini $qt(%ini) core autoaway.msg                $did(%dname, 8).text
    ;;--
    writeini $qt(%ini) core defaultmsg                  $did(%dname, 11).text
    writeini $qt(%ini) core awaynotice.channel          $did(%dname, 12).state
    if ($did(%dname, 17).text isnum) {
        writeini $qt(%ini) core awaynotice.channel.timeout $did(%dname, 17).text
    }
    else {
        inc %error.count
    }
    writeini $qt(%ini) core awaynotice.query            $did(%dname, 13).state
    if ($did(%dname, 21).text isnum) {
        writeini $qt(%ini) core awaynotice.query.timeout $did(%dname, 21).text
    }
    else {
        inc %error.count
    }
    if (%error.count > 0) {
        zError_Dialog %error.count errors were encountered during save. This likely means that you have entered invalid input in a textbox. Invalid changes have not been saved.
    }
    .signal -n $nopath($script) init
}

dialog conf_away {
    title "Away configuration"
    size -1 -1 157 122
    option dbu
    box "Auto away", 1, 0 0 157 51
    check "Enabled", 2, 4 8 50 10
    text "After", 3, 4 19 14 8
    edit "", 4, 28 18 24 10
    combo 5, 53 18 46 10, drop
    check "Return on activity", 6, 3 40 53 10
    text "Message:", 7, 3 30 24 8
    edit "", 8, 28 29 126 10
    box "Misc.", 9, 0 51 157 58
    text "Default msg:", 10, 4 58 32 8
    edit "", 11, 38 57 116 10
    check "Away notice on channel highlight", 12, 3 67 89 10
    check "Away notice on /query", 13, 3 87 89 10
    button "Cancel", 14, 82 110 37 12, cancel
    button "Ok", 15, 120 110 37 12, default
    text "Wait", 16, 13 77 13 8
    edit "", 17, 28 76 24 10
    combo 18, 52 76 46 10, drop
    text "before repeating", 19, 99 77 42 8
    text "Wait", 20, 13 98 13 8
    edit "", 21, 28 97 24 10
    combo 22, 52 97 46 10, drop
    text "before repeating", 23, 99 98 42 8
}

