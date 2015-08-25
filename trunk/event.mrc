on *:INPUT:#: {
    if ($ctrlenter == $false) {
        if ($left($1, 1) != /) {
            msg $active $1-
            halt
        }
    }
}

on *:INPUT:?: {
    if ($ctrlenter == $false) {
        if ($left($1, 1) != /) {
            msg $active $1-
            halt
        }
    }
}

on ^*:TEXT:*:*: {
    haltdef
    if ($target != $me) {
        echo $+(-i,$indent) $target $chantext(msg, $target, $nick, $1-)
        if (($target != $active) && ($me isin $1-)) {
            scid $activecid echo $+(-i,$indent) $active $ts $+(,$color(highlight text),H) $vsep(14, 14) $+(,$color(other text),$pad($calc($hget(zTheme, nick.indent) + 1), $nick).pre,!,$address) hilighted you in $chan @ $+($network,.)
        }
        if ($away == $true) {
            ;; will only send notice if enabled, see away.mrc same goes for the /msg below.
            .notice $nick $Away(-awaynotice, $nick)
        }
    }
    else {
        echo $+(-i,$indent) $nick $chantext(msg, $target, $nick, $1-)
        if ($away == $true) {
            msg $nick $away(-awaynotice, $nick)
        }
    }
}

on ^*:ACTION:*:*: {
    haltdef
    if ($target != $me) {
        echo $+(-i,$indent) $target $chantext(action, $target, $nick, $1-)
        if ($away == $true) {
            notice $nick $Away(-awaynotice, $nick)
        }
    }
    else {
        echo $+(-i,$indent) $nick $chantext(action, $target, $nick, $1-)
        if ($away == $true) {
            msg $nick $away(-awaynotice, $nick)
        }
    }
}

on ^*:JOIN:#: {
    haltdef
    if ($nick != $me) {
        if ($hget(zCore.IRC, ipType.detect) == 1) {
            var %iptype $+($chr(91),$ipType($gettok($address, 2, 64)),$chr(93))
        }
        var %line
        echo $+(-i,$indent) $target $ts $+(,$color(join text),>) $vsep(14, 14) $+($pad($calc($hget(zTheme, nick.indent) + 1), $nick).pre,!,$address) %iptype has joined $+($target,.)
    }
    else {
        if ($hget(zTheme, chanNameImage) == 1) {
            var %pic $+($scriptdiretc\img\chanNames\,$chan,.jpg)
            if ($file(%pic) == $null) {
                zLog -theme No chanNameImage found, generating...
                var %font = Arial, %size = 72
                zLog -theme +1 font: %font - size: %size
                var %w $width($chan, %font, %size)
                var %h $height($chan, %font, %size)
                window -dak0pfh @pic 0 0 $calc(%w + 5) %h
                zLog -theme +2 Drawing...
                drawrect -r @pic 0 0 0 0 %w %h
                drawtext -r @pic  $rgb(25, 25, 25) %font %size 0 0 $chan
                zLog -theme +2 Saving...
                drawsave -q100 @pic $qt(%pic)
                window -c @pic
            }
            zLog -theme Setting background for $chan to %pic
            background -p $chan $qt(%pic)
        }
    }
}

on ^*:PART:#: {
    haltdef
    if ($nick != $me) {
        if ($hget(zCore.IRC, ipType.detect) == 1) {
            var %iptype $+($chr(91),$ipType($gettok($address, 2, 64)),$chr(93))
        }
        var %line $ts $+(,$color(part text),<) $vsep(14, 14) $+($pad($calc($hget(zTheme, nick.indent) + 1), $nick).pre,!,$address) %iptype has parted
        var %reason $+($chr(40),$1-,$chr(41))
        echo $+(-i,$indent) $target %line $target %reason
    }
    else {
        echo $+(-i,$indent) $target $ts $+(,$color(part text),<) $vsep(14, 14) $pad($calc($hget(zTheme, nick.indent) + 2), You).pre have parted $target $+($chr(40),$1-,$chr(41))
    }
}

