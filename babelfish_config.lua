#!/usr/bin/lua

local config = {}

config.namespaces = {
    "Base Namespace",
}
config.database = {
    ["Base Namespace"] = {
        path = ".",
        exclusion = {
            "babelfish_config.lua",
        },
    },
}
-- this exclusion will be applied to all namespaces
config.exclusion = {
    "Locales/*",
    "Libs/*",
}

return config