# FreeInstanceSharer

A light World of Warcraft addon to share your saved instance to others.

## Introduction

Share saved instance by invite other players by in-game whisper or battle.net whisper. Also with other supporting feature.

* Invite player who send whisper to you.
* Auto extending saved instance.
* Auto change difficulty.
* Auto leave party when receiving message in party channel.

## Usage

Copy `FreeInstanceSharer` to `Interface/Addons`, and enable this addon in game.

## Configuration

```
local enable = true -- enable when started (will be changed to save the status of last login)
local autoDifficulty = true -- auto change difficulty
local autoExtend = true -- auto extending saved instance
local autoInvite = true -- invite by in-game whisper
local autoInviteMsg = "123" -- in-game whisper message
local autoInviteBN = true -- invite by battle.net whisper
local autoInviteBNMsg = "123" -- battle.net whisper message
local autoLeave = true -- auto leave party when receiving message in party channel
```

Modify above vars in `FreeInstanceSharer.lua`.

## Future plans

- [ ] Add queue
- [ ] In-game settings

## Contribution

PR to this project.

## License

The MIT License