on ^*:QUIT: {
    haltdef
    if ($hget(zCore.IRC, ipType.detect) == 1) {
        var %iptype $+($chr(91),$ipType($gettok($address, 2, 64)),$chr(93))
    }
    var %line $ts $+(,$color(part text),<) $vsep(14, 14) $+($pad($calc($hget(zTheme, nick.indent) + 1), $nick).pre,!,$address) %iptype has quit $network
    var %reason $+($chr(40),$1-,$chr(41))
    var %count 1
    var %total $comchan($nick, 0)
    while (%count <= %total) {
        echo $+(-i,$indent) $comchan($nick, %count) %line %reason
        inc %count
    }
    if ($query($nick) != $null) {
        echo $+(-i,$indent) $nick %line %reason
    }
}

on ^*:RAWMODE:#: {
    haltdef
    echo $+(-i,$indent) $target $ts $+(,$color(mode text),M) $vsep(14,14) $pad($calc($hget(zTheme, nick.indent) + 2), $nick).pre sets mode $target $1-
}

on ^*:NICK: {
    haltdef
    var %line $ts $+(,$color(nick text),N) $vsep(14,14) $pad($calc($hget(zTheme, nick.indent) + 1), $nick).pre is now known as $newnick
    var %count 1
    var %total $comchan($newnick, 0)
    while (%count <= %total) {
        echo $+(-i,$indent) $comchan($newnick, %count) %line
        inc %count
    }
    if ($query($newnick) != $null) {
        echo $+(-i,$indent) $newnick %line
    }
}

on ^*:KICK:#: {
    haltdef
    if ($nick != $me) {
        var %nick.addr $+($pad($calc($hget(zTheme, nick.indent) + 1), $knick).pre,!,$address($knick, 5))
        echo $+(-i,$indent) $target $ts $+(,$color(kick text),K) $vsep(14,14) %nick.addr was kicked from $target by $nick $+($chr(40),$1-,$chr(41))
    }
}

on ^*:INVITE:#: {
    scid $activecid echo $+(-i,$indent) $active $ts $+(,$color(Invite text),I) $vsep(14,14)  $+(,$color(other text),$pad($calc($hget(zTheme, nick.indent) + 1), $nick).pre,!,$address) invited you to join $chan @ $+($network,.)
}

on *:CONNECT: {
    zLog -net Connected to %network / $server
    .timerscidresolve 1 5 zLog -net $!scidresolve(refresh)
    var %network $network
    if ($hget(%network) != $null) {
        hfree %network
    }
    hmake %network 20
}

on *:DISCONNECT: {
    .timerscidresolve 1 5 zLog -net $!scidresolve(refresh)
    zLog -net Disconnected from $network / $server
    hfree $network
}

on ^*:ERROR:*: {
    zLog -net Server error from $network / $+($server,:) $1-
    .timerscidresolve 1 5 zLog -net $!scidresolve(refresh)
    hfree $network
}

