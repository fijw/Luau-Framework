--[[
    @author                                                            
    ```                                                                
        Roblox: @roblox_user_5618502527                                
        GitHub: @fijw (k4)                                             
        Twitter: @Xjwfi (k4)                                           
        Discord: @vfjx (k4)                                            
    ```                                                               

    @version 2.1.3                                                     

    @description                                                       
    ```
        Easy-to-use framework for initializing server & client modules.
        Includes an initialization module that requires and initializes
        modules until success, a pragma module for verifying that the
        framework's current version is updated and that the server is
        inside of an active cache list, and a listener script for
        client-side module initialization that is triggered when the
        server modules have finished initializing. This framework is
        also built to work with a networking library, ByteNet-Max.
    ```
]]
--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local FrameworkGroup = require(ReplicatedStorage.Networking.PacketGroups.Framework)


local CacheService = ServerScriptService.Services.CacheService
local ModerationService = ServerScriptService.Services.ModerationService
local CommandsPipelineService = ServerScriptService.Services.CommandsPipelineService

local InventoryComponent = ServerScriptService.Components.Inventory
local CrateMachineComponent = ServerScriptService.Components.CrateMachine
local StatsUpdatingComponent = ServerScriptService.Components.StatsUpdating
local DeveloperSpawningComponent = ServerScriptService.Components.DeveloperSpawning
local RebirthingComponent = ServerScriptService.Components.Rebirthing
local MergingMachineComponent = ServerScriptService.Components.MergingMachine
local HealingMachineComponent = ServerScriptService.Components.HealingMachine
local TradingComponent = ServerScriptService.Components.Trading
local PetsHandlingComponent = ServerScriptService.Components.PetsHandling
local ChatTagsService = ServerScriptService.Services.ChatTagsService


local Initialization = script.Initialization
local Listener = script.Listener


--[[ @end_section Imports ]]


--[[ @section Variables ]]
local serverKickMessage = `\n\n\nServer failed to initialize.\nPlease rejoin.\n\n`

local ModulesToLoad
= {
    [CacheService.Name] = CacheService,
    [ModerationService.Name] = ModerationService,
    [CommandsPipelineService.Name] = CommandsPipelineService,

    [InventoryComponent.Name] = InventoryComponent,
    [CrateMachineComponent.Name] = CrateMachineComponent,
    [StatsUpdatingComponent.Name] = StatsUpdatingComponent,
    [DeveloperSpawningComponent.Name] = DeveloperSpawningComponent,
    [RebirthingComponent.Name] = RebirthingComponent,
    [MergingMachineComponent.Name] = MergingMachineComponent,
    [HealingMachineComponent.Name] = HealingMachineComponent,
    [TradingComponent.Name] = TradingComponent,
    [PetsHandlingComponent.Name] = PetsHandlingComponent,
    [ChatTagsService.Name] = ChatTagsService
}

local NUM_OF_RETRIES = 10
--[[ @end_section Variables ]]


-- Move the initialization and listener modules to their respective locations.
do
    Listener.Parent = StarterPlayer.StarterPlayerScripts

    Initialization.Parent = ReplicatedStorage
    Initialization = require(ReplicatedStorage:WaitForChild("Initialization")) :: any
end


-- Initialize server modules then signal clients to initialize their modules.
do
    local initResult: "success" | "failure"
    task.spawn(function(): () initResult = Initialization(ModulesToLoad :: { [string]: ModuleScript }) end)

    -- Handle initialization failures.s
    do
        local retries = 0
        while true do if initResult or retries >= NUM_OF_RETRIES then break else retries += 1; task.wait() end end

        if initResult == "failure" or not initResult then
            task.wait(5); if initResult or initResult == "success" then return end

            for i: number, player: Player in Players:GetPlayers() do
                player:Kick(serverKickMessage)
            end

            return
        end
    end

    FrameworkGroup.LoadClientModules:fireAllClients()

    -- Handle new players.
    do
        local function onPlayerAdded(player: Player): ()
            if initResult == "success" then FrameworkGroup.LoadClientModules:fireClient(player); return end
            task.wait(5); if initResult == "success" then FrameworkGroup.LoadClientModules:fireClient(player); return end

            player:Kick(serverKickMessage)
        end

        Players.PlayerAdded:Connect(onPlayerAdded)
    end
end