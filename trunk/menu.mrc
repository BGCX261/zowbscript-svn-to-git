menu channel,status,query {
    zOWBscript
    .Away system
    ..Set away...: {
        away $?="Reason?"
    }
    .Configuration
    ..Console logger: {
        conf_zlog
    }
    ..Networks: {
        conf_net
    }
    ..Themes: {
        conf_theme
    }
    ..Time and Date: {
        conf_time
    }
}