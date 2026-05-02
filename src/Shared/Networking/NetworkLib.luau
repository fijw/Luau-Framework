--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
local StringToHex = require(ReplicatedStorage.Libraries.DataLibs.StringToHex)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic C Client argument. ]]
type ClientRemoteEventCallbackType<C> = (data: C) -> ()

--[[ @generic S Server argument. ]]
type ServerRemoteEventCallbackType<S> = (sender: Player, data: S) -> ()

--[[
    @generic S Server argument.
    @generic C Client argument.
]]
type ServerRemoteFunctionCallbackType<C, S> = (sender: Player, data: S) -> (C)

--[[
    @generic C Client argument.
    @generic S Server argument.
]]
type ClientRemoteFunctionCallbackType<C, S> = (data: C) -> (S)


--[[
    @generic C Client argument.
    @generic S Server argument.
]]
export type Packet<C, S> = setmetatable
<
    {
        clientRemote: RemoteEvent | RemoteFunction,

        packetId: string,
        securityTag: string,

        serverConnection: RBXScriptConnection?,
        clientConnection: RBXScriptConnection?
    },

    {
        __index
        : {
            fireClient: (self: Packet<C, S>, player: Player, data: C) -> (),
            fireAllClients: (self: Packet<C, S>, data: C) -> (),
            fireServer: (self: Packet<C, S>, data: S) -> (),

            invokeClient: (self: Packet<C, S>, player: Player, data: C) -> (S),
            invokeServer: (self: Packet<C, S>, data: S) -> (C),

            onClientEvent: (self: Packet<C, S>, callback: ClientRemoteEventCallbackType<C>) -> (),
            onServerEvent: (self: Packet<C, S>, callback: ServerRemoteEventCallbackType<S>) -> (),

            onClientInvoke: (self: Packet<C, S>, callback: ClientRemoteFunctionCallbackType<C, S>) -> (S),
            onServerInvoke: (self: Packet<C, S>, callback: ServerRemoteFunctionCallbackType<C, S>) -> (C),

            disconnectAll: (self: Packet<C, S>) -> ()
        }
    }
>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local isClient = RunService:IsClient()

local CachedPackets = {}
--[[ @end_section Variables ]]


--[[ @section Firing Functions ]]
--[[
    @usage Fire an event to a player.

    @generic C Client argument.

    @param self Packet<any, any>
    @param player Player
    @param data C

    @return void
]]
local function fireClientCallback<C>(self: Packet<any, any>, player: Player, data: C)
    if isClient then return end

    local CompressedData = {}

    if typeof(data) == "table" then
        for i: any, v: any in pairs(data :: any) do
            CompressedData[i] = Compression(v)
        end

        CompressedData = Compression(CompressedData)
    else
        CompressedData = Compression(data)
    end

    -- Send the event.
    do
        local remoteEvent = script:FindFirstChild(self.packetId) :: RemoteEvent
        if not remoteEvent then return end

        remoteEvent:FireClient(player, CompressedData, Compression(self.securityTag))
    end
end

--[[
    @usage Fire an event to all players.

    @generic C Client argument.

    @param self Packet<any, any>
    @param data C

    @return void
]]
local function fireAllClientsCallback<C>(self: Packet<any, any>, data: C)
    if isClient then return end

    local CompressedData = {}

    if typeof(data) == "table" then
        for i: any, v: any in pairs(data :: any) do
            CompressedData[i] = Compression(v)
        end

        CompressedData = Compression(CompressedData)
    else
        CompressedData = Compression(data)
    end

        -- Send the event.
    do
        local remoteEvent = script:FindFirstChild(self.packetId) :: RemoteEvent
        if not remoteEvent then return end

        remoteEvent:FireAllClients(CompressedData, Compression(self.securityTag))
    end
end

--[[
    @usage Fire an event to the server.

    @generic S Server argument.

    @param self Packet<any, any>
    @param data S

    @return void
]]
local function fireServerCallback<S>(self: Packet<any, any>, data: S)
    if not isClient then return end

    local player = Players.LocalPlayer :: Player
    if not player then return end

    local CompressedData = {}

    if typeof(data) == "table" then
        for i: any, v: any in pairs(data :: any) do
            CompressedData[i] = Compression(v)
        end

        CompressedData = Compression(CompressedData)
    else
        CompressedData = Compression(data)
    end

    (self.clientRemote :: RemoteEvent):FireServer(CompressedData, Compression(self.securityTag))
