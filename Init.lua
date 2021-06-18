local addon, Engine = ...
local F = LibStub('AceAddon-3.0'):NewAddon(addon, 'AceEvent-3.0', 'AceTimer-3.0', 'AceBucket-3.0')

-- Lua functions
local _G = _G
local date, format, tinsert = date, format, tinsert

-- WoW API / Variables

local L = {}
setmetatable(L, {
    -- Make missing translations available
    __index = function(self, key)
        self[key] = (key or "")
        return key
    end
})
F.DF = { profile = {}, global = {} }
F.Options = { name = L["Free Instance Sharer"], type = 'group', args = {} }

Engine[1] = F
Engine[2] = L
Engine[3] = F.DF.profile
Engine[4] = F.DF.global
_G[addon] = Engine

F.addonPrefix = "\124cFF70B8FF" .. addon .. "\124r: "
F.playerFullName = UnitName('player') .. '-' .. GetRealmName()
F.playerGUID = UnitGUID('player')

function F:OnEnable()
    self.data = LibStub('AceDB-3.0'):New('FreeInstanceSharerDB', self.DF, true)

    -- Depreciated: Will be removed in next tier
    if FISConfig then
        -- old database
        if FISConfig.DBVer and FISConfig.DBVer == 2 then
            -- last version
            self.data:SetProfile(self.playerFullName)
            for key in pairs(self.DF.profile) do
                if type(FISConfig[key]) ~= 'nil' then
                    self.data.profile[key] = FISConfig[key]
                end
            end
        end
        FISConfig = nil
    end

    self.data.RegisterCallback(self, 'OnProfileChanged', 'Initialize')
    self.data.RegisterCallback(self, 'OnProfileCopied', 'Initialize')
    self.data.RegisterCallback(self, 'OnProfileReset', 'Initialize')

    self.db = self.data.profile
    self.global = self.data.global

    self.global.DebugLog[1] = self.global.DebugLog[2]
    self.global.DebugLog[2] = self.global.DebugLog[3]
    self.global.DebugLog[3] = {}

    self:Initialize()
end

function F:Print(...)
    _G.DEFAULT_CHAT_FRAME:AddMessage(self.addonPrefix .. format(...))
end

function F:Log(...)
    tinsert(
        self.global.DebugLog[3],
        date("%Y-%m-%d %H:%M:%S%z") .. " - Status: " .. self.status .. " - " .. format(...)
    )
end

function F:Debug(...)
    if self.db.Debug then
        self:Log(...)
        self:Print(...)
    end
end
