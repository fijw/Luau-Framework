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
            response = `Failed to fling [{targetId}]. {inputText}.`,
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
    local targetId = tonumber(args[1]) :: number
    if not targetId then return end

    table.remove(args, 1)

    -- Fling the player's character.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then failedToExecute(targetId, sender, "Target player not found"); return end

        local targetCharacter = targetPlayer.Character
        if not targetCharacter then failedToExecute(targetId, sender, "Target character not found"); return end

        local rootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not rootPart then failedToExecute(targetId, sender, "Target root part not found"); return end

		local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
		bodyAngularVelocity.AngularVelocity = Vector3.new(0, 99999, 0)
		bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
		bodyAngularVelocity.P = math.huge
		bodyAngularVelocity.Parent = rootPart

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 500, 0)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = rootPart

        task.wait()

        bodyAngularVelocity:Destroy()
        bodyVelocity:Destroy()
    end

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Flung [{targetId}].`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]