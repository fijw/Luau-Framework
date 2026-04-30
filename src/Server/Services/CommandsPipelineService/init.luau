--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)


local GiveFunCmdsModule = require(script.Commands.GiveFunCmds)

local KickModule = require(script.Commands.ModerationCommands.Kick)
local BanModule = require(script.Commands.ModerationCommands.Ban)
local UnbanModule = require(script.Commands.ModerationCommands.Unban)
local TempBanModule = require(script.Commands.ModerationCommands.TempBan)
local ResetDataModule = require(script.Commands.ModerationCommands.ResetData)
local ViewModerationHistory = require(script.Commands.ModerationCommands.ViewModerationHistory)

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
local SpectateModule = require(script.Commands.CharacterCommands.Spectate)

local BringPlayerToServerModule = require(script.Commands.JoiningCommands.BringPlayerToServer)
local JoinPlayerServerModule = require(script.Commands.JoiningCommands.JoinPlayerServer)
local JoinReservedServer = require(script.Commands.JoiningCommands.JoinReservedServer)

local ShutdownServerModule = require(script.Commands.ServerCommands.ShutdownServer)
local LockServerModule = require(script.Commands.ServerCommands.LockServer)
local UnlockServerModule = require(script.Commands.ServerCommands.UnlockServer)


local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local GlobalCommandsHandler = require(script.GlobalCommandsHandler)

local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type CommandSchema
= {
    func: (sender: Player, Args: { string }) -> (),
    helpTag: string?
}

type PermissionTypes = CmdsSettings.PermissionTypes
--[[ @end_section Types ]]


--[[ @section Variables ]]
local debugging = false

local idAndReasonTag = "[User Id] [Reason]"
local idTag = "[User Id]"
local reasonTag = "[Reason]"

local CommandDataCallbackMap: { [string]: CommandSchema }
= {
    reset_data = { func = ResetDataModule, helpTag = idAndReasonTag },
    temp_ban = { func = TempBanModule, helpTag = "[User Id] [Time Amount] [Time Frame (minute(s), hour(s), day(s), year(s))] [Reason]" },
    ban = { func = BanModule, helpTag = idAndReasonTag },
    kick = { func = KickModule, helpTag = idAndReasonTag },
    unban = { func = UnbanModule, helpTag = idAndReasonTag },
    view_moderation_history = { func = ViewModerationHistory, helpTag = idTag },

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
    spectate = { func = SpectateModule, helpTag = idTag },

    bring_player_to_server = { func = BringPlayerToServerModule, helpTag = idTag },
    join_player_server = { func = JoinPlayerServerModule, helpTag = idTag },
    join_reserved_server = { func = JoinReservedServer },

    shutdown_server = { func = ShutdownServerModule, helpTag = reasonTag },
    lock_server = { func = LockServerModule },
    unlock_server = { func = UnlockServerModule },

    give_fun_cmds = { func = GiveFunCmdsModule, helpTag = idTag }
}

local MappedCommands
= {
    ModerationCmds = { "ban", "kick", "unban", "temp_ban", "view_moderation_history" },
    CharacterCmds = { "freeze", "unfreeze", "invisible", "visible", "teleport", "fly", "unfly", "speed", "kill", "fling", "spectate" },
    JoiningCmds = { "bring_player_to_server", "join_player_server", "join_reserved_server" },
    ServerCmds = { "shutdown_server", "lock_server", "unlock_server" },
    SpecialCmds = { "give_fun_cmds", "reset_data" }
}

local PermissionsMap: { [PermissionTypes]: { string } }
= {
    developer
    = TableUtils.combineArrays(
        MappedCommands.ModerationCmds,
        MappedCommands.CharacterCmds,
        MappedCommands.JoiningCmds,
        MappedCommands.ServerCmds,
        MappedCommands.SpecialCmds
    ),

    moderator
    = TableUtils.combineArrays(
        MappedCommands.ModerationCmds,
        MappedCommands.CharacterCmds,
        MappedCommands.JoiningCmds
    ),

    fun_perms = MappedCommands.CharacterCmds
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

            local rankPermissions = CmdsSettings.RanksWithCommandPermissions[playerRank]
            local idPermissions = CmdsSettings.UserIdsWithCommandPermissions[player.UserId]
            local funPermissions = CmdsSettings.ServerUsersGivenFunCommands[player.UserId]

            local MappedPermissions = if rankPermissions or idPermissions or funPermissions then PermissionsMap[rankPermissions or idPermissions or funPermissions] else nil

            -- If the player sends "help" and they have permission to use commands then send them a list of all available commands.
            if data[1] == "help" then
                if not MappedPermissions and not debugging then
                    CommandsNamespace.packets.ClientDisplayConsoleResponse
                    .sendTo(
                        {
                            response = `You do not have permission to view the list of commands.`,
                            color = "red"
                        },
                        
                        player
                    )

                    return
                end

                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = ``,
                        color = "white"
                    },
                    
                    player
                )

                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `Wrap 1 character long arguments in angle brackets. Example: "<1>" or "<u>".`,
                        color = "blue"
                    },
                    
                    player
                )

                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = ``,
                        color = "white"
                    },
                    
                    player
                )

                for i: string, CommandData: CommandSchema in pairs(CommandDataCallbackMap) do
                    if MappedPermissions then if not table.find(MappedPermissions, i) and not debugging then continue end end

                    CommandsNamespace.packets.ClientDisplayConsoleResponse
                    .sendTo(
                        {
                            response = if CommandData.helpTag then `{i} {CommandData.helpTag}` else i,
                            color = "yellow"
                        },
                        
                        player
                    )
                end

                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = ``,
                        color = "white"
                    },
                    
                    player
                )

                return
            end

            local MappedCommand = CommandDataCallbackMap[data[1]]

            if not MappedCommand then
                CommandsNamespace.packets.ClientDisplayConsoleResponse
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
                    CommandsNamespace.packets.ClientDisplayConsoleResponse
                    .sendTo(
                        {
                            response = `You do not have permission to use commands.`,
                            color = "red"
                        },
                        
                        player
                    )
                    
                    return
                end

                if MappedPermissions and not debugging then
                    if not table.find(MappedPermissions, data[1]) then
                        CommandsNamespace.packets.ClientDisplayConsoleResponse
                        .sendTo(
                            {
                                response = `You do not have permission to use "{data[1]}".`,
                                color = "red"
                            },
                            
                            player
                        )
                        
                        return
                    end
                end
            end

            --[[
                Replace all "me" arguments with the sender's id and remove angle brackets from arguments to help
                input 1 character arguments, eg. "<1>".
            ]]
            for i: number, arg: string in ipairs(data) do if arg:lower() == "me" then data[i] = `{player.UserId}` end end
            for i: number, arg: string in ipairs(data) do arg:gsub("[<>]", "") end

            -- Replace all player username arguments with their corresponding user ids.
            do
                local StoredPlayers = {} :: { Player }
                for i: number, loopedPlayer: Player in ipairs(Players:GetPlayers()) do table.insert(StoredPlayers, loopedPlayer) end

                for i: number, arg: string in ipairs(data) do
                    for storedPlrIndex: number, storedPlayer: Player in ipairs(StoredPlayers) do
                        if not string.find(storedPlayer.Name:lower(), arg:lower()) then continue end

                        data[i] = `{storedPlayer.UserId}`
                    end
                end
            end

            table.remove(data, 1)

            MappedCommand.func(player, data)
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]