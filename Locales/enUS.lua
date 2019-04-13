local addonName, addon = ...
local L = {}

L["Auto Entering Queue"] = true
L["Auto Extend Saved Instance"] = true
L["Auto Invite by Battle.net Whisper Message"] = true
L["Auto Invite by Battle.net Whisper"] = true
L["Auto Invite by In-game Whisper Message"] = true
L["Auto Invite by In-game Whisper"] = true
L["Auto Leave Group"] = true
L["Check Queue Interval (ms)"] = true
L["Debug Mode"] = true
L["Entering Queue Message"] = true
L["Fail to fetch your character infomation from Battle.net, please try to whisper to NAME in game."] = true
L["Fetch Error Message"] = true
L["Free Instance Sharer"] = true
L["General settings"] = true
L["Invite Only Mode"] = true
L["Leave Message"] = true
L["Leave Queue Message"] = true
L["Leave Queue by In-game Whisper Message"] = true
L["Leave Queue by In-game Whisper"] = true
L["MTIME - Max time to wait players to enter instances."] = true
L["Max Waiting Time (s)"] = true
L["NAME - The name and realm of current character."] = true
L["Notify Message"] = true
L["Open config"] = true
L["Prevent AFK"] = true
L["Promoted you to team leader. If you're in Icecrown Citadel, you need to set to Heroic by yourself."] = true
L["QCURR - The position of the player in queue."] = true
L["QLEN - The length of the queue."] = true
L["Query Message"] = true
L["Welcome Message"] = true
L["You can insert following words into the text field, and it will be replace by corresponding variables."] = true
L["You have MTIME second(s) to enter instance. Difficulty set to 25 players normal in default. Send '10' in party to set to 10 players, 'H' to set to Heroic."] = true
L["You're queued, and your postion is QCURR."] = true

addon.L = setmetatable(L, {
    __index = function (self, key)
        return self[key] == true and key or self[key] or key
    end
})
