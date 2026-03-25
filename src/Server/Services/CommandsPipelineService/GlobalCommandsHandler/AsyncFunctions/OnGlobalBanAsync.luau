--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataLib = require(ServerScriptService.Libraries.DataLib)

local Types = require(script.Parent.Parent.Types)
--[[ @end_section Imports ]]


type DataClass = DataLib.DataClass
type DecompressedDataSchema = Types.DecompressedDataSchema


--[[ @section Constructor ]]
--[[
    @usage Initialize the global command.

    @param DecompressedData DecompressedDataSchema

    @return void
]]
local function constructorCallback(DecompressedData: DecompressedDataSchema)
    local reason, targetId = DecompressedData.reason, DecompressedData.targetId
    if not reason or not targetId then return end

    local FoundPlayer = Players:GetPlayerByUserId(targetId)
    if not FoundPlayer then return end

    local PlayerDataClass = DataLib(FoundPlayer)
    if not PlayerDataClass then return end

    PlayerDataClass().ModerationData(
        {
            permanent = true,
            banReason = reason
        },
        
        "BanData"
    )
end

return constructorCallback
--[[ @end_section Constructor ]]