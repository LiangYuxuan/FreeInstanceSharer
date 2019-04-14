local addonName, addon = ...
local L = {}

L["Auto Entering Queue"] = "Auto Entering Queue"
L["Auto Extend Saved Instance"] = "Auto Extend Saved Instance"
L["Auto Invite by Battle.net Whisper Message"] = "Auto Invite by Battle.net Whisper Message"
L["Auto Invite by Battle.net Whisper"] = "Auto Invite by Battle.net Whisper"
L["Auto Invite by In-game Whisper Message"] = "Auto Invite by In-game Whisper Message"
L["Auto Invite by In-game Whisper"] = "Auto Invite by In-game Whisper"
L["Auto Leave Group"] = "Auto Leave Group"
L["Check Queue Interval (ms)"] = "Check Queue Interval (ms)"
L["Debug Mode"] = "Debug Mode"
L["Entering Queue Message"] = "Entering Queue Message"
L["Fail to fetch your character infomation from Battle.net, please try to whisper to NAME in game."] = "Fail to fetch your character infomation from Battle.net, please try to whisper to NAME in game."
L["Fetch Error Message"] = "Fetch Error Message"
L["Free Instance Sharer"] = "Free Instance Sharer"
L["General settings"] = "General settings"
L["Invite Only Mode"] = "Invite Only Mode"
L["Leave Message"] = "Leave Message"
L["Leave Queue Message"] = "Leave Queue Message"
L["Leave Queue by In-game Whisper Message"] = "Leave Queue by In-game Whisper Message"
L["Leave Queue by In-game Whisper"] = "Leave Queue by In-game Whisper"
L["MTIME - Max time to wait players to enter instances."] = "MTIME - Max time to wait players to enter instances."
L["Max Waiting Time (s)"] = "Max Waiting Time (s)"
L["NAME - The name and realm of current character."] = "NAME - The name and realm of current character."
L["Notify Message"] = "Notify Message"
L["Open config"] = "Open config"
L["Prevent AFK"] = "Prevent AFK"
L["Promoted you to team leader. If you're in Icecrown Citadel, you need to set to Heroic by yourself."] = "Promoted you to team leader. If you're in Icecrown Citadel, you need to set to Heroic by yourself."
L["QCURR - The position of the player in queue."] = "QCURR - The position of the player in queue."
L["QLEN - The length of the queue."] = "QLEN - The length of the queue."
L["Query Message"] = "Query Message"
L["Welcome Message"] = "Welcome Message"
L["You can insert following words into the text field, and it will be replace by corresponding variables."] = "You can insert following words into the text field, and it will be replace by corresponding variables."
L["You have MTIME second(s) to enter instance. Difficulty set to 25 players normal in default. Send '10' in party to set to 10 players, 'H' to set to Heroic."] = "You have MTIME second(s) to enter instance. Difficulty set to 25 players normal in default. Send '10' in party to set to 10 players, 'H' to set to Heroic."
L["You're queued, and your postion is QCURR."] = "You're queued, and your postion is QCURR."

-- Make missing translations available
addon.L = setmetatable(L, {
    __index = function(self, key)
        self[key] = (key or "")
        return key
    end
})
