--------------------
-- Localization.lua
--
-- 2017/12/11
--------------------

local _, addon = ...

addon.L = {
  ["MSG_PREFIX"] = "|cFF70B8FFFree Instance Sharer|r:",
  ["SHARE_STARTING"] = "|cFFFFFF00Starting|r sharing.",
  ["SHARE_STARTED"] = "|cFF00FF00Started|r sharing.",
  ["SHARE_STOP"] = "|cFFFF0000Ended|r sharing.",
  ["TEXT_ENABLE"] = "|cFF00FF00Enabled|r",
  ["TEXT_DISABLE"] = "|cFFFF0000Disabled|r",
  ["AUTO_EXTEND"] = "Extend saved instance: ",
  ["AUTO_INVITE"] = "In-game whisper to invite: ",
  ["AUTO_INVITE_BN"] = "Battle.net whisper to invite: ",
  ["AUTO_INVITE_MSG"] = "Trigger text：%s",
  -- TODO: QUEUE_MSG & WELCOME_MSG
  ["AUTO_LEAVE"] = "Party message to leave: " -- CHANGED
}

if GetLocale() == "zhCN" then
  addon.L = {
    ["MSG_PREFIX"] = "|cFF70B8FF免费CD分享|r：",
    ["SHARE_STARTING"] = "|cFFFFFF00正在准备|r分享。",
    ["SHARE_STARTED"] = "|cFF00FF00开始|r分享。",
    ["SHARE_STOP"] = "|cFFFF0000停止|r分享。",
    ["TEXT_ENABLE"] = "|cFF00FF00启用|r",
    ["TEXT_DISABLE"] = "|cFFFF0000停用|r",
    ["AUTO_EXTEND"] = "自动延长锁定：",
    ["AUTO_INVITE"] = "密语自动邀请：",
    ["AUTO_INVITE_BN"] = "战网密语自动邀请：",
    ["AUTO_INVITE_MSG"] = "文本为：%s",
    -- TODO: QUEUE_MSG & WELCOME_MSG
    ["AUTO_LEAVE"] = "小队发言退组：" -- CHANGED
  }
end
