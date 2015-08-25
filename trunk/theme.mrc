on *:SIGNAL:$($nopath($script)): {
    if ($hget(tmp, zSplash) != 0) {
        hadd zs status_text Initializing $+($nopath($script),...)
        .signal -n zSplash update
    }
    if ($1 == init) {
        var %ini $scriptdiretc\theme.ini
        if ($file(%ini) == $null) {
            var %ticks $ticks
            zLog -conf +2 $init(conf, gen, %ini, core, nick.indent=15 active.theme=default, chanNameImage=1)
            zLog -conf +2 Defaults for $script generated in $+($dur(%ticks).suf,.)
            noop $sleep(500)
            .signal -n $nopath($script) init
        }
        else {
            var %ticks.total $ticks
            zLog -init +2 Initializing settings for $+($script,.)
            var %ini $scriptdiretc\theme.ini
            zLog -init +3 $init(conf, load, %ini, core, zTheme, 5)
            if ($2 != --nothemereload) {
                zLog -init +2 Starting zTheme...
                zlog -init +3 $load_theme
            }
            zLog -init +2 Initialization for $script completed in $+($dur(%ticks.total).suf,.)
        }
    }
}

alias load_theme {
    var %ticks $ticks
    if ($hget(zTheme, random.theme) == 1) {
        var %total.themes $findfile($scriptdirdat\themes\, *.ini, 0)
        var %theme $findfile($scriptdirdat\themes\, *.ini, $rand(1, %total.themes))
    }
    else {
        var %theme $hget(zTheme, active.theme)
    }
    var %ini $+($scriptdirdat\themes\,%theme,.ini)
    zLog -theme +2 Active theme: $+(",%theme,") by $readini(%ini, info, author) $+($chr(91),$readini(%ini, info, version),$(|),$readini(%ini, info, year),$(|),$bytes($file(%ini).size).suf,$chr(93))
    if ($ini(%ini, palette) != $null) {
        zLog -theme +3 Ajusting palette...
        var %count 1
        var %total $ini(%ini, palette, 0)
        while (%count <= %total) {
            whilefix
            var %item $ini(%ini, palette, %count)
            var %data $readini(%ini, palette, %item)
            zLog -theme +4 $pad(15, %item) $vsep(14, 14) %data
            color %item %data
            inc %count
        }
    }
    else {
        zLog -theme +3 No palette data found.
    }
    if ($ini(%ini, colours) != $null) {
        zLog -theme +3 Setting colours...
        var %count 1
        var %total $ini(%ini, colours, 0)
        while (%count <= %total) {
            whilefix
            var %item $ini(%ini, colours, %count)
            ;; Dark rain?
            var %data $readini(%ini, colours, %item)
            zLog -theme +4 $pad(15, %item) $vsep(14, 14) %data
            color $replace(%item, _, $chr(32)) %data
            inc %count
        }
    }
    else {
        zLog -theme +3 No colour data found.
    }
    if ($ini(%ini, nicklist) != $null) {
        if ($readini($scriptdiretc\theme.ini, core, nicklist.colours) == 1) {
            zLog -theme +3 Setting nicklist colours...
            if ($cnick(0) > 0) {
                zLog -theme +4 Clearing nicklist colour settings...
                var %count $cnick(0)
                while (%count > 0) {
                    whilefix
                    .cnick -r %count
                    dec %count
                }
            }
            var %count 1
            var %total $ini(%ini, nicklist, 0)
            while (%count <= %total) {
                whilefix
                var %item $ini(%ini, nicklist, %count)
                var %data $readini(%ini, nicklist, %item)
                var %item $modenum(%item).name2chr
                var %line $iif($left(%item,2) == i_, -l30) * %data $remove(%item, i_)
                zLog -theme +4 .cnick %line
                .cnick %line
                inc %count
            }
            if ($readini(%ini, nicklist, i_regular) != $null) {
                zLog -theme +4 .cnick -nl30 * $readini(%ini, nicklist, i_regular)
                .cnick -nl30 * $readini(%ini, nicklist, i_regular)
            }
            if ($readini(%ini, nicklist, regular) != $null) {
                zLog -theme +4 .cnick -n * $readini(%ini, nicklist, regular)
                .cnick -n * $readini(%ini, nicklist, regular)
            }
        }
        else {
            zLog -theme +3 Nicklist colours disabled.
        }
    }
    else {
        zLog -theme +3 No nicklist colour data found.
    }
    return Theme loaded in $dur(%ticks).suf
}

;; returns string to be echo'd locally in channels/queries
alias chantext {
    var %modechar $iif($1 == msg, $modechr($left($nick($2, $3).pnick, 1)), *)
    var %modecolour $cnick(%modechar, M).color
    if ($me !isin $4-) {
        var %textcolour $color($iif($2 == $me, own text, normal text))
    }
    else {
        var %textcolour $color(Highlight text)
    }
    var %textcolour $iif($len(%textcolour) == 1, $+(0,%textcolour), %textcolour)
    var %nick $iif($1 == action, $pad($calc($hget(zTheme, nick.indent) + 2), $3).pre, $pad($hget(zTheme, nick.indent), $3))
    return $ts $+(,%modecolour,%modechar,) $vsep(14, 14) %nick $iif($1 == msg, >) $+(,%textcolour,$4-,)
}

;; dump current mIRC palette to theme-usable format.
alias dumppalette {
    var %c 0
    var %t 15
    while (%c <= %t) {
        echo -s $+(%c,=,$color(%c))
        inc %c
    }
}

;; theme dialog stuff

alias conf_theme {
    dialog -mo theme_config theme_config
}

