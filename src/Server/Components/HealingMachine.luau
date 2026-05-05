--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local HealingMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.HealingMachine)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the hatch pet packet.

    @return void
]]
local function constructorCallback()
    
end

return constructorCallback
--[[ @end_section Constructor ]]