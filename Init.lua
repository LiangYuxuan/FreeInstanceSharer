local addon, Engine = ...
local FIS = LibStub('AceAddon-3.0'):NewAddon(addon, 'AceEvent-3.0', 'AceTimer-3.0', 'AceBucket-3.0')

local L = {}
-- Make missing translations available
setmetatable(L, {
    __index = function(self, key)
        self[key] = (key or "")
        return key
    end
})

Engine[1] = FIS
Engine[2] = L
_G[addon] = Engine

FIS.addonPrefix = "\124cFF70B8FF" .. addon .. "\124r:"
FIS.playerFullName = UnitName('player') .. '-' .. GetRealmName()

function FIS:debug(...)
    if self.db.debug then
        print(self.addonPrefix, format(...))
    end
end
