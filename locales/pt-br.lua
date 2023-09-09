local Translations = {
    error = {
        var = 'texto vai aqui',
    },
    success = {
        var = 'texto vai aqui',
    },
    primary = {
        var = 'texto vai aqui',
    },
    menu = {
        var = 'texto vai aqui',
    },
    commands = {
        var = 'texto vai aqui',
    },
    progressbar = {
        var = 'texto vai aqui',
    },
}

if GetConvar('rsg_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
-- Lang:t('error.no_item')