on *:SIGNAL:$($nopath($script)): {
    if ($1 == init) {
        var %ticks $ticks
        var %ctime $ctime
        var %ini $scriptdirdat\zscript.ini
        var %version_main $readini(%ini, core, version_main)
        var %version_suf $readini(%ini, core, version_suf)
        hadd -m tmp zSplash $readini(%ini, zSplash, enabled)
        if ($hget(tmp, zSplash) != 0) {
            if ($script(init.mrc) != $null) {
                .unload -rs init.mrc
                var %wswitches -k0ae
            }
            else {
                var %wswitches -k0ae
            }
            window %wswitches @zConsole
            echo @zConsole zScript %version_main %version_suf is starting up...
            .load -rs $qt($scriptdirinit.mrc)
            .signal -n zSplash start
            hadd zs version %version_main %version_suf
            hadd zs status_text Checking environment...
            .signal -n zSplash update
        }
        echo @zConsole Checking environment...
        echo @zConsole >> OS: Windows $os - Uptime: $uptime(system, 1)
        if ($read($scriptdirdat\os.txt, sn, $os) != 1) {
            echo @zConsole >> >> Your OS is older than Windows 2000. You may experience some compatibility issues.
        }
        echo @zConsole >> mIRC version: $version
        var %target_version_lo $readini($scriptdirdat\zscript.ini, core, target_mirc_version_lo)
        var %target_version_hi $readini($scriptdirdat\zscript.ini, core, target_mirc_version_hi)
        if ($version < %target_version_lo) {
            echo @zConsole >> >> Your version of mIRC is older than $+(%target_version,.)
            echo @zConsole >> >> >> Certain functionality may be broken.
            echo @zConsole >> >> >> It is encouraged to upgrade.
            echo @zConsole >> >> >> Please do not report any bugs.
        }
        elseif ($version > %target_version_hi) {
            echo @zConsole >> >> Your version of mIRC is newer than $+(%target_version,.)
            echo @zConsole >> >> >> This version is not fully supported.
            echo @zConsole >> >> >> You are free to report bugs so that we can keep suppporting newer mIRC versions.
        }
        echo @zConsole >> >> Please report any issues to
        echo @zConsole >> >> http://code.google.com/p/zowbscript/issues/list
        echo @zConsole >> >> Try to describe your issue as detailed as you can,
        echo @zConsole >> >> and make sure you paste all the info found above.
        echo @zConsole >> SSL-Ready: $sslready
        if ($hget(tmp, zSplash) != 0) {
            hadd zs status_text Loading core scripts...
            .signal -n zSplash update
        }
        echo @zConsole Loading core scripts...
        var %scriptdir $scriptdir
        var %files alias.mrc zlog.mrc time.mrc
        var %count 1
        var %total $numtok(%files, 32)
        while (%count <= %total) {
            dll $qt($scriptdirdll\whilefix.dll) WhileFix .
            var %current $gettok(%files, %count, 32))
            var %file $+(%scriptdir,%current)
            if ($file(%file) != 0) {
                if ($script(%current) != $null) {
                    .unload -rs %current
                }
                echo @zConsole >> %count - %current - $bytes($file(%file).size).suf - $lines(%file) lines.
                .load -rs $qt(%file)
                inc %count
                .signal -n %current init
            }
            else {
                echo @zConsole 04Can't find $+($qt(%file),!) Please make sure it is placed in $+($qt(%scriptdir),!)
                echo @zConsole 04Cowardly refusing to continue after failing to load a core script.
                halt
            }
        }
        zLog -init Successfully loaded core scripts.
        if ($hget(tmp, zSplash) != 0) {
            hadd zs status_text Initializing core configuration...
            .signal -n zSplash update
        }
        zLog -init Initializing core configuration...
        zLog -init $init(core)
        if ($hget(tmp, zSplash) != 0) {
            hadd zs status_text Loading other scripts...
            .signal -n zSplash update
        }
        zLog -init Loading other scripts...
        zLog -load $init(scripts)
        if ($hget(tmp, zSplash) != 0) {
            hadd zs status_text Loading plugins...
            .signal -n zSplash update
        }
        zLog -init Loading plugins...
        var %plugin.total $findfile($scriptdirplugins\, *.mrc, 0, 1)
        if (%plugin.total > 0) {
            var %plugin.ticks $ticks
            zLog -init +2 Found %plugin.total plugins...
            noop $findfile($scriptdirplugins\, *.mrc, 0, 1, $zPlugin(init, $1-))
            zLog -init +2 Initialized %plugin.total plugins in $+($dur(%plugin.ticks).suf,.)
        }
        else {
            zLog -init No plugins detected.
        }
        zLog -init Initialization completed in $+($dur(%ticks).suf,.)
        if ($hget(tmp, zSplash) != 0) {
            .signal -n zSplash end
        }
        hdel tmp zSplash
    }
}

on *:START: {
    .signal -n $nopath($script) init
}