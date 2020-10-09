local addon, Engine = ...
local F = LibStub('AceAddon-3.0'):NewAddon(addon, 'AceEvent-3.0', 'AceTimer-3.0', 'AceBucket-3.0')

-- Lua functions
local _G = _G
local date, format, tinsert = date, format, tinsert

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
F.playerGUID = UnitGUID('player')

function F:Print(...)
    _G.DEFAULT_CHAT_FRAME:AddMessage(self.addonPrefix .. format(...))
end

function F:Log(...)
    if not self.db.DebugLog[self.currSession] then
        self.db.DebugLog[self.currSession] = {}
    end

    tinsert(
        self.db.DebugLog[self.currSession],
        date("%Y-%m-%d %H:%M:%S%z") .. " - Status: " .. self.status .. " - " .. format(...)
    )
end

function F:Debug(...)
    if self.db.Debug then
        self:Log(...)
        self:Print(...)
    end
end
