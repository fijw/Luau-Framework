--!strict
--!native
--!optimize 2


local ArithmeticPetActions = require(script.Connections.ArithmeticPetActions)
local Coins = require(script.Connections.Coins)
local Requests = require(script.Connections.Requests)
local EndingActions = require(script.Connections.EndingActions)


local ConnectionsMap: { () -> () } = { ArithmeticPetActions, Coins, Requests, EndingActions }


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback()
    for i: number, connectionCallback: () -> () in ipairs(ConnectionsMap) do
        connectionCallback()
    end
end

return constuctorCallback
--[[ @end_section Constructor ]]