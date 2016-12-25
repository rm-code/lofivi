files['.luacheckrc'].global = false
std = 'max+busted'

globals = {
    'love',
    'getVersion',
    'getTitle'
}

exclude_files = {
    './lua_install/*',
    './lib/*'
}

ignore = {
    '/self'
}
