--!strict
--!native
--!optimize 2


local DataSettings = require(script.DataSettings)
local ChatSettings = require(script.ChatSettings)
local CmdsSettings = require(script.CmdsSettings)


type PermissionTypes = CmdsSettings.PermissionTypes


local Settings
= {
    DataSettings = DataSettings,
    ChatSettings = ChatSettings,
    CmdsSettings = CmdsSettings,

    version = `1.0.0`
}


return Settings