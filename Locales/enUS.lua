local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale("FreeInstanceSharer", "enUS", true)

-- print in ChatFrame
L["FIS:"] = "|cFF70B8FFFIS|r: "
L["SHARE_STARTING"] = "|cFFFFFF00Preparing|r sharing."
L["SHARE_STARTED"] = "|cFF00FF00Start|r sharing."
L["SHARE_STOP"] = "|cFFFF0000Stop|r sharing"
L["INVITE_ONLY_MODE"] = "|cFF00FF00Invite Only Mode|r."

-- Config Frame
L["Free Instance Sharer"] = true
L["DESCRIPTION"] = "Simply sharing your saved instance to others."
L["Settings"] = true
L["Notify Message"] = true
L["Enable"] = true
L["Invite Only"] = true
L["Prevent AFK"] = true
L["Debug Mode"] = true
L["Auto Extend Saved Instance"] = true
L["Auto Invite by In-game Whisper"] = true
L["Auto Invite by In-game Whisper Message"] = true
L["Auto Invite by Battle.net Whisper"] = true
L["Auto Invite by Battle.net Whisper Message"] = true
L["Leave Queue by In-game Whisper"] = true
L["Leave Queue by In-game Whisper Message"] = true
L["Check Queue Interval (ms)"] = true
L["Auto Entering Queue"] = true
L["Entering Queue Message"] = true
L["Max Waiting Time (s)"] = true
L["Auto Leave Group"] = true
L["Fetch Error Message"] = true
L["Query Message"] = true
L["Leave Queue Message"] = true
L["Welcome Message"] = true
L["Leave Message"] = true
L["TEXT_REPLACE"] = "自动排队信息、进组信息、退组信息可以含有以下字符串，发送时将被自动替换为对应的变量\nQCURR - 当前玩家在队列的位置，只在自动排队信息中有效。\nQLEN - 队列长度。\nMTIME - 最长等待进本时间。\nNAME - 当前CD号玩家名与服务器名。"
