--!strict
--!native
--!optimize 2


local DataSettings = require(script.DataSettings)
local ChatSettings = require(script.ChatSettings)


type PermissionTypes = ChatSettings.PermissionTypes


local Settings
= {
    DataSettings = DataSettings,
    ChatSettings = ChatSettings,

    serverIsLocked = false,

    ServerUsersGivenFunCommands = {} :: { [number]: PermissionTypes }
}


return Settings