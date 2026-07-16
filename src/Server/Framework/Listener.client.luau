--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Initialization = ReplicatedStorage:FindFirstChild("Initialization")

local FrameworkGroup = require(ReplicatedStorage.Networking.PacketGroups.Framework)

local FlyingService = StarterPlayer.StarterPlayerScripts.Services.CommandConsoleServices.FlyingService
local PermissionsDisplayService = StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.CommandConsoleUIServices.PermissionsDisplayService
local CommandConsoleUIService = StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.CommandConsoleUIServices.CommandConsoleUIService
local SpectateService = StarterPlayer.StarterPlayerScripts.Services.CommandConsoleServices.SpectateService
local ChatTagService = StarterPlayer.StarterPlayerScripts.Services.ChatTagService

local LoadingScreenService = require(StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.LoadingScreenService)
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player?
local isServer = RunService:IsServer()

local ModulesToLoad: { [string]: ModuleScript }
= {
    [FlyingService.Name] = FlyingService,
    [PermissionsDisplayService.Name] = PermissionsDisplayService,
    [CommandConsoleUIService.Name] = CommandConsoleUIService,
    [SpectateService.Name] = SpectateService,
    [ChatTagService.Name] = ChatTagService
}

local NUM_OF_RETRIES = 10
--[[ @end_section Variables ]]


-- Pre-initialization.
do
    -- Check if the script is running on the server and prepare the initialization module.
    do
        if isServer then return end

        if Initialization then Initialization = require(Initialization) :: any
        else
            print("Client failed to find the Initialization module.")
            return 
        end
    end


    -- Add component modules to be initialized.
    for i: number, module: Instance in ipairs(StarterPlayer.StarterPlayerScripts.Components:GetChildren()) do
        ModulesToLoad[module.Name] = module :: ModuleScript
    end
end


-- Initialize client modules when the loading packet is received.
do
    task.spawn(function() LoadingScreenService() end)

    FrameworkGroup.LoadClientModules:onClientEvent(
        function(data: nil)
            local result: "success" | "failure"
            task.spawn(function() result = Initialization(ModulesToLoad :: { [string]: ModuleScript }) end)

            local retries = 0
            while true do if result or retries >= NUM_OF_RETRIES then break else retries += 1; task.wait() end end

            task.wait(5)

            if result == "success" or not localPlayer then return end
            (localPlayer :: Player):Kick(`\n\n\nYour client scripts could not be initialized.\nPlease try rejoining.\n\n`)
        end
    )
end