alias theme_selector {
    var %dname theme_selector
    if ($1 == list) {
        noop $findfile($scriptdirdat\themes\, *.ini, 0, 1, did -a %dname 2 $gettok($nopath($1-), 1, 46))
    }
    elseif ($1 == info) {
        if ($2 == active) {
            var %author.id   7
            var %version.id  9
            var %year.id    11
            var %size.id    13
            var %ini $+($scriptdirdat\themes\,$hget(zTheme, active.theme),.ini)

        }
        elseif ($2 == selected) {
            var %author.id  16
            var %version.id 18
            var %year.id    20
            var %size.id    22
            var %ini $+($scriptdirdat\themes\,$did(%dname, 2, $did(%dname, 2).sel),.ini)
        }
        did -a %dname %author.id    $readini(%ini, info, author)
        did -a %dname %version.id   $readini(%ini, info, version)
        did -a %dname %year.id      $readini(%ini, info, year)
        did -a %dname %size.id      $bytes($file(%ini).size).suf
    }
}

on *:DIALOG:theme_*:*:*: {
    if ($dname == theme_config) {
        if ($devent == init) {
            did -ra $dname 2 $hget(zTheme, active.theme)
            did -ra $dname 6 $hget(zTheme, nick.indent)
            did $+(-,$iif($hget(zTheme, random.theme) == 1, c, u)) $dname 9
            var %idle.time 10 20 30 40 50 60
            didtok $dname 14 32 %idle.time
            if ($hget(zTheme, nicklist.idle) == 1) {
                did -c $dname 11
                if ($hget(zTheme, nicklist.idle.colour) == 1) {
                    did -c $dname 12
                }
                else {
                    did -b 13-14
                }
            }
            else {
                did -b $dname 12-14
            }
        }
        elseif ($devent == sclick) {
            if ($did == 3) {
                did -b $dname 1-9
                dialog -mo theme_selector theme_selector
            }
            elseif ($did == 7) {
                var %ini $scriptdiretc\theme.ini
                echo -s dID 6 == $did($dname, 6).text
                if ($did($dname, 6).text !isnum) {
                    var %q $?!="Nickname indentation setting may only be a number. Saving your modifications may cause undesired operation. Do you wish to save this value anyway?"
                    if (%q == $true) {
                        writeini -n $qt(%ini) core nick.indent $did($dname, 6)
                    }
                }
                else {
                    writeini -n $qt(%ini) core nick.indent $did($dname, 6)
                }
                writeini -n $qt(%ini) core random.theme $did($dname, 9).state
                .signal -n $nopath($script) init --nothemereload
                dialog -x theme_config
            }
        }
    }
    elseif ($dname == theme_selector) {
        if ($devent == init) {
            noop $theme_selector(list)
            noop $theme_selector(info, active)
        }
        elseif ($devent == sclick) {
            if ($did == 2) {
                noop $theme_selector(info, selected)
            }
            elseif ($did == 3) {
                var %theme.new $did($dname, 2, $did($dname, 2).sel).text
                zLog -init +1 Changing theme...
                zLog -init +2 $hget(zTheme, active.theme) -> %theme.new
                hadd zTheme active.theme %theme.new
                did -b $dname 1-23
                zLog -init +3 $load_theme
                noop $theme_selector(active)
                did -e $dname 1-23
            }
            elseif ($did == 4) {
                run $qt($+($scriptdirdat\themes\,$did($dname, 2, $did($dname, 2).sel),.ini))
            }
        }
        elseif ($devent == close) {
            did -e theme_config 1-9
        }
    }
}

dialog theme_config {
      title     "Theme config"
      size      -1 -1 154 57
      option dbu
      ;;type    text                            id  x   y   w   h   options
      box       "Theme",                        1,  1   1   75  28
      text      ":themename:",                  2,  6   9   66  8
      button    "Change...",                    3,  36  18  37  8
      box       "Misc",                         4,  1   29  75  28
      text      "Nick indentation",             5,  5   37  39  8
      edit      "",                             6,  55  35  18  10
      button    "Ok",                           7,  78  44  37  12, default
      button    "Cancel",                       8,  116 44  37  12, cancel
      check     "Random theme on start",        9,  5   46  68  10
      box       "Nicklist",                     10, 77  1   76  42
      check     "Enable nicklist colouring",    11, 81  9   69  10
      check     "Different 'idle' colour",      12, 81  19  68  10
      text      "Idle time:",                   13, 90  31  25  8
      combo                                     14, 116 30  35  12, size drop
}


dialog theme_selector {
    title   "Theme selector"
    size    -1 -1 159 106
    option dbu
    ;;type  text                id  x   y   w   h
    box     "Available themes", 1,  0   0   79  106
    list                        2,  2   7   75  84, size
    button  "Load",             3,  2   92  37  12
    button  "Edit...",          4,  40  92  37  12
    box     "Active theme",     5,  80  0   79  47
    text    "Author",           6,  85  9   25  8
    text    "",                 7,  113 9   44  8
    text    "Version",          8,  85  18  25  8
    text    "",                 9,  113 18  44  8
    text    "Year",             10, 85  27  25  8
    text    "",                 11, 113 27  44  8
    text    "Size",             12, 85  36  25  8
    text    "",                 13, 113 36  44  8
    box     "Selected theme",   14, 80  47  79  46
    text    "Author",           15, 84  56  25  8
    text    "",                 16, 112 56  44  8
    text    "Version",          17, 84  65  25  8
    text    "",                 18, 112 65  44  8
    text    "Year",             19, 84  74  25  8
    text    "",                 20, 112 74  44  8
    text    "Size",             21, 84  83  25  8
    text    "",                 22, 112 83  44  8, cancel
    button  "Close",            23, 122 94  37  12
}