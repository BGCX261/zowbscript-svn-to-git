;; whitespace padding
alias pad {
    return $iif($prop == pre,$+($str($chr(160),$calc($1 - $len($2-))),$2-),$+($2-,$str($chr(160),$calc($1 - $len($2-)))))
}

;; vertical seperator
alias vsep {
    return $+(, $1, $chr(44), $2) 
}

;; horizontal seperator
alias hsep {
    return $+(, $1, $chr(44), $2, $str($iif($3 == $null, -, $3), 80),)
}

;; ticks duration
alias dur {
    return $+($calc(($ticks - $1) / 1000),$iif($prop == suf, s))
}

;; check for valid mode character
alias modechr {
    if ($istok(~.&.!.@.%.+, $1, 46) == $false) {
        return $chr(160)
    }
    else {
        return $1
    }
}

alias modecomp {
    if ($modechr($1) == $1) {
        return $replace($1, ~, 6, !, 5, &, 5, @, 4, $(%), 3, +, 2)
    }
    else {
        return 1
    }
}

;; to indent channel/query texts, so that it wraps nicer.
alias indent {
    return $calc($len($ts) + $hget(zTheme, nick.indent) + 1)
}

;; themed /msg
alias msg {
    .!msg $1-
    echo $+(-i,$indent) $1 $chantext(msg, $1, $me, $2-)
}

alias say {
    msg $active $1-
}

;; themed /describe
alias describe {
    .!describe $1-
    echo $+(-i,$indent) $1 $chantext(action, $1, $me, $2-)
}

alias me {
    describe $active $1-
}

;; returns percentage from low/high value. use .suf prop for % sign.
;; $3 for rounding
alias perc {
    return $+($round($calc(($1 / $2) * 100),$iif($3 == $null, 0, $3)),$iif($prop == suf, $(%)))
}

alias core {
    if ($1 == init) {
        .load -rs $scriptdirevent.mrc
    }
}

alias whilefix {
    dll $qt($scriptdirdll\whilefix.dll) WhileFix .
}

alias sleep {
    var %count 1
    var %total $1
    while (%count <= %total) {
        whilefix
        inc %count
    }
    return slept for $dur($calc($ticks - %ticks)) seconds.
}

;; dialog related

alias dCheck {
    return $iif($1 == 1, -c, -u)
}

alias dPopulateCombo {
    var %dName = $1, %dID = $2
    if ($prop == tUnits) {
        var %items seconds minutes hours
    }
    else {
        var %items $3-
    }
    var %c 1
    var %t $numtok(%items, 32)
    while (%c <= %t) {
        did -a %dName %dID $gettok(%items, %c, 32)
        inc %c
    }
}

alias zDump {
    window -a @zDump
    if (info isin $1-) {
        var %ini $scriptdirdat\zscript.ini
        echo @zDump mIRC version: $version
        echo @zDump target version: $readini(%ini, core, target_mirc_version)
        echo @zDump $!mircexe signature: $file($mircexe).sig
        echo @zDump zOWBscript version: $readini(%ini, core, version_main) $hget(%ini, core, version_suf)
        echo @zDump $hsep(14, $colour(background))
    }
    if (script isin $1-) {
        var %c 1
        var %t $script(0)
        echo @zDump %t scripts loaded:
        while (%c <= %t) {
            echo @zDump >> $pad(4, $+(%c,.)).pre $pad(60, $script(%c)) $pad(6, $lines($script(%c))).pre $pad(8, $bytes($file($script(%c)).size).suf).pre
            inc %c
        }
        echo @zDump $hsep(14, $colour(background))
    }
    if (hash isin $1-) {
        var %c 1
        var %t $hget(0)
        echo @zDump %t hashtables loaded:
        while (%c <= %t) {
            var %current $hget(%c)
            var %c1 1
            var %t1 $hget(%current, 0).item
            echo @zDump >> $pad(4, $+(%c,.)).pre %current - %t items
            while (%c1 <= %t1) {
                echo @zDump >> >> $pad(4, $+(%c1,.)).pre $pad(30, $hget(%current, %c1).item) $hget(%current, %c1).data
                inc %c1
            }
            inc %c
        }
        echo @zDump $hsep(14, $colour(background))
    }
}

alias zInit {
    .load -rs $qt($scriptdirevent.mrc)
}