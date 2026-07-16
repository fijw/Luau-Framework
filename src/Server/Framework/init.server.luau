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

local Initialization = script.Initialization
local Listener = script.Listener
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local serverKickMessage = `\n\n\nServer failed to initialize.\nPlease rejoin.\n\n`

local ModulesToLoad: { [string]: ModuleScript } = {}

local NUM_OF_RETRIES = 10
--[[ @end_section Variables ]]


-- Move the initialization and listener modules to their respective locations.
do
    Listener.Parent = StarterPlayer.StarterPlayerScripts

    Initialization.Parent = ReplicatedStorage
    Initialization = require(ReplicatedStorage:WaitForChild("Initialization")) :: any
end


-- Fetch services & components to be initialized.
do
    for i: number, module: Instance in ipairs(ServerScriptService.Services:GetChildren()) do
        ModulesToLoad[module.Name] = module :: ModuleScript
    end

    for i: number, module: Instance in ipairs(ServerScriptService.Components:GetChildren()) do
        ModulesToLoad[module.Name] = module :: ModuleScript
    end
end


-- Initialize server modules then signal clients to initialize their modules.
do
    local initResult: "success" | "failure"
    task.spawn(function() initResult = Initialization(ModulesToLoad :: { [string]: ModuleScript }) end)

    -- Handle initialization failures.
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
        local function onPlayerAdded(player: Player)
            if initResult == "success" then FrameworkGroup.LoadClientModules:fireClient(player); return end
            task.wait(5); if initResult == "success" then FrameworkGroup.LoadClientModules:fireClient(player); return end

            player:Kick(serverKickMessage)
        end

        Players.PlayerAdded:Connect(onPlayerAdded)
    end
end