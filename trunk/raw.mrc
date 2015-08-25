alias zRaw {
    if ($1 == process) {
        ;;RPL_ISUPPORT (005)
        if ($2 == 5) {
            var %tok $3-
            var %table $+(raw_,$network,_RPL_ISUPPORT)
            echo -s timeout: $hget(tmp, RPL_ISUPPORT_TIMEOUT)
            if (($hget(%table) != $null) && ($hget(tmp, RPL_ISUPPORT_TIMEOUT) == $null)) {
                hfree %table
                hmake %table 20
                zlog -raw Populating $+(%table,...)
            }
            hadd -mu5 tmp RPL_ISUPPORT_TIMEOUT 1
            var %count 1
            var %total $numtok(%tok, 32)
            while (%count <= %total) {
                var %current $gettok(%tok, %count, 32)
                if ($gettok(%tok, $+(%count,-), 32) != are supported by this server) {
                    zLog -raw >> %current
                    if ($numtok(%current, 61) == 2) {
                        var %item $gettok(%current, 1, 61)
                        var %data $gettok(%current, 2, 61)
                        hadd %table %item %data
                    }
                    else {
                        hadd %table %current 1
                    }
                    inc %count
                }
                else {
                    inc %count %total
                }
            }
        }
    }
    elseif ($1 == resolve) {
        if ($1 isnum) {
            return $hget(rawResolve_numeric, $2)
        }
        else {
            return $hget(rawResolve_name, $2)
        }
    }

}

raw *:*: {
    zRaw process $numeric $2-
}