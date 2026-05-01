--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    HandleCommand = NetworkLib("handle_command", "Event",
        {
            clientType = nil,
            serverType = { "command_argument" }
        }
    ),


    FlyCharacter = NetworkLib("fly_character", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    UnflyCharacter = NetworkLib("unfly_character", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    DisplayConsoleMessage = NetworkLib("display_console_message", "Event",
        {
            clientType = { message = "", color = "" },
            serverType = nil
        }
    ),

    DisplayNewPermissions = NetworkLib("display_new_permissions", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    ChangeConsolePermissionsText = NetworkLib("change_console_permissions_text", "Event",
        {
            clientType = "new_permissions_text",
            serverType = nil
        }
    ),

    
    SpectateTarget = NetworkLib("spectate_target", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets