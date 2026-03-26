--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local GiveFunCmdsModule = require(script.Commands.GiveFunCmds)

local KickModule = require(script.Commands.ModerationCommands.Kick)
local BanModule = require(script.Commands.ModerationCommands.Ban)
local UnbanModule = require(script.Commands.ModerationCommands.Unban)
local TempBanModule = require(script.Commands.ModerationCommands.TempBan)

local FlyModule = require(script.Commands.CharacterCommands.Fly)
local UnflyModule = require(script.Commands.CharacterCommands.Unfly)
local FreezeModule = require(script.Commands.CharacterCommands.Freeze)
local UnfreezeModule = require(script.Commands.CharacterCommands.Unfreeze)
local InvisibleModule = require(script.Commands.CharacterCommands.Invisible)
local VisibleModule = require(script.Commands.CharacterCommands.Visible)
local TeleportModule = require(script.Commands.CharacterCommands.Teleport)
local SpeedModule = require(script.Commands.CharacterCommands.Speed)
local KillModule = require(script.Commands.CharacterCommands.Kill)
local FlingModule = require(script.Commands.CharacterCommands.Fling)

local BringPlayerToServerModule = require(script.Commands.JoiningCommands.BringPlayerToServer)
local JoinPlayerServerModule = require(script.Commands.JoiningCommands.JoinPlayerServer)
local JoinReservedServer = require(script.Commands.JoiningCommands.JoinReservedServer)

local ShutdownServerModule = require(script.Commands.ServerCommands.ShutdownServer)
local LockServerModule = require(script.Commands.ServerCommands.LockServer)
local UnlockServerModule = require(script.Commands.ServerCommands.UnlockServer)


local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local GlobalCommandsHandler = require(script.GlobalCommandsHandler)

local Settings = require(ReplicatedStorage.Settings)
local ChatSettings = require(ReplicatedStorage.Settings.ChatSettings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type CommandSchema
= {
    func: (sender: Player, Args: { string }) -> (),
    helpTag: string?
}

type PermissionTypes = ChatSettings.PermissionTypes
--[[ @end_section Types ]]


--[[ @section Variables ]]
local debugging = true

local idAndReasonTag = "[User Id] [Reason]"
local idTag = "[User Id]"
local reasonTag = "[Reason]"

local CommandCallbackMap: { [string]: CommandSchema }
= {
    temp_ban = { func = TempBanModule, helpTag = "[User Id] [Time Amount] [Time Frame (minutes, hours, days, years)] [Reason]" },
    ban = { func = BanModule, helpTag = idAndReasonTag },
    kick = { func = KickModule, helpTag = idAndReasonTag },
    unban = { func = UnbanModule, helpTag = idAndReasonTag },

    fly = { func = FlyModule, helpTag = idTag },
    unfly = { func = UnflyModule, helpTag = idTag },
    freeze = { func = FreezeModule, helpTag = idTag },
    unfreeze = { func = UnfreezeModule, helpTag = idTag },
    invisible = { func = InvisibleModule, helpTag = idTag },
    visible = { func = VisibleModule, helpTag = idTag },
    teleport = { func = TeleportModule, helpTag = "[Teleporting User Id] [Root User Id]" },
    speed = { func = SpeedModule, helpTag = "[User Id] [Speed]" },
    kill = { func = KillModule, helpTag = idTag },
    fling = { func = FlingModule, helpTag = idTag },

    bring_player_to_server = { func = BringPlayerToServerModule, helpTag = idTag },
    join_player_server = { func = JoinPlayerServerModule, helpTag = idTag },
    join_reserved_server = { func = JoinReservedServer },

    shutdown_server = { func = ShutdownServerModule, helpTag = reasonTag },
    lock_server = { func = LockServerModule },
    unlock_server = { func = UnlockServerModule },

    give_fun_cmds = { func = GiveFunCmdsModule, helpTag = idTag }
}

local PermissionsMap: { [PermissionTypes]: { string } }
= {
    developer
    = {
        "ban", "kick", "unban", "temp_ban",
        "freeze", "unfreeze", "invisible", "visible", "teleport", "fly", "unfly", "speed", "kill", "fling",
        "bring_player_to_server", "join_player_server", "join_reserved_server",
        "shutdown_server", "lock_server", "unlock_server",
        "give_fun_cmds"
    },

    moderator
    = {
        "ban", "kick", "unban", "temp_ban",
        "freeze", "unfreeze", "invisible", "visible", "teleport", "fly", "unfly", "speed", "kill", "fling",
        "bring_player_to_server", "join_player_server", "join_reserved_server"
    },

    fun_perms = { "fly", "unfly", "freeze", "unfreeze", "invisible", "visible", "teleport", "speed", "kill", "fling" }
}
--[[ @end_section Variables ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback()
    GlobalCommandsHandler()

    CommandsNamespace.packets.ServerHandleCommand
    .listen(
        function(data: { string }, player: Player?)
            if not player then return end

            local playerRank = player:GetRankInGroupAsync(game.CreatorId)

            local rankPermissions = ChatSettings.ChatCommandSettings.RanksWithCommandPermissions[playerRank]
            local idPermissions = ChatSettings.ChatCommandSettings.UserIdsWithCommandPermissions[player.UserId]
            local funPermissions = Settings.ServerUsersGivenFunCommands[player.UserId]

            local MappedPermissions = if rankPermissions or idPermissions or funPermissions then PermissionsMap[rankPermissions or idPermissions or funPermissions] else nil

            if data[1] == "help" then
                if not MappedPermissions and not debugging then
                    CommandsNamespace.packets.DisplayConsoleResponse
                    .sendTo(
                        {
                            response = `You do not have permissions to view the list of commands.`,
                            color = "red"
                        },
                        
                        player
                    )

                    return
                end

                for i: string, CommandData: CommandSchema in pairs(CommandCallbackMap) do
                    if MappedPermissions then if not table.find(MappedPermissions, i) and not debugging then continue end end

                    CommandsNamespace.packets.DisplayConsoleResponse
                    .sendTo(
                        {
                            response = if CommandData.helpTag then `{i} {CommandData.helpTag}` else i,
                            color = "yellow"
                        },
                        
                        player
                    )
                end

                return
            end

            local MappedCommand = CommandCallbackMap[data[1]]

            if not MappedCommand then
                CommandsNamespace.packets.DisplayConsoleResponse
                .sendTo(
                    {
                        response = `Send "help" to see a list of all available commands.`,
                        color = "red"
                    },
                    
                    player
                )

                return
            end

            -- Check if the player has the required permissions.
            do
                if not MappedPermissions and not debugging then
                    CommandsNamespace.packets.DisplayConsoleResponse
                    .sendTo(
                        {
                            response = `You do not have permissions to use commands.`,
                            color = "red"
                        },
                        
                        player
                    )
                    
                    return
                end

                if MappedPermissions and not debugging then
                    if not table.find(MappedPermissions, data[1]) then
                        CommandsNamespace.packets.DisplayConsoleResponse
                        .sendTo(
                            {
                                response = `You do not have permissions to use "{data[1]}".`,
                                color = "red"
                            },
                            
                            player
                        )
                        
                        return
                    end
                end
            end

            -- Replace all "me" arguments with the sender's id.
            for i: number, arg: string in ipairs(data) do if arg:lower() == "me" then data[i] = `{player.UserId}` end end

            table.remove(data, 1)

            MappedCommand.func(player, data)
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]