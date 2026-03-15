--[[
    AquaUI Interface Suite
    Ocean Blue / White Theme
    Inspired by Rayfield (SiriusSoftwareLtd)

    Components:
      Window, Tabs, Buttons, Toggles, Sliders,
      Dropdowns, Inputs, Keybinds, Color Pickers,
      Labels, Separators, Notifications, Paragraphs

    Usage:
      local AquaUI = loadstring(game:HttpGet('https://...'))()
      local Window = AquaUI:CreateWindow({ Name = "My Script", Theme = "Ocean" })
      local Tab = Window:CreateTab("Combat", 4483362458)
      Tab:CreateButton({ Name = "Kill All", Callback = function() end })
]]

-- ============================================================
--  SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

-- ============================================================
--  THEME
-- ============================================================
local Themes = {
    Ocean = {
        Background          = Color3.fromRGB(10,  22,  40),
        Topbar              = Color3.fromRGB(13,  33,  68),
        TabBackground       = Color3.fromRGB(8,   18,  33),
        TabSelected         = Color3.fromRGB(0,   180, 220),
        TabSelectedText     = Color3.fromRGB(10,  22,  40),
        TabText             = Color3.fromRGB(160, 200, 220),
        ElementBackground   = Color3.fromRGB(13,  33,  68),
        ElementHover        = Color3.fromRGB(18,  45,  85),
        ElementStroke       = Color3.fromRGB(0,   100, 160),
        TextColor           = Color3.fromRGB(220, 240, 255),
        SubTextColor        = Color3.fromRGB(120, 170, 200),
        PlaceholderColor    = Color3.fromRGB(80,  120, 150),
        Accent              = Color3.fromRGB(0,   212, 255),
        AccentDark          = Color3.fromRGB(0,   140, 180),
        SliderFill          = Color3.fromRGB(0,   212, 255),
        SliderBackground    = Color3.fromRGB(20,  40,  70),
        ToggleOn            = Color3.fromRGB(0,   212, 255),
        ToggleOff           = Color3.fromRGB(40,  60,  90),
        ToggleKnob          = Color3.fromRGB(255, 255, 255),
        DropdownBackground  = Color3.fromRGB(10,  25,  50),
        DropdownSelected    = Color3.fromRGB(0,   60,  100),
        Shadow              = Color3.fromRGB(0,   5,   15),
        Success             = Color3.fromRGB(0,   220, 130),
        Warning             = Color3.fromRGB(255, 184, 0),
        Danger              = Color3.fromRGB(255, 60,  80),
        NotifBackground     = Color3.fromRGB(10,  22,  40),
        ScrollBarColor      = Color3.fromRGB(0,   140, 180),
        BorderColor         = Color3.fromRGB(0,   80,  140),
        White               = Color3.fromRGB(255, 255, 255),
    },
}

-- ============================================================
--  UTILITY
-- ============================================================
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function newInst(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function makeCorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeStroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent
    return s
end

local function makePadding(t, b, l, r, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t)
    p.PaddingBottom = UDim.new(0, b)
    p.PaddingLeft   = UDim.new(0, l)
    p.PaddingRight  = UDim.new(0, r)
    p.Parent        = parent
    return p
end

local function makeListLayout(spacing, fillDir, parent)
    local l = Instance.new("UIListLayout")
    l.Padding             = UDim.new(0, spacing)
    l.FillDirection       = fillDir or Enum.FillDirection.Vertical
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent              = parent
    return l
end

local function ripple(button, theme)
    local rippleFrame = newInst("Frame", {
        Size            = UDim2.new(0, 0, 0, 0),
        Position        = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint     = Vector2.new(0.5, 0.5),
        BackgroundColor3= theme.Accent,
        BackgroundTransparency = 0.7,
        ZIndex          = button.ZIndex + 5,
        Parent          = button,
    })
    makeCorner(999, rippleFrame)
    tween(rippleFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, button.AbsoluteSize.X * 2.5, 0, button.AbsoluteSize.X * 2.5),
        BackgroundTransparency = 1,
    })
    task.delay(0.5, function() rippleFrame:Destroy() end)
end

