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
    info = info or {}
    local title   = info.Title   or "Baritone"
    local subtitle = info.Subtitle or ""

    local Window = { Tabs = {}, ActiveTab = nil }

    -- ScreenGui
    local ScreenGui = New("ScreenGui", {
        Name = "BaritoneUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ScreenInsets = Enum.ScreenInsets.None,
    })
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok then ScreenGui.Parent = LocalPlayer.PlayerGui end

    -- Кнопка открытия
    local OpenButton = New("TextButton", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(120, 34),
        Text = title,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Visible = true,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OpenButton })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = OpenButton })

    -- Драг кнопки открытия
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
            OpenButton.Position = UDim2.new(0, openStartPos.X.Offset + delta.X, 0, openStartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            openDragging = false
        end
    end)

    -- Главный фрейм
    local MainFrame = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(600, 420),
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MainFrame })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = MainFrame })

    -- Топбар
    local TopBar = New("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 2,
        Parent = MainFrame,
    })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = TopBar })

    -- Лого / иконка
    local LogoLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0, 160, 1, 0),
        Text = "✦  " .. title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = TopBar,
    })

    -- Кнопки топбара
    local MinusButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        Text = "−",
        TextColor3 = Theme.TextDim,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 2,
        Parent = TopBar,
    })
    local CloseButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 2,
        Parent = TopBar,
    })

    -- Левая панель (табы)
    local Sidebar = New("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(0, 150, 1, -42),
        ZIndex = 2,
        Parent = MainFrame,
    })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Sidebar })

    local TabList = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        Parent = Sidebar,
    })
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TabList,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = TabList,
    })

    -- Контент зона
    local ContentArea = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(150, 42),
        Size = UDim2.new(1, -150, 1, -42),
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = MainFrame,
    })

    -- Футер
    local Footer = New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 1, 0),
        Size = UDim2.new(1, -150, 0, 22),
        ZIndex = 2,
        Parent = MainFrame,
    })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Footer })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = subtitle ~= "" and subtitle or "baritone ui",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ZIndex = 2,
        Parent = Footer,
    })

    -- Оверлей для диалога
    local Overlay = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 8,
        Parent = MainFrame,
    })

    -- Диалог закрытия
    local Dialog = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(260, 110),
        Visible = false,
        ZIndex = 9,
        Parent = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Dialog })
    New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Dialog })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 12),
        Size = UDim2.new(1, 0, 0, 46),
        Text = "Закрыть текущее окно?",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextWrapped = true,
        ZIndex = 9,
        Parent = Dialog,
    })

    local CancelBtn = New("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0.05, 0, 1, -10),
        Size = UDim2.new(0.43, 0, 0, 28),
        Text = "Продолжить",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        ZIndex = 9,
        Parent = Dialog,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CancelBtn })

    local ConfirmBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0.95, 0, 1, -10),
        Size = UDim2.new(0.43, 0, 0, 28),
        Text = "Закрыть",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        ZIndex = 9,
        Parent = Dialog,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ConfirmBtn })

    -- Драг главного окна (только за топбар)
    local dragging, dragStart, startPos
    local dialogOpen = false

    TopBar.InputBegan:Connect(function(input)
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

    -- Свернуть / развернуть
    MinusButton.MouseButton1Click:Connect(function()
        if dialogOpen then return end
        MainFrame.Visible = false
    end)
    OpenButton.MouseButton1Click:Connect(function()
        if dialogOpen then return end
        local moved = openDragStart and (OpenButton.Position.X.Offset ~= openStartPos.X.Offset or OpenButton.Position.Y.Offset ~= openStartPos.Y.Offset)
        if moved then return end
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Диалог закрытия
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function showDialog()
        dialogOpen = true
        dragging = false

        Overlay.Visible = true
        TweenService:Create(Overlay, tweenInfo, { BackgroundTransparency = 0.55 }):Play()

        Dialog.Visible = true
        Dialog.BackgroundTransparency = 1
        for _, v in pairs(Dialog:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                v.TextTransparency = 1
                if v:IsA("TextButton") then v.BackgroundTransparency = 1 end
            end
        end
        TweenService:Create(Dialog, tweenInfo, { BackgroundTransparency = 0 }):Play()
        for _, v in pairs(Dialog:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                TweenService:Create(v, tweenInfo, { TextTransparency = 0 }):Play()
                if v:IsA("TextButton") then
                    TweenService:Create(v, tweenInfo, { BackgroundTransparency = 0 }):Play()
                end
            end
        end

        local cancelConn, confirmConn
        cancelConn = CancelBtn.MouseButton1Click:Connect(function()
            cancelConn:Disconnect()
            confirmConn:Disconnect()
            TweenService:Create(Overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(Dialog, tweenInfo, { BackgroundTransparency = 1 }):Play()
            for _, v in pairs(Dialog:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    TweenService:Create(v, tweenInfo, { TextTransparency = 1 }):Play()
                    if v:IsA("TextButton") then
                        TweenService:Create(v, tweenInfo, { BackgroundTransparency = 1 }):Play()
                    end
                end
            end
            task.wait(0.25)
            Dialog.Visible = false
            Overlay.Visible = false
            dialogOpen = false
        end)
        confirmConn = ConfirmBtn.MouseButton1Click:Connect(function()
            cancelConn:Disconnect()
            confirmConn:Disconnect()
            ScreenGui:Destroy()
        end)
    end

    CloseButton.MouseButton1Click:Connect(showDialog)

    -- Метод добавления таба
    function Window:AddTab(tabInfo)
        tabInfo = tabInfo or {}
        local tabName = tabInfo.Name or "Tab"
        local Tab = { Name = tabName, Groups = {} }

        -- Кнопка таба в сайдбаре
        local TabBtn = New("TextButton", {
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
            LayoutOrder = #Window.Tabs + 1,
            Parent = TabList,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabBtn })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = TabBtn,
        })

        -- Контейнер контента таба
        local TabContainer = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 1, -22),
            CanvasSize = UDim2.fromScale(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Border,
            Visible = false,
            ZIndex = 2,
            Parent = ContentArea,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabContainer,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = TabContainer,
        })

        local function activateTab()
            -- Скрыть все табы
            for _, t in pairs(Window.Tabs) do
                t._container.Visible = false
                TweenService:Create(t._btn, tweenInfo, { BackgroundTransparency = 1, TextColor3 = Theme.TextDim }):Play()
            end
            TabContainer.Visible = true
            TweenService:Create(TabBtn, tweenInfo, { BackgroundTransparency = 0, TextColor3 = Theme.Text }):Play()
            Window.ActiveTab = Tab
        end

        TabBtn.MouseButton1Click:Connect(function()
            if dialogOpen then return end
            activateTab()
        end)

        Tab._btn = TabBtn
        Tab._container = TabContainer

        table.insert(Window.Tabs, Tab)

        -- Первый таб активируется автоматически
        if #Window.Tabs == 1 then
            activateTab()
        end

        return Tab
    end

    return Window
end

return Baritone
