local F, L, P, G = unpack((select(2, ...)))

P.DBVer = 2
P.Enable = false
P.Debug = false
P.AutoExtend = true
P.DNDMessage = true
P.InviteOnWhisper = true
P.InviteOnWhisperMsg = '123'
P.InviteOnBNWhisper = true
P.InviteOnBNWhisperMsg = '123'
P.BlacklistMaliciousUser = true
P.AutoQueue = true
P.LeaveQueueOnWhisper = true
P.LeaveQueueOnWhisperMsg = '233'
P.AutoLeave = true
P.InviteTimeLimit = 0
P.TimeLimit = 30
P.WhisperMessage = true
P.BNWhisperMessage = true
P.GroupMessage = true
P.DNDMsg = L["Current length of queue: QLEN."]
P.EnterQueueMsg = L["You're queued. Position in queue: QCURR."]
P.QueryQueueMsg = L["You're queued. Position in queue: QCURR."]
P.LeaveQueueMsg = ERR_LFG_LEFT_QUEUE
P.FetchErrorMsg = L["Failed to fetch your character information from Battle.net, please PM NAME."]
P.WelcomeMsg = L["MTIME second(s) to enter instance. Difficulty set to 25 players normal. Send '10/25/N/H' in party to change, 'leave' to leave, 'raid'/'party' to convert to raid/party."]
P.TLELeaveMsg = L["Time Limit Exceeded. You're promoted to team leader."]
P.AutoLeaveMsg = L["You're promoted to team leader. Good luck!"]
P.Blacklist = {}

G.DebugLog = {
    {},
    {},
    {},
}
