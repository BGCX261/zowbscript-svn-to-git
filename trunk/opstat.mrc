alias opstat {
    var %chan $iif($isid == $true, $1, $active)
    if ($hget(opstat) != $null) {
        hfree opstat
    }
    hmake opstat 10
    var %count 1
    var %total $nick(%chan, 0)
    while (%count <= %total) {
        hinc opstat $modenum($left($nick(%chan, %count).pnick, 1)).chr2num
        inc %count
    }
    var %count 1
    var %total $hget(opstat, 0).item
    while (%count <= %total) {
        var %current $hget(opstat, %count).item
        var %round $calc($len($nick(%chan, 0)) - 2)
        var %perc $+($chr(91),$perc($hget(opstat, %current), $nick(%chan, 0), $iif(%round < 1, 0, %round)).suf,$chr(93),$chr(44))
        var %out. [ $+ [ %current ] ] $hget(opstat, %current) $modenum(%current).num2name %perc
        inc %count
    }
    var %result $+($left(%out.6 %out.5 %out.4 %out.3 %out.2 %out.1, -1),.)
    if ($isid == $true) {
        return %result
    }
    else {
        echo $+(-ai,$indent) $ts $+(,$color(info text),i) $vsep(14, 14) %result
    }
}

alias modenum {
    if ($prop == chr2num) {
        if ($1 isalpha) {
            return 1
        }
        else {
            return $replace($1, ~, 6, &, 5, !, 5, @, 4, $(%), 3, +, 2)
        }
    }
    elseif ($prop == name2chr) {
        return $replace($1, owner, ~, superop2, !, superop, &, halfop, $(%), op, @, voice, +)
    }
    elseif ($prop == num2name) {
        return $replace($1, 1, regular(s), 2, voiced, 3, halfop(s), 4, op(s), 5, superop(s), 6, (co-)owner(s))
    }
}