end
--[[ @end_section Firing Functions ]]


--[[ @section Invoking Functions ]]
--[[
    @usage Invoke a function to a player.

    @generic C Client argument.

    @param self Packet<any, any>
    @param player Player
    @param data C

    @return any
]]
local function invokeClientCallback<C>(self: Packet<any, any>, player: Player, data: C): any
    if isClient then return end

    local CompressedData = {}

    if typeof(data) == "table" then
        for i: any, v: any in pairs(data :: any) do
            CompressedData[i] = Compression(v)
        end

        CompressedData = Compression(CompressedData)
    else
        CompressedData = Compression(data)
    end

    -- Send the function.
    do
        local remoteFunction = script:FindFirstChild(self.packetId) :: RemoteFunction
        if not remoteFunction then return end

        return remoteFunction:InvokeClient(player, CompressedData, Compression(self.securityTag))
    end
end

--[[
    @usage Invoke a function to the server.

    @generic S Server argument.

    @param self Packet<any, any>
    @param data S

    @return any
]]
local function invokeServerCallback<S>(self: Packet<any, any>, data: S): any
    if not isClient then return end

    local CompressedData = {}

    if typeof(data) == "table" then
        for i: any, v: any in pairs(data :: any) do
            CompressedData[i] = Compression(v)
        end

        CompressedData = Compression(CompressedData)
    else
        CompressedData = Compression(data)
    end

    return (self.clientRemote :: RemoteFunction):InvokeServer(CompressedData, Compression(self.securityTag))
end
--[[ @end_section Invoking Functions ]]


--[[ @section Callback Functions ]]
--[[
    @usage Register a client callback for when an event is fired.

    @param self Packet<any, any>
    @param callback ClientRemoteEventCallbackType

    @return void
]]
local function onClientEventCallback<C>(self: Packet<any, any>, callback: ClientRemoteEventCallbackType<C>)
    if not isClient then return end

    self.clientConnection
    = (self.clientRemote :: RemoteEvent).OnClientEvent:Connect(
        function(data: buffer, securityTag: buffer)
            if typeof(data) ~= "buffer" then return end
            if not securityTag or typeof(securityTag) ~= "buffer" or Compression(securityTag, "decompress") ~= self.securityTag then return end

            local DecompressedData = Compression(data, "decompress")
            
            if typeof(DecompressedData) == "table" then
                for i: any, v: buffer in pairs(DecompressedData :: any) do
                    DecompressedData[i] = Compression(v, "decompress")
                end
            end

            callback(DecompressedData)
        end
    )
end

--[[
    @usage Register a server callback for when an event is fired.

    @param self Packet<any, any>
    @param callback ClientRemoteEventCallbackType

    @return void
]]
local function onServerEventCallback<S>(self: Packet<any, any>, callback: ServerRemoteEventCallbackType<S>)
    if isClient then return end

    local remoteEvent = script:FindFirstChild(self.packetId) :: RemoteEvent
    if not remoteEvent then return end

    self.serverConnection
    = remoteEvent.OnServerEvent:Connect(
        function(player: Player, data: buffer, securityTag: buffer)
            if typeof(data) ~= "buffer" then return end
            if not securityTag or typeof(securityTag) ~= "buffer" or Compression(securityTag, "decompress") ~= self.securityTag then return end

            local DecompressedData = Compression(data, "decompress")
            
            if typeof(DecompressedData) == "table" then
                for i: any, v: buffer in pairs(DecompressedData :: any) do
                    DecompressedData[i] = Compression(v, "decompress")
                end
            end

            callback(player, DecompressedData)
        end
    )
end

--[[
    @usage Register a client callback for when a function is invoked.

    @param self Packet<any, any>
    @param callback ClientRemoteFunctionCallbackType

    @return void
]]
local function onClientInvokeCallback<C, S>(self: Packet<any, any>, callback: ClientRemoteFunctionCallbackType<C, S>)
    if not isClient then return end

    (self.clientRemote :: RemoteFunction).OnClientInvoke
    = function(data: buffer, securityTag: buffer): S
        if typeof(data) ~= "buffer" then return nil end

        if not securityTag or typeof(securityTag) ~= "buffer" or Compression(securityTag, "decompress") ~= self.securityTag then
            return nil
        end

        local DecompressedData = Compression(data, "decompress")

        if typeof(DecompressedData) == "table" then
            for i: any, v: buffer in pairs(DecompressedData :: any) do
                DecompressedData[i] = Compression(v, "decompress")
            end
        end

        return callback(DecompressedData)
    end
