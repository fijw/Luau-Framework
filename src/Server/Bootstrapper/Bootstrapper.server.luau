--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LoadClientNamespace = require(ReplicatedStorage.Networking.Namespaces.LoadClient)

local Initialization = require(ReplicatedStorage.Initialization)

local CacheService = ServerScriptService.Services.CacheService
local ModerationService = ServerScriptService.Services.ModerationService
local CommandsPipelineService = ServerScriptService.Services.CommandsPipelineService
--[[ @end_section Imports ]]


local ModulesToLoad
= {
    CommandsPipelineService,
    CacheService,
    ModerationService
}


-- Initialize server modules then signal clients to initialize their modules.
do
    if not Initialization(ModulesToLoad :: { ModuleScript }) then
        print("Failed to initialize server modules.")

        return
    end

    LoadClientNamespace.packets.LoadClientModules.sendToAll(nil)

    -- Handle new players.
    do
        local function onPlayerAdded(player: Player)
            LoadClientNamespace.packets.LoadClientModules.sendTo(nil, player)
        end

        Players.PlayerAdded:Connect(onPlayerAdded)
    end
end