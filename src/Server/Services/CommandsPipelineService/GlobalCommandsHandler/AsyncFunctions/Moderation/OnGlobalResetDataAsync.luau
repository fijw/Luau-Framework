--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local Types = require(script.Parent.Parent.Parent.Types)

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)
--[[ @end_section Imports ]]


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

    local PlayerDataClass = Registry(FoundPlayer)
    if not PlayerDataClass then return end

    for i: string, v: any in pairs(DataSettings.DataTemplate :: { [string]: any }) do
        PlayerDataClass()()[i](v)
    end

    FoundPlayer:Kick(`\n\nYour data has been reset.\nReason: "{reason}".\n\n\n`)
end

return constructorCallback
--[[ @end_section Constructor ]]