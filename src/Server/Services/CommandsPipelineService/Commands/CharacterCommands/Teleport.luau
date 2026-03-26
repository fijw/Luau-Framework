--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
--[[ @end_section Imports ]]


--[[
    @usage Display a failed message to the console.

    @param targetId number
    @param sender Player
    @param inputText string

    @return void
]]
local function failedToExecute(targetId: number, sender: Player, inputText: string)
    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Failed to teleport [{targetId}]. {inputText}.`,
            color = "red"
        },
        
        sender
    )
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string })
    local targetId1 = tonumber(args[1]) :: number
    if not targetId1 then return end

    table.remove(args, 1)

    local targetId2 = tonumber(args[1]) :: number
    if not targetId2 then return end

    table.remove(args, 1)

    local rootPlayerRootPart: BasePart
    local teleportingPlayerRootPart: BasePart

    -- Get the root player's root part.
    do
        local rootPlayer = Players:GetPlayerByUserId(targetId2)
        if not rootPlayer then failedToExecute(targetId2, sender, "Root player not found"); return end

        local rootPlayerCharacter = rootPlayer.Character
        if not rootPlayerCharacter then failedToExecute(targetId2, sender, "Root character not found"); return end

        local rootCharacterRootPart = rootPlayerCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
        if not rootCharacterRootPart then failedToExecute(targetId2, sender, "Root root part not found"); return end

        rootPlayerRootPart = rootCharacterRootPart
    end

    -- Get the teleporting player's root part.
    do
        local teleportingPlayer = Players:GetPlayerByUserId(targetId1)
        if not teleportingPlayer then failedToExecute(targetId1, sender, "Teleporting player not found"); return end

        local teleportingPlayerCharacter = teleportingPlayer.Character
        if not teleportingPlayerCharacter then failedToExecute(targetId1, sender, "Teleporting character not found"); return end

        local teleportingCharacterRootPart = teleportingPlayerCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
        if not teleportingCharacterRootPart then failedToExecute(targetId1, sender, "Teleporting root part not found"); return end

        teleportingPlayerRootPart = teleportingCharacterRootPart
    end

    teleportingPlayerRootPart.CFrame = rootPlayerRootPart.CFrame

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Teleported [{targetId1}] to [{targetId2}].`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]