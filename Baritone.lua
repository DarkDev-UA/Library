local Baritone = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local IsMobile = (function()
    local ok, platform = pcall(function() return UserInputService:GetPlatform() end)
    if ok then
        return platform == Enum.Platform.Android or platform == Enum.Platform.IOS
    end
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end)()

local Theme = {
    Background = Color3.fromRGB(12, 12, 12),   -- основной фон
    Surface = Color3.fromRGB(18, 18, 18),       -- панели / сайдбар
    Border = Color3.fromRGB(120, 15, 35),       -- бордовая обводка
    Accent = Color3.fromRGB(150, 20, 45),       -- акцент (кнопки)
    AccentHover = Color3.fromRGB(180, 25, 55),  -- акцент при hover
    Text = Color3.fromRGB(220, 220, 220),       -- основной текст
    TextDim = Color3.fromRGB(100, 100, 100),    -- приглушённый текст
}


-- Lucide иконки
local Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/DarkDev-UA/Library/refs/heads/main/lucide-roblox.luau"))()

function Baritone.GetIcon(name)
    local ok, asset = pcall(function()
        return Lucide.GetAsset(name, 48)
    end)
    if ok and asset then
        return { Image = asset.Url, ImageRectSize = asset.ImageRectSize, ImageRectOffset = asset.ImageRectOffset }
    end
    return nil
end


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
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 55),
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
    local openDragging, openDragStart, openStartPos, openMoved
    local openLocked = false

    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            openDragging = true
            openMoved = false
            openDragStart = input.Position
            openStartPos = OpenButton.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if openDragging and not openLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - openDragStart
            if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
                openMoved = true
            end
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
    New("UIStroke", { Color = Theme.Border, Thickness = 1.5, Parent = MainFrame })

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
        Text = title,
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
        if openMoved then return end
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Диалог закрытия
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function showDialog()
        dialogOpen = true
        dragging = false

        Overlay.BackgroundTransparency = 0.99  -- не 1, иначе не перехватывает клики
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
        local tabIcon = tabInfo.Icon and Baritone.GetIcon(tabInfo.Icon)
        local Tab = { Name = tabName, Groups = {} }

        -- Кнопка таба в сайдбаре
        local TabBtn = New("TextButton", {
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Text = "",
            ZIndex = 3,
            LayoutOrder = #Window.Tabs + 1,
            Parent = TabList,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabBtn })

        -- Внутренний контейнер: иконка + текст горизонтально
        local TabInner = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 3,
            Parent = TabBtn,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = TabInner,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 6),
            Parent = TabInner,
        })

        -- Иконка таба
        local TabIconLabel = nil
        if tabIcon then
            TabIconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(16, 16),
                Image = tabIcon.Image,
                ImageRectSize = tabIcon.ImageRectSize,
                ImageRectOffset = tabIcon.ImageRectOffset,
                ImageColor3 = Theme.TextDim,
                LayoutOrder = 1,
                ZIndex = 4,
                Parent = TabInner,
            })
        end

        -- Текст таба
        local TabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, tabIcon and -22 or 0, 1, 0),
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 4,
            Parent = TabInner,
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
            ScrollBarImageColor3 = Theme.Accent,
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
            for _, t in pairs(Window.Tabs) do
                t._container.Visible = false
                TweenService:Create(t._btn, tweenInfo, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(t._label, tweenInfo, { TextColor3 = Theme.TextDim }):Play()
                if t._icon then
                    TweenService:Create(t._icon, tweenInfo, { ImageColor3 = Theme.TextDim }):Play()
                end
            end
            TabContainer.Visible = true
            TweenService:Create(TabBtn, tweenInfo, { BackgroundTransparency = 0 }):Play()
            TweenService:Create(TabLabel, tweenInfo, { TextColor3 = Theme.Text }):Play()
            if TabIconLabel then
                TweenService:Create(TabIconLabel, tweenInfo, { ImageColor3 = Theme.Text }):Play()
            end
            Window.ActiveTab = Tab
        end

        TabBtn.MouseButton1Click:Connect(function()
            if dialogOpen then return end
            activateTab()
        end)

        Tab._btn = TabBtn
        Tab._label = TabLabel
        Tab._icon = TabIconLabel
        Tab._container = TabContainer

        table.insert(Window.Tabs, Tab)

        -- Первый таб активируется автоматически
        if #Window.Tabs == 1 then
            activateTab()
        end

        return Tab
    end

    -- EditOpenButton
    function Baritone:EditOpenButton(opts)
        opts = opts or {}

        -- Текст
        if opts.Text ~= nil then
            OpenButton.Text = tostring(opts.Text)
        end

        -- Размер (лимит: мин 60x24, макс 300x60)
        if opts.Size ~= nil then
            local w = math.clamp(opts.Size.X or 120, 60, 300)
            local h = math.clamp(opts.Size.Y or 34, 24, 60)
            OpenButton.Size = UDim2.fromOffset(w, h)
        end

        -- OnlyMobile: скрыть кнопку если не мобила
        if opts.OnlyMobile ~= nil then
            if opts.OnlyMobile and not IsMobile then
                OpenButton.Visible = false
            else
                OpenButton.Visible = true
            end
        end

        -- Locked: запретить двигать
        if opts.Locked ~= nil then
            openLocked = opts.Locked
        end
    end

    return Window
end

return Baritone
