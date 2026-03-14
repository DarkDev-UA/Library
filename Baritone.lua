local Baritone = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    Surface = Color3.fromRGB(24, 24, 24),
    Border = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(180, 20, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
}

local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

function Baritone:CreateWindow(info)
    local Window = {}

    local ScreenGui = New("ScreenGui", {
        Name = "BaritoneUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok then ScreenGui.Parent = LocalPlayer.PlayerGui end

    local MainFrame = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(550, 380),
        ZIndex = 1,
        Parent = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = MainFrame })

    -- Кнопка открытия
    local OpenButton = New("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 20, 1, -20),
        Size = UDim2.fromOffset(40, 40),
        Text = "",
        ZIndex = 1,
        Parent = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = OpenButton })

    -- Топ панель
    local TopBar = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 1,
        Parent = MainFrame,
    })

    local MinusButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "-",
        TextColor3 = Theme.TextDim,
        TextSize = 16,
        ZIndex = 1,
        Parent = TopBar,
    })

    local CloseButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 18,
        ZIndex = 1,
        Parent = TopBar,
    })

    -- Затемнение
    local Overlay = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 5,
        Parent = MainFrame,
    })

    -- Диалог
    local Dialog = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        ZIndex = 6,
        Parent = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Dialog })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Dialog })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 15),
        Size = UDim2.new(1, 0, 0, 50),
        Text = "Вы точно хотите закрыть текущее окно?",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextWrapped = true,
        ZIndex = 6,
        Parent = Dialog,
    })

    local CancelBtn = New("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0.05, 0, 1, -10),
        Size = UDim2.new(0.43, 0, 0, 30),
        Text = "Продолжить",
        TextColor3 = Theme.Text,
        TextSize = 13,
        ZIndex = 6,
        Parent = Dialog,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CancelBtn })

    local ConfirmBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0.95, 0, 1, -10),
        Size = UDim2.new(0.43, 0, 0, 30),
        Text = "Закрыть",
        TextColor3 = Theme.Text,
        TextSize = 13,
        ZIndex = 6,
        Parent = Dialog,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ConfirmBtn })

    -- Dragging
    local dragging, dragStart, startPos
    local dialogOpen = false

    MainFrame.InputBegan:Connect(function(input)
        if dialogOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    local openDragging, openDragStart, openStartPos
    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            openDragging = true
            openDragStart = input.Position
            openStartPos = OpenButton.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if openDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - openDragStart
            OpenButton.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            openDragging = false
        end
    end)

    -- Логика кнопок
    OpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenButton.Visible = false
    end)

    MinusButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenButton.Visible = true
    end)

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenBack = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local function showDialog()
        dialogOpen = true
        dragging = false
        local origPos = MainFrame.Position

        Overlay.Visible = true
        TweenService:Create(Overlay, tweenInfo, { BackgroundTransparency = 0.5 }):Play()
        TweenService:Create(MainFrame, tweenInfo, { Position = UDim2.fromScale(0.5, 0.5) }):Play()

        task.wait(0.3)
        Dialog.Visible = true
        Dialog.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(Dialog, tweenBack, { Size = UDim2.fromOffset(280, 120) }):Play()

        local cancelConn, confirmConn
        cancelConn = CancelBtn.MouseButton1Click:Connect(function()
            cancelConn:Disconnect()
            confirmConn:Disconnect()
            TweenService:Create(Dialog, tweenInfo, { Size = UDim2.fromOffset(0, 0) }):Play()
            TweenService:Create(Overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
            task.wait(0.3)
            Dialog.Visible = false
            Overlay.Visible = false
            TweenService:Create(MainFrame, tweenInfo, { Position = origPos }):Play()
            dialogOpen = false
        end)

        confirmConn = ConfirmBtn.MouseButton1Click:Connect(function()
            cancelConn:Disconnect()
            confirmConn:Disconnect()
            ScreenGui:Destroy()
        end)
    end

    CloseButton.MouseButton1Click:Connect(showDialog)
    
    ScreenGui.ClipsDescendants = false

    return Window
end

return Baritone
