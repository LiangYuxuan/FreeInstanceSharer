--------------------
-- Localization.lua
--
-- 2017/12/11
--------------------

local _, addon = ...

addon.L = {
  -- TODO: English Version
}

-- TODO: Change this when English Version ready
-- if GetLocale() == "zhCN" then
if true then
  addon.L = {
    ["MSG_PREFIX"] = "|cFF70B8FF免费CD分享|r：",
    ["SHARE_STARTING"] = "|cFFFFFF00正在准备|r分享。",
    ["SHARE_STARTED"] = "|cFF00FF00开始|r分享。",
    ["SHARE_STOP"] = "|cFFFF0000停止|r分享。",
    ["TEXT_ENABLE"] = "|cFF00FF00启用|r",
    ["TEXT_DISABLE"] = "|cFFFF0000停用|r",
    ["AUTO_EXTEND"] = "自动延长锁定：",
    ["CHECK_INVAL"] = "检查时间间隔：",
    ["AUTO_INVITE"] = "密语自动邀请：",
    ["AUTO_INVITE_BN"] = "战网密语自动邀请：",
    ["AUTO_INVITE_MSG"] = "文本为：%s",
    ["AUTO_QUEUE"] = "进组申请排队：",
    ["SHOW_WELCOME_MSG"] = "进组信息：",
    ["SHOW_LEAVE_MSG"] = "退组信息：",
    ["MAX_TIME"] = "最长等待进本时间：",
    ["AUTO_LEAVE"] = "检查成员位置并退组：",
    ["QUEUE_MSG"] = "你已进入队列，排在第 %d 名。",
    ["WELCOME_MSG"] = "你现在有 %d 秒的进本时间。默认难度为25人普通，在队伍发送 10 切换为10人模式，发送 H 切换为英雄模式。",
    ["LEAVE_MSG"] = "已将队长转交，刷无敌请自行在副本内修改难度为英雄（如果未成功请在副本外设置自己为25普通在来一次）。",
  }
end
