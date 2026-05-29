--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)

local CmdsSettings = require(ReplicatedStorage.FrameworkSettings.CmdsSettings)
--[[ @end_section Imports ]]


type SavingInventoryClassSchema = Stackentory.SavingInventoryClassSchema


--[[ @section Constructor ]]
--[[
    @usage Handles player cache upon joining and leaving.
    
    @return void
]]
local function constructorCallback(): ()
    local function onPlayerAdded(player: Player): ()
        local PlrDataClass = Registry(player, true)
        if not PlrDataClass then return end
    end

    local function onPlayerRemoving(player: Player): ()
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        PlrDataClass:saveClass()
        PlrDataClass:deleteClass()

        if not CmdsSettings.ServerUsersGivenFunCommands[player.UserId] then return end
        CmdsSettings.ServerUsersGivenFunCommands[player.UserId] = nil
    end

    -- Handle player joining and leaving connections.
    do
        for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

        Players.PlayerAdded:Connect(onPlayerAdded)
        Players.PlayerRemoving:Connect(onPlayerRemoving)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]