--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Initialization = require(ReplicatedStorage.Initialization)

local LoadClientNamespace = require(ReplicatedStorage.Networking.Namespaces.LoadClient)

local ChatTagsService = StarterPlayer.StarterPlayerScripts.Services.ChatServices.ChatTagsService
local ChatCmdsService = StarterPlayer.StarterPlayerScripts.Services.ChatServices.ChatCmdsService
--[[ @end_section Imports ]]


local ModulesToLoad = { ChatTagsService, ChatCmdsService }


LoadClientNamespace.packets.LoadClientModules.listenOnce(
    function(data: nil, player: Player?)
        if not Initialization(ModulesToLoad :: { ModuleScript }) then print("Failed to initialize client modules.") end
    end
)