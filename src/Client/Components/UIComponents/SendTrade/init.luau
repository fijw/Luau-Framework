--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)

local UIComponents = require(script.Components)
local TradeRequestComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.TradeRequest)

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema

type HandledUI = UIUtilitiesLibrary.HandledUI
type HandledTween = TweensLib.HandledTween
--[[ @end_section Types ]]


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui

local CachedPlayerTradingContainers: { [Player]: Frame } = {}
--[[ @end_section Variables ]]


--[[ @section Utility Functions ]]
--[[
    @usage Tweens an instance.

    @param inst GuiObject
    @param timeInput number
    @param type "pos" | "trans"
    @param input number | UDim2

    @return HandledTween
]]
local function tweenInst(inst: GuiObject, timeInput: number, type: "pos" | "trans" | "size", input: number | UDim2): HandledTween
    local HandledTween
    = TweensLib(
        inst,


        timeInput,

        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,

        0,
        false,
        0,


        {
            Position = if type == "pos" then input else nil,
            ImageTransparency = if type == "trans" then input else nil,
            Size = if type == "size" then input else nil
        }
    )

    return HandledTween
end

--[[
    @usage Adds a player trading container to the UI.

    @param plr Player
    @param scrollingFrame ScrollingFrame
    @param defaultPlayerTradingContainer Frame
    @param HandledUI HandledUI

    @return void
]]
local function addPlayerTradingContainer
(
    plr: Player,
    scrollingFrame: ScrollingFrame,
    defaultPlayerTradingContainer: Frame,
    HandledUI: HandledUI
)
    local PlayerTradingContainer = defaultPlayerTradingContainer:Clone()
    PlayerTradingContainer.Name = plr.Name
    PlayerTradingContainer.Parent = scrollingFrame
    PlayerTradingContainer.Visible = true

    local PlrIcon = PlayerTradingContainer:WaitForChild("PlrIcon") :: ImageLabel
    local PlayerNamesContainer = PlayerTradingContainer:WaitForChild("PlayerNamesContainer") :: Frame
    local PlrDisplayText = PlayerNamesContainer:WaitForChild("PlrDisplayText") :: TextLabel
    local PlrNameText = PlayerNamesContainer:WaitForChild("PlrNameText") :: TextLabel
    local SendTradeBtn = PlayerTradingContainer:WaitForChild("SendTradeBtn") :: ImageButton

    PlrDisplayText.Text = plr.DisplayName
    PlrNameText.Text = plr.Name

    CachedPlayerTradingContainers[plr] = PlayerTradingContainer

    HandledUI:handleButtonPress(SendTradeBtn,
        function(pos1: number, pos2: number) TradingGroup.SendTradeRequest:fireServer(plr.UserId) end, true
    )
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    local clonedSendTrade = UIComponents.SendTrade:Clone()
    clonedSendTrade.Parent = PlayerGui

    local containerFrame = clonedSendTrade:WaitForChild("Container") :: Frame
    local searchBox = containerFrame:WaitForChild("SearchBox") :: Frame
    local frameBox = searchBox:WaitForChild("FrameBox") :: ImageLabel
    local textBox = frameBox:WaitForChild("TextBox") :: TextBox
    local closeBtn = containerFrame:WaitForChild("CloseBtn") :: ImageButton
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local scrollingFrame = mainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local uiListLayout = scrollingFrame:WaitForChild("UIListLayout") :: UIListLayout
    local defaultPlayerTradingContainer = scrollingFrame:WaitForChild("PlayerTradingContainer") :: Frame

    local HandledUI = UIUtilitiesLibrary("send_trade", clonedSendTrade)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    -- Adding and removing player trading containers.
    do
        for i: number, plr: Player in ipairs(Players:GetPlayers()) do
            --if plr.Name == localPlayer.Name then continue end
            addPlayerTradingContainer(plr, scrollingFrame, defaultPlayerTradingContainer, HandledUI)
        end

        Players.PlayerAdded:Connect(
            function(player: Player)
                if player.Name == localPlayer.Name then return end
                addPlayerTradingContainer(player, scrollingFrame, defaultPlayerTradingContainer, HandledUI)
            end
        )

        Players.PlayerRemoving:Connect(
            function(player: Player)
                if not CachedPlayerTradingContainers[player] then return end
                CachedPlayerTradingContainers[player]:Destroy()
            end
        )
    end

    -- Networking connections.
    do
        TradingGroup.SendTradeRequest:onClientEvent(
            function(data)
                local TradeRequestHandledUI = UIUtilitiesLibrary("trade_request", TradeRequestComponents().tradeRequest)
                TradeRequestHandledUI:hoverAndToggleSizing(1.15)
                TradeRequestHandledUI:setFocus( { "Screen", "Notification", "AreYouSure", "TradeRequest" } )
                
                TradeRequestComponents().tradeRequestText.Text = `You received a trade request from {data}.<br /><br />Would you like to accept?`

                TradeRequestHandledUI:handleButtonPress(TradeRequestComponents().acceptBtn,
                    function(pos1: number, pos2: number)
                        TradingGroup.AcceptTradeRequest:fireServer()

                        TradeRequestHandledUI:removeFocus({ clonedSendTrade.Name })
                        TradeRequestHandledUI:destroy()
                    end
                )

                TradeRequestHandledUI:handleButtonPress(TradeRequestComponents().declineBtn,
                    function(pos1: number, pos2: number)
                        TradingGroup.DeclineTradeRequest:fireServer()

                        TradeRequestHandledUI:removeFocus({ clonedSendTrade.Name })
                        TradeRequestHandledUI:destroy()
                    end
                )
            end
        )
    end

    -- Animations for closing and opening.
    do
        local originalContainerSize = containerFrame.Size

        HandledUI:subscribeToSetFocus("opening_subscription",
            function(self, NamesKeepingFocus)
                containerFrame.Size = UDim2.new(0, 0, 0, 0)

                tweenInst(
                    containerFrame,
                    
                    0.25,
                    "size",

                    originalContainerSize
                )
            end
        )

        HandledUI:subscribeToRemoveFocus("closing_subscription",
            function(self, NamesToBringBackToFocus)
                tweenInst(
                    containerFrame,
                    
                    0.25,
                    "size",

                    UDim2.new(0, 0, 0, 0)
                ):waitForCompletion()

                textBox.Text = ""
            end
        )
    end

    task.spawn(
        function()
            while true do
                repeat task.wait() until clonedSendTrade.Enabled; task.wait()
                scrollingFrame.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y)
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]