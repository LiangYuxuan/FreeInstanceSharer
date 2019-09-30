local addon, Engine = ...
local F = LibStub('AceAddon-3.0'):NewAddon(addon, 'AceEvent-3.0', 'AceTimer-3.0')

-- Lua functions
local _G = _G
local format = format

-- WoW API / Variables

local L = {}
-- Make missing translations available
setmetatable(L, {
    __index = function(self, key)
        self[key] = (key or "")
        return key
    end
})

Engine[1] = F
Engine[2] = L
_G[addon] = Engine

F.addonPrefix = "\124cFF70B8FF" .. addon .. "\124r: "
F.playerFullName = UnitName('player') .. '-' .. GetRealmName()

function F:Print(...)
    _G.DEFAULT_CHAT_FRAME:AddMessage(self.addonPrefix .. format(...))
end

function F:Debug(...)
    if self.db.Debug then
        self:Print(...)
    end
end