end

--[[
    @usage Register a server callback for when a function is invoked.

    @param self Packet<any, any>
    @param callback ClientRemoteFunctionCallbackType

    @return void
]]
local function onServerInvokeCallback<C, S>(self: Packet<any, any>, callback: ServerRemoteFunctionCallbackType<C, S>)
    if isClient then return end

    local remoteFunction = script:FindFirstChild(self.packetId) :: RemoteFunction
    if not remoteFunction then return end

    remoteFunction.OnServerInvoke
    = function(player: Player, data: buffer, securityTag: buffer): C
        if typeof(data) ~= "buffer" then return nil end
        
        if not securityTag or typeof(securityTag) ~= "buffer" or Compression(securityTag, "decompress") ~= self.securityTag then
            return nil
        end

        local DecompressedData = Compression(data, "decompress")

        if typeof(DecompressedData) == "table" then
            for i: any, v: buffer in pairs(DecompressedData :: any) do
                DecompressedData[i] = Compression(v, "decompress")
            end
        end

        return callback(player, DecompressedData)
    end
end
--[[ @end_section Callback Functions ]]


--[[
    @usage Disconnect all connections to the packet.

    @param self Packet<any, any>

    @return void
]]
local function disconnectAllCallback(self: Packet<any, any>)
    if self.serverConnection then self.serverConnection:Disconnect(); self.serverConnection = nil end
    if self.clientConnection then self.clientConnection:Disconnect(); self.clientConnection = nil end

    -- Disconnect the remote functions.
    do
        local clientRemoteFunction = script:FindFirstChild(self.packetId) :: RemoteFunction
        local serverRemoteFunction = script:FindFirstChild(self.packetId) :: RemoteFunction

        if clientRemoteFunction then clientRemoteFunction.OnClientInvoke = nil :: any end
        if serverRemoteFunction then serverRemoteFunction.OnServerInvoke = nil :: any end
    end
end


--[[ @section Constructor ]]
--[[
    @usage Create a new packet.

    @generic C Client argument.
    @generic S Server argument.

    @param packetId string
    @param type "Event" | "Function"
    @param PacketDetails { clientType: C, serverType: S }

    @return Packet<C, S>
]]
local function constructorCallback<C, S>
(
    packetId: string,
    type: "Event" | "Function",
    PacketDetails: { clientType: C, serverType: S, }
): Packet<C, S>
    if CachedPackets[packetId] then return CachedPackets[packetId] end

    local NewPacket
    = setmetatable({ packetId = packetId, securityTag = StringToHex.convert(packetId) }, 
        {
            __index
            = {
                fireClient = fireClientCallback,
                fireAllClients = fireAllClientsCallback,
                fireServer = fireServerCallback,

                invokeClient = invokeClientCallback,
                invokeServer = invokeServerCallback,

                onClientEvent = onClientEventCallback,
                onServerEvent = onServerEventCallback,

                onClientInvoke = onClientInvokeCallback,
                onServerInvoke = onServerInvokeCallback,

                disconnectAll = disconnectAllCallback
            }
        }
    ) :: Packet<C, S>;

    (CachedPackets :: { [string]: Packet<C, S> })[packetId] = NewPacket

    local typeRemote = if type == "Event" then Instance.new("RemoteEvent") else Instance.new("RemoteFunction")
    local foundRemote = script:FindFirstChild(packetId)
    
    if not foundRemote and not isClient then
        typeRemote.Name = packetId
        typeRemote.Parent = script
    elseif not foundRemote and isClient then
        repeat task.wait() until script:FindFirstChild(packetId)
        foundRemote = script:FindFirstChild(packetId) :: Instance
    end
    
    if isClient and foundRemote then NewPacket.clientRemote = foundRemote :: any end
    local remote: RemoteEvent | RemoteFunction = if isClient then foundRemote :: any else if foundRemote then foundRemote :: any else typeRemote

    task.spawn(
        function()
            if not isClient then return end

            while true do
                if not CachedPackets[packetId] then break end; task.wait()

                local newId = HttpService:GenerateGUID(false)
                if remote then (remote :: Instance).Name = newId end
            end
        end
    )

    return NewPacket
end

return constructorCallback
--[[ @end_section Constructor ]]