on *:SIGNAL:$($nopath($script)): {
    if ($hget(tmp, zSplash) != 0) {
        hadd zs status_text Initializing $+($nopath($script),...)
        .signal -n zSplash update
    }
    if ($1 == init) {
        var %ini $scriptdiretc\time.ini
        if ($file(%ini) == $null) {
            var %ticks $ticks
            echo @zConsole >> >> $init(conf, gen, %ini, core, time.format=HH:nn:ss date.format=dd/mm/yyyy timestamp.format=HH:nn:ss)
            echo @zConsole >> Defaults for $script generated in $+($dur(%ticks).suf,.)
            noop $sleep(500)
            .signal -n $nopath($script) init
        }
        else {
            var %ticks.total $ticks
            echo @zConsole >> >>  Initializing settings for $+($script,.)
            var %ini $scriptdiretc\time.ini
            echo @zConsole >> >> >> $init(conf, load, %ini, core, zTime, 5)
            echo @zConsole >> >> Initialization for $script completed in $+($dur(%ticks.total).suf,.)
        }
        return
    }
}

alias conf_time {
    dialog -m conf_time conf_time
}

;; timestamp
alias ts {
    return 01,14 $asctime($ctime, $hget(zTime, timestamp.format)) 
}

on *:DIALOG:conf_time:*:*: {
    if ($devent == init) {
        did -a $dname 2 $hget(zTime, time.format)
        did -a $dname 4 $hget(zTime, date.format)
        did -a $dname 6 $hget(zTime, timestamp.format)
    }
    elseif ($devent == sclick) {
        if ($did == 9) {
            help $!asctime
        }
        elseif ($did == 10) {
            ;; to-do: add stricter checking if format is according $asctime specifications.
            var %ini $scriptdiretc\time.ini
            writeini $qt(%ini) core time.format $did(2).text
            writeini $qt(%ini) core date.format $did(4).text
            writeini $qt(%ini) core timestamp.format $did(6).text
            signal -n $nopath($script) init
        }
    }
}

dialog conf_time {
    title "zOWBscript Time/Date config"
    size -1 -1 116 102
    option dbu
    box "Time format", 1, 1 1 114 22
    edit "", 2, 5 9 105 10
    box "Date format", 3, 1 23 114 22
    edit "", 4, 5 32 105 10
    box "Timestamp format", 5, 1 46 114 22
    edit "", 6, 5 55 105 10
    box "", 7, 1 66 114 22
    text "These settings accept the $asctime format. Click 'help' below for more information.", 8, 4 72 108 13
    button "Help", 9, 1 89 37 12
    button "Ok", 10, 39 89 37 12, default
    button "Cancel", 11, 77 89 37 12, cancel
}