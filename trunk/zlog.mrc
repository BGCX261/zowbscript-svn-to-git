on *:SIGNAL:$($nopath($script)): {
    if ($hget(tmp, zSplash) != 0) {
        hadd zs status_text Initializing $+($nopath($script),...)
        .signal -n zSplash update
    }
    if ($1 == init) {
        if ($window(@zConsole) != $null) {
            window -ek0 @zConsole
        }
        var %ini $scriptdiretc\zlog.ini
        if ($file(%ini) == $null) {
            var %ticks $ticks
            echo @zConsole >> >> $init(conf, gen, %ini, core, enabled=1 logtodisk=0 logtodisk.timeout=30)
            echo @zConsole >> Defaults for $script generated in $+($dur(%ticks).suf,.)
            noop $sleep(500)
            .signal -n $nopath($script) init
        }
        else {
            var %ticks.total $ticks
            echo @zConsole >> >>  Initializing settings for $+($script,.)
            var %ini $scriptdiretc\zlog.ini
            echo @zConsole >> >> >> $init(conf, load, %ini, core, zLog, 5)
            var %ini $scriptdirdat\zlog.ini
            echo @zConsole >> >> >> $init(conf, load, %ini, switches, zLog.switches, 10)
            echo @zConsole >> >> Configuration for $script initialized in $+($dur(%ticks.total).dur,.)
        }
    }
}

alias zlog {
    if ($hget(zLog, enabled) == 1) {
        if ($window(@zConsole) == $null) {
            window -ek0 @zConsole
        }
        var %switch $right($1, -1)
        if ($hget(zLog.switches, %switch) != $null) {
            var %c $hget(zLog.switches, %switch)
            if ($left($2, 1) == +) {
                var %message $ts $pad(12, $+(,%c,%switch,)) $vsep(14,14) $+($pad($calc(3 * $right($2, -1)), >>).pre,,$color(normal text),$chr(32),$3-,)
            }
            else {
                var %message $ts $pad(12, $+(,%c,%switch,)) $vsep(14,14) $+(,$color(normal text),$2-,)
            }
            echo -i22 @zConsole %message
            if ($hget(zLog, logtodisk) == 1) {
                if ($fopen(zLog.disk) == $null) {
                    fopen zLog.disk $qt($scriptdirlog\zlog.log)
                    echo -s ferr: $ferr
                    if ($ferr == 0) {
                        fopen -n zLog.disk $qt($scriptdirlog\zlog.log)
                    }
                }
                fwrite -n zLog.disk %message
                .timerzLog.disk 1 $hget(zLog, logtodisk.timeout) fclose zLog.disk
            }
        }
    }
}

alias conf_zlog {
    dialog -m conf_zlog conf_zlog
}

on *:DIALOG:conf_zlog:*: {
    var %ini $scriptdiretc\zlog.ini
    if ($devent == init) {
        var %enabled $hget(zLog, enabled)
        if (%enabled == 0) {
            did -b $dname 2-14
        }
        else {
            did -c $dname 1
        }
        var %count 1
        var %total $hget(zLog.switches, 0).item
        while (%count <= %total) {
            did -a $dname 3 $hget(zLog.switches, %count).item
            inc %count
        }
        did -c $dname 3 1
        did -a $dname 4 $hget(zLog.switches, $did(3, $did(3).sel).text)
        did -b $dname 5
        var %enabled $hget(zLog, logtodisk)
        if (%enabled == 0) {
            did -b $dname 8-14
        }
        else {
            did -c $dname 7
        }
        did -a $dname 9 $hget(zLog, logtodisk.timeout)
        did -a $dname 11 zlog.log
        did -a $dname 13 $bytes($file($scriptdirlog\zlog.log).bytes).suf
    }
    elseif ($devent == $sclick) {
        if ($did == 1) {
            did $+(-,$iif($did(1).state == 1, e, b)) $dname 2-14
        }
        var %selected $did(3, $did(3).sel).text
        elseif ($did == 3) {
            did -ra $dname 4 $hget(zLog.switches, %selected)
        }
        elseif ($did == 5) {
            if ($hget(zLog.switches, %selected) != $did(4)) {
                if (($did(4) isnum) && ($did(4) < 16) && ($did(4) > -1)) {
                    hadd zLog.switches %selected $did(4)
                    writeini
                }
            }
        }
        elseif ($did == 7) {
            did $+(-,$iif($did(7).state == 1, e, b)) $dname 8-14
        }
        elseif ($did == 14) {
            var %ask $?!="Are you sure you want to delete the console log?"
            if (%ask == $true) {
                remove $qt($scriptdirlog\zlog.log)
            }
        }
        elseif ($did == 15) {
            writeini $qt(%ini) core enable $did(1).state
            writeini $qt(%ini) core logtodisk $did(7).state
            writeini $qt(%ini) core logtodisk.timeout $did(9).text
            .signal -n $nopath($script) init
        }
    }
}

dialog conf_zlog {
    title "zLog Config"
    size -1 -1 77 106
    option dbu
    check "Enable system log console", 1, 1 1 74 10
    box "Labels", 2, 1 12 75 30
    combo 3, 5 21 43 10, size drop
    edit "", 4, 48 21 24 10
    button "Apply", 5, 49 32 23 7
    box "Log to disk", 6, 1 42 75 50
    check "Enable", 7, 5 50 30 10
    text "fclose timeout", 8, 4 61 34 8
    edit "", 9, 40 59 18 10
    text "s.", 10, 59 61 6 8
    text "", 11, 4 73 45 8
    box "", 12, 2 68 73 4
    text "kB", 13, 51 73 20 8
    button "Clear", 14, 35 83 37 7
    button "Ok", 15, 1 93 37 12, default ok cancel
    button "Cancel", 16, 39 93 37 12, cancel
}
