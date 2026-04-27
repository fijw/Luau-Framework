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

local LoadClientNamespace = require(ReplicatedStorage.Networking.Namespaces.LoadClient)


local CacheService = ServerScriptService.Services.CacheService
local ModerationService = ServerScriptService.Services.ModerationService
local CommandsPipelineService = ServerScriptService.Services.CommandsPipelineService

local InventoryComponent = StarterPlayer.StarterPlayerScripts.Components.UIComponents.Inventory


local Initialization = script.Initialization
local Listener = script.Listener


--[[ @end_section Imports ]]


--[[ @section Variables ]]
local serverKickMessage = `\n\n\nServer failed to initialize.\nPlease rejoin.\n\n`

local ModulesToLoad
= {
    [CommandsPipelineService.Name] = CommandsPipelineService,
    [CacheService.Name] = CacheService,
    [ModerationService.Name] = ModerationService,

    [InventoryComponent.Name] = InventoryComponent
}
--[[ @end_section Variables ]]


-- Move the initialization and listener modules to their respective locations.
do
    Listener.Parent = StarterPlayer.StarterPlayerScripts

    Initialization.Parent = ReplicatedStorage
    Initialization = require(ReplicatedStorage:WaitForChild("Initialization")) :: any
end


-- Initialize server modules then signal clients to initialize their modules.
do
    --if not require(script.Pragma) then print("Server initialization cancelled."); return end

    local initResult: "success" | "failure" = Initialization(ModulesToLoad :: { [string]: ModuleScript }) :: any

    if initResult == "failure" then
        for i: number, player: Player in Players:GetPlayers() do
            player:Kick(serverKickMessage)
        end

        return
    end

    LoadClientNamespace.packets.LoadClientModules.sendToAll(nil)

    -- Handle new players.
    do
        local function onPlayerAdded(player: Player)
            if initResult == "success" then LoadClientNamespace.packets.LoadClientModules.sendTo(nil, player); return end
            player:Kick(serverKickMessage)
        end

        Players.PlayerAdded:Connect(onPlayerAdded)
    end
end