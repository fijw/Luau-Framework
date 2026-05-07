--!strict
--!native
--!optimize 2


local ArithmeticPetActions = require(script.Connections.ArithmeticPetActions)
local Coins = require(script.Connections.Coins)
local Requests = require(script.Connections.Requests)
local EndingActions = require(script.Connections.EndingActions)


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback()
    local ConstructorArray = { ArithmeticPetActions, Coins, Requests, EndingActions }

    for i: number, constructorCallback: () -> () in ipairs(ConstructorArray) do
        constructorCallback()
    end
end

return constuctorCallback
--[[ @end_section Constructor ]]