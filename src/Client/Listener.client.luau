--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Initialization = require(ReplicatedStorage.Initialization)

local LoadClientNamespace = require(ReplicatedStorage.Networking.Namespaces.LoadClient)

local ChatTagsService = StarterPlayer.StarterPlayerScripts.Services.ChatTagsService
local FlyingService = StarterPlayer.StarterPlayerScripts.Services.FlyingService
local PermissionsDisplayService = StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.PermissionsDisplayService
local CommandConsoleUIService = StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.CommandConsoleUIService

local LoadingScreenService = require(StarterPlayer.StarterPlayerScripts.Services.OnScreenServices.LoadingScreenService)
--[[ @end_section Imports ]]


local ModulesToLoad
= {
    ChatTagsService,
    FlyingService,
    PermissionsDisplayService,
    CommandConsoleUIService
}


-- Initialize client modules.
do
    task.spawn(function() LoadingScreenService() end)

    LoadClientNamespace.packets.LoadClientModules
    .listenOnce(
        function(data: nil, player: Player?)
            if not Initialization(ModulesToLoad :: { ModuleScript }) then print("Failed to initialize client modules.") end
        end
    )
end