-- ============================================================
--  MAIN LIBRARY TABLE
-- ============================================================
local AquaUI = {}
AquaUI.__index = AquaUI
AquaUI.Flags   = {}

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
function AquaUI:Notify(options)
    local theme   = Themes.Ocean
    options       = options or {}
    local title   = options.Title   or "Notification"
    local content = options.Content or ""
    local duration= options.Duration or 4
    local ntype   = options.Type    or "Info" -- Info | Success | Warning | Error

    local typeColors = {
        Info    = theme.Accent,
        Success = theme.Success,
        Warning = theme.Warning,
        Error   = theme.Danger,
    }
    local accentColor = typeColors[ntype] or theme.Accent

    -- Container
    local screenGui = CoreGui:FindFirstChild("AquaUI_Notifs")
    if not screenGui then
        screenGui = newInst("ScreenGui", {
            Name            = "AquaUI_Notifs",
            ResetOnSpawn    = false,
            ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
            Parent          = CoreGui,
        })
        local holder = newInst("Frame", {
            Name            = "Holder",
            Size            = UDim2.new(0, 300, 1, 0),
            Position        = UDim2.new(1, -316, 0, 0),
            BackgroundTransparency = 1,
            Parent          = screenGui,
        })
        local layout = Instance.new("UIListLayout")
        layout.Padding             = UDim.new(0, 8)
        layout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
        layout.SortOrder           = Enum.SortOrder.LayoutOrder
        layout.Parent              = holder
        makePadding(0, 16, 0, 0, holder)
    end

    local holder = screenGui:FindFirstChild("Holder")

    local card = newInst("Frame", {
        Size            = UDim2.new(1, 0, 0, 70),
        BackgroundColor3= theme.NotifBackground,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        Parent          = holder,
    })
    makeCorner(10, card)
    makeStroke(accentColor, 1, card)

    -- Accent bar
    newInst("Frame", {
        Size            = UDim2.new(0, 3, 1, 0),
        BackgroundColor3= accentColor,
        BorderSizePixel = 0,
        ZIndex          = 2,
        Parent          = card,
    })

    -- Title
    newInst("TextLabel", {
        Size            = UDim2.new(1, -20, 0, 22),
        Position        = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = theme.TextColor,
        Font            = Enum.Font.GothamBold,
        TextSize        = 13,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 3,
        Parent          = card,
    })

    -- Content
    newInst("TextLabel", {
        Size            = UDim2.new(1, -20, 0, 30),
        Position        = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        Text            = content,
        TextColor3      = theme.SubTextColor,
        Font            = Enum.Font.Gotham,
        TextSize        = 11,
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextWrapped     = true,
        ZIndex          = 3,
        Parent          = card,
    })

    -- Progress bar
    local progBg = newInst("Frame", {
        Size            = UDim2.new(1, 0, 0, 2),
        Position        = UDim2.new(0, 0, 1, -2),
        BackgroundColor3= theme.SliderBackground,
        BorderSizePixel = 0,
        ZIndex          = 4,
        Parent          = card,
    })
    local progFill = newInst("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundColor3= accentColor,
        BorderSizePixel = 0,
        ZIndex          = 5,
        Parent          = progBg,
    })

    -- Slide in
    card.Position = UDim2.new(1, 10, card.Position.Y.Scale, card.Position.Y.Offset)
    tween(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, card.Position.Y.Scale, card.Position.Y.Offset),
    })

    -- Countdown
    tween(progFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0),
    })

    task.delay(duration, function()
        tween(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, card.Position.Y.Scale, card.Position.Y.Offset),
            BackgroundTransparency = 1,
        })
        task.delay(0.3, function() card:Destroy() end)
    end)
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function AquaUI:CreateWindow(options)
    options = options or {}
    local theme       = Themes[options.Theme] or Themes.Ocean
    local windowName  = options.Name         or "AquaUI"
    local keybind     = options.Keybind      or Enum.KeyCode.K
    local minSize     = options.MinimizeKey  or keybind

    -- Root ScreenGui
    local screenGui = newInst("ScreenGui", {
        Name            = "AquaUI_" .. windowName,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        Parent          = CoreGui,
    })

    -- Main frame
    local mainFrame = newInst("Frame", {
        Name            = "MainFrame",
        Size            = UDim2.new(0, 560, 0, 380),
        Position        = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3= theme.Background,
        ClipsDescendants = false,
        Parent          = screenGui,
    })
    makeCorner(12, mainFrame)
    makeStroke(theme.BorderColor, 1, mainFrame)

    -- Shadow
    local shadow = newInst("ImageLabel", {
        Size            = UDim2.new(1, 30, 1, 30),
        Position        = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image           = "rbxassetid://6014261993",
        ImageColor3     = theme.Shadow,
        ImageTransparency = 0.5,
        ScaleType       = Enum.ScaleType.Slice,
        SliceCenter     = Rect.new(49, 49, 450, 450),
        ZIndex          = 0,
        Parent          = mainFrame,
    })

    -- Topbar
    local topbar = newInst("Frame", {
        Name            = "Topbar",
        Size            = UDim2.new(1, 0, 0, 44),
        BackgroundColor3= theme.Topbar,
        ZIndex          = 2,
        Parent          = mainFrame,
    })
    makeCorner(12, topbar)
    -- Cover bottom corners of topbar
    newInst("Frame", {
        Size            = UDim2.new(1, 0, 0, 12),
        Position        = UDim2.new(0, 0, 1, -12),
        BackgroundColor3= theme.Topbar,
        BorderSizePixel = 0,
        ZIndex          = 2,
        Parent          = topbar,
    })

    -- Accent dot
    local dot = newInst("Frame", {
        Size            = UDim2.new(0, 10, 0, 10),
        Position        = UDim2.new(0, 14, 0.5, -5),
        BackgroundColor3= theme.Accent,
        ZIndex          = 3,
        Parent          = topbar,
    })
    makeCorner(99, dot)

    -- Title
    newInst("TextLabel", {
        Size            = UDim2.new(1, -80, 1, 0),
        Position        = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text            = windowName,
        TextColor3      = theme.TextColor,
        Font            = Enum.Font.GothamBold,
        TextSize        = 14,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 3,
        Parent          = topbar,
    })

    -- Close button
    local closeBtn = newInst("TextButton", {
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3= Color3.fromRGB(255, 60, 80),
        BackgroundTransparency = 0.6,
        Text            = "✕",
        TextColor3      = theme.White,
        Font            = Enum.Font.GothamBold,
        TextSize        = 11,
        ZIndex          = 4,
        Parent          = topbar,
    })
    makeCorner(6, closeBtn)

    -- Minimize button
    local minimizeBtn = newInst("TextButton", {
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -70, 0.5, -14),
        BackgroundColor3= theme.Accent,
        BackgroundTransparency = 0.7,
        Text            = "—",
        TextColor3      = theme.Accent,
        Font            = Enum.Font.GothamBold,
        TextSize        = 11,
        ZIndex          = 4,
        Parent          = topbar,
    })
    makeCorner(6, minimizeBtn)

    -- Body (below topbar)
    local body = newInst("Frame", {
        Name            = "Body",
        Size            = UDim2.new(1, 0, 1, -44),
        Position        = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent          = mainFrame,
    })

    -- Tab sidebar
    local tabSidebar = newInst("Frame", {
        Name            = "TabSidebar",
        Size            = UDim2.new(0, 130, 1, 0),
        BackgroundColor3= theme.TabBackground,
        Parent          = body,
    })
    makeListLayout(4, Enum.FillDirection.Vertical, tabSidebar)
    makePadding(8, 8, 6, 6, tabSidebar)

    -- Content area
    local contentArea = newInst("Frame", {
        Name            = "ContentArea",
        Size            = UDim2.new(1, -130, 1, 0),
        Position        = UDim2.new(0, 130, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent          = body,
    })

    -- Divider between sidebar and content
    newInst("Frame", {
        Size            = UDim2.new(0, 1, 1, 0),
        Position        = UDim2.new(0, 130, 0, 0),
        BackgroundColor3= theme.BorderColor,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent          = body,
    })

    -- ── Dragging ──────────────────────────────────────────
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Toggle visibility ─────────────────────────────────
    local visible = true
    local minimized = false

    closeBtn.MouseButton1Click:Connect(function()
        ripple(closeBtn, theme)
        tween(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
        })
        task.delay(0.25, function() screenGui:Destroy() end)
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 560, 0, 44),
            })
        else
            tween(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 560, 0, 380),
            })
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == keybind then
            visible = not visible
            mainFrame.Visible = visible
        end
    end)

    -- ── Window object ─────────────────────────────────────
    local Window = { _theme = theme, _tabs = {}, _activeTab = nil }

    -- ========================================================
    --  CREATE TAB
    -- ========================================================
    function Window:CreateTab(name, icon)
        local theme = self._theme

        -- Tab button
        local tabBtn = newInst("TextButton", {
            Name            = name,
            Size            = UDim2.new(1, 0, 0, 32),
            BackgroundColor3= theme.TabBackground,
            BackgroundTransparency = 0,
            Text            = "",
            AutoButtonColor = false,
            ZIndex          = 3,
            Parent          = tabSidebar,
        })
        makeCorner(7, tabBtn)

        local tabLabel = newInst("TextLabel", {
            Size            = UDim2.new(1, -10, 1, 0),
            Position        = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text            = name,
            TextColor3      = theme.TabText,
            Font            = Enum.Font.GothamSemibold,
            TextSize        = 12,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 4,
            Parent          = tabBtn,
        })

        -- Tab content scroll frame
        local tabContent = newInst("ScrollingFrame", {
            Name            = name .. "_Content",
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.ScrollBarColor,
            Visible         = false,
            Parent          = contentArea,
        })
        makeListLayout(6, Enum.FillDirection.Vertical, tabContent)
        makePadding(10, 10, 10, 10, tabContent)

        -- Auto-size scroll frame
        tabContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            -- automatically handled by CanvasSize
        end)
        local listLayout = tabContent:FindFirstChildWhichIsA("UIListLayout")
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Select tab logic
        local function selectTab()
            for _, t in pairs(Window._tabs) do
                tween(t.btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = theme.TabBackground,
                    BackgroundTransparency = 0,
                })
                t.lbl.TextColor3 = theme.TabText
                t.content.Visible = false
            end
            tween(tabBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.TabSelected,
                BackgroundTransparency = 0,
            })
            tabLabel.TextColor3 = theme.TabSelectedText
            tabContent.Visible  = true
            Window._activeTab   = name
        end

        tabBtn.MouseButton1Click:Connect(selectTab)
        tabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= name then
                tween(tabBtn, TweenInfo.new(0.12), { BackgroundColor3 = theme.ElementHover })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= name then
                tween(tabBtn, TweenInfo.new(0.12), { BackgroundColor3 = theme.TabBackground })
            end
        end)

        local tabEntry = { btn = tabBtn, lbl = tabLabel, content = tabContent }
        table.insert(Window._tabs, tabEntry)

        if #Window._tabs == 1 then selectTab() end

        -- ====================================================
        --  TAB COMPONENTS
        -- ====================================================
        local Tab = {}

        -- Helper: create element container
        local function makeElement(height)
            local el = newInst("Frame", {
                Size            = UDim2.new(1, 0, 0, height),
                BackgroundColor3= theme.ElementBackground,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent          = tabContent,
            })
            makeCorner(8, el)
            makeStroke(theme.ElementStroke, 1, el)
            return el
        end

        -- ── BUTTON ──────────────────────────────────────────
        function Tab:CreateButton(opts)
            opts = opts or {}
            local el = makeElement(40)
            el.BackgroundColor3 = theme.ElementBackground

            local btn = newInst("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 2,
                Parent          = el,
            })

            newInst("TextLabel", {
                Size            = UDim2.new(1, -16, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Button",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            -- Arrow indicator
            newInst("TextLabel", {
                Size            = UDim2.new(0, 20, 1, 0),
                Position        = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text            = "›",
                TextColor3      = theme.Accent,
                Font            = Enum.Font.GothamBold,
                TextSize        = 18,
                ZIndex          = 3,
                Parent          = el,
            })

            btn.MouseEnter:Connect(function()
                tween(el, TweenInfo.new(0.12), { BackgroundColor3 = theme.ElementHover })
            end)
            btn.MouseLeave:Connect(function()
                tween(el, TweenInfo.new(0.12), { BackgroundColor3 = theme.ElementBackground })
            end)
            btn.MouseButton1Click:Connect(function()
                ripple(btn, theme)
                if opts.Callback then
                    task.spawn(opts.Callback)
                end
            end)

            return { SetName = function(_, n) end }
        end

        -- ── TOGGLE ──────────────────────────────────────────
        function Tab:CreateToggle(opts)
            opts = opts or {}
            local flag    = opts.Flag or opts.Name
            local current = opts.CurrentValue or false
            AquaUI.Flags[flag] = current

            local el = makeElement(44)

            newInst("TextLabel", {
                Size            = UDim2.new(1, -60, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Toggle",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            -- Track
            local track = newInst("Frame", {
                Size            = UDim2.new(0, 40, 0, 22),
                Position        = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3= current and theme.ToggleOn or theme.ToggleOff,
                ZIndex          = 3,
                Parent          = el,
            })
            makeCorner(99, track)

            -- Knob
            local knob = newInst("Frame", {
                Size            = UDim2.new(0, 16, 0, 16),
                Position        = current and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3= theme.ToggleKnob,
                ZIndex          = 4,
                Parent          = track,
            })
            makeCorner(99, knob)

            local btn = newInst("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 5,
                Parent          = el,
            })

            btn.MouseButton1Click:Connect(function()
                current = not current
                AquaUI.Flags[flag] = current
                tween(track, TweenInfo.new(0.18), {
                    BackgroundColor3 = current and theme.ToggleOn or theme.ToggleOff,
                })
                tween(knob, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = current and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                })
                if opts.Callback then task.spawn(opts.Callback, current) end
            end)

            local toggleObj = {}
            function toggleObj:Set(val)
                current = val
                AquaUI.Flags[flag] = val
                tween(track, TweenInfo.new(0.18), {
                    BackgroundColor3 = val and theme.ToggleOn or theme.ToggleOff,
                })
                tween(knob, TweenInfo.new(0.18), {
                    Position = val and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                })
            end
            return toggleObj
        end

        -- ── SLIDER ──────────────────────────────────────────
        function Tab:CreateSlider(opts)
            opts = opts or {}
            local flag      = opts.Flag or opts.Name
            local range     = opts.Range or {0, 100}
            local increment = opts.Increment or 1
            local suffix    = opts.Suffix or ""
            local current   = opts.CurrentValue or range[1]
            AquaUI.Flags[flag] = current

            local el = makeElement(54)

            -- Top row
            local nameLabel = newInst("TextLabel", {
                Size            = UDim2.new(0.6, 0, 0, 20),
                Position        = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Slider",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            local valLabel = newInst("TextLabel", {
                Size            = UDim2.new(0.4, -14, 0, 20),
                Position        = UDim2.new(0.6, 0, 0, 8),
                BackgroundTransparency = 1,
                Text            = tostring(current) .. suffix,
                TextColor3      = theme.Accent,
                Font            = Enum.Font.GothamBold,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 3,
                Parent          = el,
            })

            -- Track BG
            local trackBg = newInst("Frame", {
                Size            = UDim2.new(1, -28, 0, 4),
                Position        = UDim2.new(0, 14, 0, 36),
                BackgroundColor3= theme.SliderBackground,
                ZIndex          = 3,
                Parent          = el,
            })
            makeCorner(99, trackBg)

            -- Fill
            local pct = (current - range[1]) / (range[2] - range[1])
            local fill = newInst("Frame", {
                Size            = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3= theme.SliderFill,
                BorderSizePixel = 0,
                ZIndex          = 4,
                Parent          = trackBg,
            })
            makeCorner(99, fill)

            -- Knob
            local sliderKnob = newInst("Frame", {
                Size            = UDim2.new(0, 14, 0, 14),
                Position        = UDim2.new(pct, -7, 0.5, -7),
                BackgroundColor3= theme.White,
                ZIndex          = 5,
                Parent          = trackBg,
            })
            makeCorner(99, sliderKnob)

            -- Drag logic
            local sliding = false
            local hitbox  = newInst("TextButton", {
                Size            = UDim2.new(1, 0, 0, 20),
                Position        = UDim2.new(0, 0, 0, -8),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 6,
                Parent          = trackBg,
            })

            local function updateSlider(inputX)
                local rel  = (inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                rel        = math.clamp(rel, 0, 1)
                local raw  = range[1] + rel * (range[2] - range[1])
                local snapped = math.round(raw / increment) * increment
                snapped    = math.clamp(snapped, range[1], range[2])
                local newPct = (snapped - range[1]) / (range[2] - range[1])
                tween(fill,        TweenInfo.new(0.05), { Size = UDim2.new(newPct, 0, 1, 0) })
                tween(sliderKnob, TweenInfo.new(0.05), { Position = UDim2.new(newPct, -7, 0.5, -7) })
                current            = snapped
                valLabel.Text      = tostring(snapped) .. suffix
                AquaUI.Flags[flag] = snapped
                if opts.Callback then task.spawn(opts.Callback, snapped) end
            end

            hitbox.MouseButton1Down:Connect(function()
                sliding = true
                updateSlider(Mouse.X)
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(Mouse.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            local sliderObj = {}
            function sliderObj:Set(val)
                val = math.clamp(val, range[1], range[2])
                current = val
                AquaUI.Flags[flag] = val
                local np = (val - range[1]) / (range[2] - range[1])
                tween(fill,        TweenInfo.new(0.1), { Size = UDim2.new(np, 0, 1, 0) })
                tween(sliderKnob, TweenInfo.new(0.1), { Position = UDim2.new(np, -7, 0.5, -7) })
                valLabel.Text = tostring(val) .. suffix
            end
            return sliderObj
        end

        -- ── DROPDOWN ────────────────────────────────────────
        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local flag      = opts.Flag or opts.Name
            local options   = opts.Options or {}
            local multi     = opts.MultipleOptions or false
            local current   = opts.CurrentOption or (multi and {} or {options[1]})
            AquaUI.Flags[flag] = current

            local elHeight  = 44
            local el = makeElement(elHeight)

            newInst("TextLabel", {
                Size            = UDim2.new(0.5, 0, 0, elHeight),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Dropdown",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            local selected = newInst("TextLabel", {
                Size            = UDim2.new(0.5, -40, 0, elHeight),
                Position        = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1,
                Text            = type(current) == "table" and table.concat(current, ", ") or tostring(current),
                TextColor3      = theme.Accent,
                Font            = Enum.Font.Gotham,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Right,
                TextTruncate    = Enum.TextTruncate.AtEnd,
                ZIndex          = 3,
                Parent          = el,
            })

            local arrow = newInst("TextLabel", {
                Size            = UDim2.new(0, 20, 0, elHeight),
                Position        = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text            = "▾",
                TextColor3      = theme.SubTextColor,
                Font            = Enum.Font.GothamBold,
                TextSize        = 13,
                ZIndex          = 3,
                Parent          = el,
            })

            -- Dropdown list (appears below)
            local listOpen  = false
            local listFrame = newInst("Frame", {
                Size            = UDim2.new(1, 0, 0, 0),
                Position        = UDim2.new(0, 0, 1, 4),
                BackgroundColor3= theme.DropdownBackground,
                ClipsDescendants = true,
                ZIndex          = 20,
                Visible         = false,
                Parent          = el,
            })
            makeCorner(8, listFrame)
            makeStroke(theme.BorderColor, 1, listFrame)

            local listLayout = makeListLayout(0, Enum.FillDirection.Vertical, listFrame)
            makePadding(4, 4, 0, 0, listFrame)

            local function updateSelected()
                if multi then
                    selected.Text = #current > 0 and table.concat(current, ", ") or "None"
                else
                    selected.Text = current[1] or "None"
                end
                AquaUI.Flags[flag] = current
                if opts.Callback then task.spawn(opts.Callback, current) end
            end

            local function buildList()
                for _, child in pairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, option in ipairs(options) do
                    local isSelected = table.find(current, option) ~= nil
                    local item = newInst("TextButton", {
                        Size            = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3= isSelected and theme.DropdownSelected or Color3.fromRGB(0,0,0),
                        BackgroundTransparency = isSelected and 0 or 1,
                        Text            = "",
                        ZIndex          = 21,
                        Parent          = listFrame,
                    })
                    makeCorner(6, item)
                    newInst("TextLabel", {
                        Size            = UDim2.new(1, -20, 1, 0),
                        Position        = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text            = option,
                        TextColor3      = isSelected and theme.Accent or theme.SubTextColor,
                        Font            = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                        TextSize        = 12,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        ZIndex          = 22,
                        Parent          = item,
                    })
                    item.MouseButton1Click:Connect(function()
                        if multi then
                            local idx = table.find(current, option)
                            if idx then table.remove(current, idx) else table.insert(current, option) end
                        else
                            current = {option}
                            -- close
                            listOpen = false
                            tween(listFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) })
                            tween(el,        TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, elHeight) })
                            task.delay(0.15, function() listFrame.Visible = false end)
                        end
                        updateSelected()
                        buildList()
                    end)
                end
                local totalH = #options * 30 + 8
                if listOpen then
                    tween(listFrame, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, totalH) })
                    tween(el,        TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, elHeight + totalH + 4) })
                end
            end

            local toggleBtn = newInst("TextButton", {
                Size            = UDim2.new(1, 0, 0, elHeight),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 10,
                Parent          = el,
            })

            toggleBtn.MouseButton1Click:Connect(function()
                listOpen = not listOpen
                if listOpen then
                    listFrame.Visible = true
                    buildList()
                    tween(arrow, TweenInfo.new(0.15), { Rotation = 180 })
                else
                    tween(arrow, TweenInfo.new(0.15), { Rotation = 0 })
                    tween(listFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) })
                    tween(el,        TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, elHeight) })
                    task.delay(0.15, function() listFrame.Visible = false end)
                end
            end)

            local dropObj = {}
            function dropObj:Set(val)
                current = type(val) == "table" and val or {val}
                updateSelected()
                buildList()
            end
            function dropObj:Refresh(newOptions)
                options = newOptions
                buildList()
            end
            return dropObj
        end

        -- ── INPUT ───────────────────────────────────────────
        function Tab:CreateInput(opts)
            opts = opts or {}
            local flag = opts.Flag or opts.Name
            AquaUI.Flags[flag] = opts.Default or ""

            local el = makeElement(44)

            newInst("TextLabel", {
                Size            = UDim2.new(0.45, 0, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Input",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            local box = newInst("TextBox", {
                Size            = UDim2.new(0.5, -14, 0, 26),
                Position        = UDim2.new(0.5, 0, 0.5, -13),
                BackgroundColor3= theme.DropdownBackground,
                Text            = opts.Default or "",
                PlaceholderText = opts.Placeholder or "Enter value...",
                TextColor3      = theme.TextColor,
                PlaceholderColor3 = theme.PlaceholderColor,
                Font            = Enum.Font.Gotham,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ClearTextOnFocus = opts.ClearOnFocus ~= false,
                ZIndex          = 4,
                Parent          = el,
            })
            makeCorner(6, box)
            makeStroke(theme.ElementStroke, 1, box)
            makePadding(0, 0, 8, 8, box)

            box:GetPropertyChangedSignal("Text"):Connect(function()
                AquaUI.Flags[flag] = box.Text
            end)
            box.FocusLost:Connect(function(enter)
                if opts.Callback then task.spawn(opts.Callback, box.Text) end
            end)

            local inputObj = {}
            function inputObj:Set(val)
                box.Text = val
                AquaUI.Flags[flag] = val
            end
            return inputObj
        end

        -- ── KEYBIND ─────────────────────────────────────────
        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local flag    = opts.Flag or opts.Name
            local current = opts.CurrentKeybind or Enum.KeyCode.E
            AquaUI.Flags[flag] = current
            local listening = false

            local el = makeElement(44)

            newInst("TextLabel", {
                Size            = UDim2.new(0.6, 0, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Keybind",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            local bindBtn = newInst("TextButton", {
                Size            = UDim2.new(0, 70, 0, 26),
                Position        = UDim2.new(1, -82, 0.5, -13),
                BackgroundColor3= theme.DropdownBackground,
                Text            = tostring(current):gsub("Enum.KeyCode.", ""),
                TextColor3      = theme.Accent,
                Font            = Enum.Font.GothamBold,
                TextSize        = 12,
                ZIndex          = 4,
                Parent          = el,
            })
            makeCorner(6, bindBtn)
            makeStroke(theme.ElementStroke, 1, bindBtn)

            bindBtn.MouseButton1Click:Connect(function()
                listening = true
                bindBtn.Text = "..."
                bindBtn.TextColor3 = theme.Warning
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
                    current            = input.KeyCode
                    AquaUI.Flags[flag] = current
                    listening          = false
                    bindBtn.Text       = tostring(current):gsub("Enum.KeyCode.", "")
                    bindBtn.TextColor3 = theme.Accent
                    if opts.Callback then task.spawn(opts.Callback, current) end
                end
            end)

            local kbObj = {}
            function kbObj:Set(keyCode)
                current = keyCode
                AquaUI.Flags[flag] = keyCode
                bindBtn.Text = tostring(keyCode):gsub("Enum.KeyCode.", "")
            end
            return kbObj
        end

        -- ── COLOR PICKER ────────────────────────────────────
        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local flag    = opts.Flag or opts.Name
            local current = opts.Color or Color3.fromRGB(0, 212, 255)
            AquaUI.Flags[flag] = current

            local el = makeElement(44)

            newInst("TextLabel", {
                Size            = UDim2.new(0.7, 0, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = opts.Name or "Color",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            local preview = newInst("Frame", {
                Size            = UDim2.new(0, 28, 0, 28),
                Position        = UDim2.new(1, -40, 0.5, -14),
                BackgroundColor3= current,
                ZIndex          = 4,
                Parent          = el,
            })
            makeCorner(6, preview)
            makeStroke(theme.White, 1, preview)

            local cpBtn = newInst("TextButton", {
                Size            = UDim2.new(0, 28, 0, 28),
                Position        = UDim2.new(1, -40, 0.5, -14),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 5,
                Parent          = el,
            })

            -- Simple hue picker popup
            local pickerOpen = false
            local picker = newInst("Frame", {
                Size    = UDim2.new(0, 200, 0, 30),
                Position= UDim2.new(1, -210, 1, 4),
                BackgroundColor3 = theme.DropdownBackground,
                Visible = false,
                ZIndex  = 30,
                Parent  = el,
            })
            makeCorner(8, picker)
            makeStroke(theme.BorderColor, 1, picker)
            makePadding(4, 4, 6, 6, picker)

            -- Hue bar
            local hueBar = newInst("ImageLabel", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundColor3= Color3.new(1,1,1),
                Image           = "rbxassetid://698693182",
                ZIndex          = 31,
                Parent          = picker,
            })
            makeCorner(5, hueBar)

            local hueKnob = newInst("Frame", {
                Size            = UDim2.new(0, 8, 1, 0),
                BackgroundColor3= theme.White,
                ZIndex          = 32,
                Parent          = hueBar,
            })
            makeCorner(3, hueKnob)

            local hueBtn = newInst("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 33,
                Parent          = hueBar,
            })

            local hueDragging = false
            hueBtn.MouseButton1Down:Connect(function() hueDragging = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((Mouse.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hueKnob.Position = UDim2.new(rel, -4, 0, 0)
                    current          = Color3.fromHSV(rel, 1, 1)
                    preview.BackgroundColor3 = current
                    AquaUI.Flags[flag]       = current
                    if opts.Callback then task.spawn(opts.Callback, current) end
                end
            end)

            cpBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                picker.Visible = pickerOpen
            end)

            local cpObj = {}
            function cpObj:Set(color)
                current = color
                preview.BackgroundColor3 = color
                AquaUI.Flags[flag]       = color
            end
            return cpObj
        end

        -- ── LABEL ───────────────────────────────────────────
        function Tab:CreateLabel(text)
            local el = makeElement(30)
            el.BackgroundTransparency = 1
            el.BackgroundColor3 = Color3.fromRGB(0,0,0)
            -- override: no background
            for _,c in pairs(el:GetChildren()) do
                if c:IsA("UIStroke") or c:IsA("UICorner") then c:Destroy() end
            end
            el.BackgroundTransparency = 1

            newInst("TextLabel", {
                Size            = UDim2.new(1, -14, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text            = text or "Label",
                TextColor3      = theme.SubTextColor,
                Font            = Enum.Font.Gotham,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
                ZIndex          = 3,
                Parent          = el,
            })

            local lObj = {}
            function lObj:Set(t)
                el:FindFirstChildWhichIsA("TextLabel").Text = t
            end
            return lObj
        end

        -- ── PARAGRAPH ───────────────────────────────────────
        function Tab:CreateParagraph(opts)
            opts = opts or {}
            local el = makeElement(60)

            newInst("TextLabel", {
                Size            = UDim2.new(1, -28, 0, 18),
                Position        = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Text            = opts.Title or "Title",
                TextColor3      = theme.TextColor,
                Font            = Enum.Font.GothamBold,
                TextSize        = 13,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = el,
            })

            newInst("TextLabel", {
                Size            = UDim2.new(1, -28, 0, 30),
                Position        = UDim2.new(0, 14, 0, 26),
                BackgroundTransparency = 1,
                Text            = opts.Content or "",
                TextColor3      = theme.SubTextColor,
                Font            = Enum.Font.Gotham,
                TextSize        = 11,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
                ZIndex          = 3,
                Parent          = el,
            })
        end

        -- ── SEPARATOR ───────────────────────────────────────
        function Tab:CreateSection(name)
            local el = newInst("Frame", {
                Size            = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent          = tabContent,
            })
            -- Line
            newInst("Frame", {
                Size            = UDim2.new(1, 0, 0, 1),
                Position        = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3= theme.BorderColor,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Parent          = el,
            })
            -- Label
            local lbl = newInst("TextLabel", {
                Size            = UDim2.new(0, 0, 1, 0),
                Position        = UDim2.new(0.5, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.X,
                BackgroundColor3= theme.Background,
                Text            = "  " .. (name or "Section") .. "  ",
                TextColor3      = theme.Accent,
                Font            = Enum.Font.GothamBold,
                TextSize        = 10,
                AnchorPoint     = Vector2.new(0.5, 0),
                ZIndex          = 2,
                Parent          = el,
            })
        end

        return Tab
    end

    return Window
end

-- ============================================================
--  DESTROY
-- ============================================================
function AquaUI:Destroy()
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:sub(1, 7) == "AquaUI_" then
            gui:Destroy()
        end
    end
end

return AquaUI

--[[
    =============================================
    QUICK START EXAMPLE
    =============================================

    local AquaUI = loadstring(game:HttpGet(
        'https://raw.githubusercontent.com/YourRepo/AquaUI/main/AquaUI.lua'
    ))()

    local Window = AquaUI:CreateWindow({
        Name    = "My Script v1.0",
        Theme   = "Ocean",
        Keybind = Enum.KeyCode.K,
    })

    local Tab = Window:CreateTab("Combat")

    Tab:CreateSection("Aimbot")

    Tab:CreateToggle({
        Name         = "Silent Aim",
        CurrentValue = false,
        Flag         = "SilentAim",
        Callback     = function(val)
            -- toggle aimbot on/off
        end,
    })

    Tab:CreateSlider({
        Name         = "FOV",
        Range        = {10, 360},
        Increment    = 1,
        Suffix       = "°",
        CurrentValue = 90,
        Flag         = "AimbotFOV",
        Callback     = function(val) end,
    })

    Tab:CreateSection("Utilities")

    Tab:CreateButton({
        Name     = "Kill Nearest Player",
        Callback = function()
            AquaUI:Notify({
                Title   = "Executed",
                Content = "Kill script ran successfully.",
                Type    = "Success",
                Duration = 3,
            })
        end,
    })

    Tab:CreateDropdown({
        Name          = "Target Mode",
        Options       = {"All", "Enemies", "Random", "Nearest"},
        CurrentOption = {"All"},
        Flag          = "TargetMode",
        Callback      = function(opts) end,
    })

    Tab:CreateInput({
        Name        = "Player Name",
        Placeholder = "Enter username...",
        Flag        = "TargetName",
        Callback    = function(text) end,
    })

    Tab:CreateKeybind({
        Name           = "Toggle Fly",
        CurrentKeybind = Enum.KeyCode.F,
        Flag           = "FlyBind",
        Callback       = function(key) end,
    })

    Tab:CreateColorPicker({
        Name     = "ESP Color",
        Color    = Color3.fromRGB(0, 212, 255),
        Flag     = "ESPColor",
        Callback = function(color) end,
    })
]]
