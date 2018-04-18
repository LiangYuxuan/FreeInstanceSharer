local _, addon = ...

addon.L = {
  -- TODO: English Version
}

-- TODO: Change this when English Version ready
-- if GetLocale() == "zhCN" then
if true then
  addon.L = {
    -- print in ChatFrame
    ["MSG_PREFIX"] = "|cFF70B8FF便利CD分享|r：",
    ["SHARE_STARTING"] = "|cFFFFFF00正在准备|r分享。",
    ["SHARE_STARTED"] = "|cFF00FF00开始|r分享。",
    ["SHARE_STOP"] = "|cFFFF0000停止|r分享。",
    ["INVITE_ONLY_MODE"] = "|cFF00FF00极简模式|r。",

    -- Config Frame
    ["TITLE"] = "便利CD分享",
    ["DESC"] = "提供自动组队、自动排队、自动退组等功能，便利地共享副本CD。",
    ["SETTING"] = "设置",
    ["ENABLE"] = "启用",
    ["INVITE_ONLY"] = "极简模式",
    ["PREVENT_AFK"] = "防暂离",
    ["AUTO_EXTEND"] = "自动延长副本锁定",
    ["AUTO_INVITE"] = "密语自动邀请",
    ["AUTO_INVITE_BN"] = "战网密语自动邀请",
    ["CHECK_INVAL"] = "检查时间间隔",
    ["AUTO_QUEUE"] = "自动排队",
    ["MAX_TIME"] = "最长等待进本时间",
    ["AUTO_LEAVE"] = "检查成员位置并自动退组",
    ["WELCOME_MSG"] = "进组信息",
    ["LEAVE_MSG"] = "退组信息",
  }
end
