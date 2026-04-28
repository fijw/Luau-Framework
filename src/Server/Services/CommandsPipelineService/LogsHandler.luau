--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Log a command to Discord.

    @param actionType string
    @param senderId number
    @param targetId number
    @param reason string
    @param duration string?

    @return void
]]
local function constructorCallback(actionType: string, senderId: number, targetId: number, reason: string, duration: string?)
    local foundPlayer = Players:GetPlayerByUserId(targetId)
    
    if not foundPlayer then
        local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)
        if not AsyncData then return end

        if AsyncData.inUse then
            
        else

        end

    else
        local PlrDataClass = Registry(foundPlayer)
        if not PlrDataClass then return end

        PlrDataClass()().ModerationData()
    end

end

return constructorCallback
--[[ @end_section Constructor ]]