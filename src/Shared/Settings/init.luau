--!strict
--!native
--!optimize 2


local DataSettings = require(script.DataSettings)
local ChatSettings = require(script.ChatSettings)


local Settings
= {
    DataSettings = DataSettings,
    ChatSettings = ChatSettings,

    serverIsLocked = false,

    ServerUsersWithFunCommands = {} :: { number }
}


return Settings