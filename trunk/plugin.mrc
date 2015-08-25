on *:SIGNAL:$($nopath($script)): {
    if ($hget(tmp, zSplash) != 0) {
        hadd zs status_text Initializing $+($nopath($script),...)
        .signal -n zSplash update
    }
    if ($1 == init) {
        var %ini $scriptdiretc\plugin.ini
        if ($file(%ini) == $null) {
            var %ticks $ticks
            zLog -conf $init(conf, gen, %ini, core, enabled=1)
            zLog -conf +2 Defaults for $script generated in $+($dur(%ticks).suf,.)
            noop $sleep(500)
            .signal -n $nopath($script) init
        }
        else {
            var %ticks $ticks
            zLog -init +2 Initializing settings for $+($script,.)
            var %ini $scriptdiretc\away.ini
            zLog -init +3 $init(conf, load, %ini, core, zPlugin, 5)
            zLog -init +2 Initialization for $script completed in $+($dur(%ticks).suf,.)
        }
    }
}


alias zPlugin {
    var %ini $scriptdiretc\plugin.ini
    if ($1 == init) {
        var %plugin $nopath($2-)        
        if ($readini(%ini, %plugin, enabled) != 1) {
            if ($hget(tmp, zSplash) != 0) {
                hadd zs status_text Initializing plugin $+(%plugin,.)
            }
            var %table $+(zPlugin_,%plugin)
            if ($hget(%table) != $null) {
                hfree %table
            }
            hmake %table 5
            hload -i %table $qt(%ini) %plugin
            zLog -plugin +3 $pad(30, %plugin) $vsep(14,14) $pad(7, $bytes($file($2-).size).suf) $vsep(14,14) $lines($2-) lines.
            .load -rs $qt($2-)
        }
        else {
            zLog -init Plugin %plugin disabled, not loading.
        }
    }
}