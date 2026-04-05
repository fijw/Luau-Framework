--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Initialization = require(ReplicatedStorage.Initialization)

local LoadClientNamespace = require(ReplicatedStorage.Networking.Namespaces.LoadClient)

local ChatTagsService = StarterPlayer.StarterPlayerScripts.Services.ChatTagsService
local FlyingService = StarterPlayer.StarterPlayerScripts.Services.CommandConsoleServices.FlyingService
local PermissionsDisplayService = StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.CommandConsoleUIServices.PermissionsDisplayService
local CommandConsoleUIService = StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.CommandConsoleUIServices.CommandConsoleUIService
local SpectateService = StarterPlayer.StarterPlayerScripts.Services.CommandConsoleServices.SpectateService

local LoadingScreenService = require(StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.LoadingScreenService)
--[[ @end_section Imports ]]


local ModulesToLoad
= {
    [ChatTagsService.Name] = ChatTagsService,
    [FlyingService.Name] = FlyingService,
    [PermissionsDisplayService.Name] = PermissionsDisplayService,
    [CommandConsoleUIService.Name] = CommandConsoleUIService,
    [SpectateService.Name] = SpectateService
}


-- Initialize client modules.
do
    task.spawn(function() LoadingScreenService() end)

    LoadClientNamespace.packets.LoadClientModules
    .listenOnce(
        function(data: nil, player: Player?)
            if not Initialization(ModulesToLoad :: { [string]: ModuleScript }) then print("Failed to initialize client modules.") end
        end
    )
end