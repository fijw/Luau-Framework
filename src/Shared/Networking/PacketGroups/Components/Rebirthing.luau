--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    Rebirth = NetworkLib("rebirth", "Event",
        {
            clientType = true,
            serverType = nil
        }
    ),

    GetRebirthStats = NetworkLib("get_rebirth_stats", "Function",
        {
            clientType
            = {
                price = 0,
                neededLevels = 0,
                coinsMultiplier = 0   
            },

            serverType = nil
        }
    ),


    NotEnoughGemsToRebirth = NetworkLib("not_enough_gems_to_rebirth", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    NotEnoughLevelsToRebirth = NetworkLib("not_enough_levels_to_rebirth", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    MaxRebirthsReached = NetworkLib("max_rebirths_reached", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    SuccessfullyRebirthed = NetworkLib("successfully_rebirthed", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets