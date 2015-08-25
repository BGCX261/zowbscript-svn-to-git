alias init {
    if ($1 == scripts) {
        var %ticks $ticks
        var %bytes
        var %lines
        var %count 1
        var %bytes.noload
        var %lines.noload
        var %count.noload
        var %scriptdir $scriptdir
        var %total $findfile(%scriptdir, *.mrc, 0, 0)
        while (%count <= %total) {
            whilefix
            var %current $findfile(%scriptdir, *.mrc, %count, 0)
            if ($regex($nopath(%current), /^(event|alias|init|zlog|time).mrc$/) == 0) {
                if ($script($nopath(%current)) != $null) {
                    .unload -rs $qt($nopath(%current))
                }
                .load -rs $qt(%current)
                zLog -load +0 $pad(3, %count).pre $pad(30, $nopath(%current)) $vsep(14,14) $pad(7, $bytes($file(%current).size).suf) $vsep(14,14) $lines(%current) lines.
                .signal -n $nopath(%current) init
            }
            else {
                zLog -load >> $pad(3, %count).pre $pad(30, $nopath(%current) (not reloaded)) $vsep(14,14) $pad(7, $bytes($file(%current).size).suf) $vsep(14,14) $lines(%current) lines.
                inc %bytes.noload $file(%current).size
                inc %lines.noload $lines(%current)
                inc %count.noload
            }
            inc %bytes $file(%current).size
            inc %lines $lines(%current)
            inc %count
        }
        var %total.count $+($calc(%count - 1),$chr(40),-,%count.noload,$chr(41))
        var %total.bytes $+($bytes(%bytes).suf,$chr(40),-,$bytes(%bytes.noload).suf,$chr(41))
        var %total.lines $+(%lines,$chr(40),-,%lines.noload,$chr(41))

        return Loaded/initialized %total.count scripts with %total.bytes lines and %total.bytes bytes in $+($dur(%ticks).suf,.)
    }
    elseif ($1 == conf) {
        var %ticks $ticks
        var %log.method $iif($script(zlog.mrc) != $null, zLog, echo @zConsole .)
        if ($finddir($scriptdir, etc, 1, 1) == $null) {
            mkdir $scriptdiretc
        }
        if ($2 == load) {
            var %ini $3
            var %section $4
            var %table $5
            var %size $6
            if ($hget(%table) != $null) {
                hfree %table
            }
            hmake %table %size
            hload -i %table $qt(%ini) %section
            return Loaded $ini(%ini, %section, 0) items into hashtable %table in $+($dur(%ticks).suf,.)
        }
        elseif ($2 == gen) {
            %log.method -warning +2 No config file found -- Generating defaults.
            var %ini $3
            var %section $4
            var %items $5-
            var %count 1
            var %total $numtok(%items, 32)
            echo -s %count / %total
            %log.method -conf +3 $+($chr(91),%section,$chr(93))
            while (%count <= %total) {
                whilefix
                var %current $gettok(%items, %count, 32)
                %log.method -conf +3 %current
                var %item $gettok(%current, 1, 61)
                var %data $gettok(%current, 2, 61)
                writeini $qt(%ini) %section %item %data
                inc %count
            }
            flushini $qt(%ini)
            return Generated $+($chr(91),%section,$chr(93)) for $nopath(%ini) in $+($dur(%ticks).suf,.)
        }
    }
    elseif ($1 == core) {
        var %ticks.total $ticks
        var %ini $scriptdiretc\zscript.ini
        if ($hget(zCore*, 0) != $null) {
            hfree zCore*
        }
        zLog -init +1 %ini
        var %count 1
        var %total $ini(%ini, 0)
        while (%count <= %total) {
            whilefix
            var %ticks $ticks
            var %current $ini(%ini, %count)
            zLog -init +2 $+($chr(91),%current,$chr(93))
            var %sub.count 1
            var %sub.total $ini(%ini, %current, 0)
            while (%sub.count <= %sub.total) {
                whilefix
                var %item $ini(%ini, %current, %sub.count)
                var %data $readini(%ini, %current, %item)
                zLog -init +2 $+(%item,=,%data)
                hadd -m $+(zCore,$iif(%current != core, $+(.,%current))) %item %data
                inc %sub.count
            }
            zLog -init +1 Loaded settings for $nopath(%ini) $+($chr(91),%current,$chr(93)) in $+($dur(%ticks).suf,.)
            inc %count
        }
    }
}


;; --- zSplash ---

on *:SIGNAL:zSplash: {
    if ($1 == start) {
        if ($hget(zs) != $null) {
            hfree zs
        }
        hmake zs 10
        hadd zs w 440
        hadd zs h 220
        var %x $calc(($window(-1).w / 2) - ($hget(zs, w) / 2))
        var %y $calc(($window(-1).h / 2) - ($hget(zs, h) / 2))
        window -dak0pfoB +d @zSplash %x %y $hget(zs, w) $hget(zs, h)
        hadd zs c 0
        hadd zs status_text Starting up...
        hadd zs version .
        zSplash_run
    }
    elseif ($1 == end) {
        window -c @zSplash
        hfree zs
    }
    elseif ($1 == update) {
        zSplash_run
    }
}

alias zSplash_run {
    var %ticks $ticks
    if ($window(@zSplash) != $null) {
        hinc zs c 4
        drawrect -nrf @zSplash 657930 0 0 0 $hget(zs, w) $hget(zs, h)
        ;;-- start of routine
        ;;-- dotcircle --
        var %c 1
        var %dist $calc(($sin($hget(zs, c)).deg * 16) + 64)
        while (%c <= 16) {
            var %x $calc(($cos($calc($hget(zs, c) + (%c * 22.5))).deg * %dist) + ($hget(zs, w) / 2))
            var %y $calc(($sin($calc($hget(zs, c) + (%c * 22.5))).deg * %dist) + ($hget(zs, h) / 2))
            var %col $iif(2 // %c, 13120050, 6553600)
            drawdot -nr @zSplash %col 8 %x %y
            inc %c
        }
        ;;-- title text --
        var %text zOWBscript
        var %x $calc(($hget(zs, w) / 2) - ($width(%text, fixedsys, 48) / 2))
        var %y $calc(($hget(zs, h) / 3) - ($height(%text, fixedsys, 48) / 2))
        drawtext -nr @zSplash 0 fixedsys 48 $calc(%x + 2) $calc(%y + 2) %text
        drawtext -nr @zSplash 16777215 fixedsys 48 %x %y %text
        ;;-- status text --
        var %text $hget(zs, status_text)
        var %font Lucida Console
        var %fsize 16
        var %x $calc(($hget(zs, w) / 2) - ($width(%text, %font, %fsize) / 2))
        var %y $calc(($hget(zs, h) / 1.4) - ($height(%text, %font, %fsize) / 2))
        drawtext -nro @zSplash 0 $qt(%font) %fsize $calc(%x + 2) $calc(%y + 2) %text
        drawtext -nro @zSplash 16777215 $qt(%font) %fsize %x %y %text
        ;;-- version info
        drawtext -nr @zSplash 3289650 fixedsys 12 0 $calc($hget(zs, h) - 16) $hget(zs, version)
        ;;--- end of routine
        drawdot @zSplash
        .timerzSplash -h 1 $calc(20 - ($ticks - %ticks)) zSplash_run
    }
}