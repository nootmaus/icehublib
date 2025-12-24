local MacLib = {
    Options = {},
    Folder = "IceLib", -- Переименовал папку
    GetService = function(service)
        return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
    end
}

--// Services
local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local HttpService = MacLib.GetService("HttpService")
local UserInputService = MacLib.GetService("UserInputService")
local Players = MacLib.GetService("Players")
local CoreGui = MacLib.GetService("CoreGui")

--// Variables
local LocalPlayer = Players.LocalPlayer

--// Ice Theme Palette (White/Monochrome)
local THEME = {
    Background    = Color3.fromRGB(16, 20, 24),       -- Немного темнее для контраста с белым
    CardGrad1     = Color3.fromRGB(20, 25, 30),
    CardGrad2     = Color3.fromRGB(35, 40, 45),
    CardGrad3     = Color3.fromRGB(80, 80, 80),       -- Градиент теперь серый, а не синий
    StrokeGlow    = Color3.fromRGB(255, 255, 255),    -- Свечение белое
    StrokeMain    = Color3.fromRGB(200, 200, 200),    -- Обводка светло-серая/белая
    Surface       = Color3.fromRGB(30, 35, 40),
    SurfaceDark   = Color3.fromRGB(25, 28, 32),
    Accent        = Color3.fromRGB(255, 255, 255),    -- Акцент полностью белый
    Text          = Color3.fromRGB(241, 245, 249),
    TextMuted     = Color3.fromRGB(148, 163, 184),
    Error         = Color3.fromRGB(239, 68, 68),
    FontBold      = Enum.Font.GothamBold,
    FontSemi      = Enum.Font.GothamMedium,
    FontNormal    = Enum.Font.Gotham,
}
local GLOBAL_FADE = 0.1
local IconList

--// IO_SAVE stub
do
    local ENV = (getgenv and getgenv()) or _G
    if type(ENV.IO_SAVE) ~= "function" then
        ENV.IO_SAVE = function(_) end
    end
end

--// Helper Functions
local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.Name = "IceLibUI" -- Переименовал GUI
    newGui.ScreenInsets = Enum.ScreenInsets.None
    newGui.ResetOnSpawn = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder = 10000

    local parent = RunService:IsStudio()
        and LocalPlayer:FindFirstChild("PlayerGui")
        or (gethui and gethui())
        or CoreGui

    newGui.Parent = parent
    return newGui
end

local function Tween(instance, info, props)
    if not instance then return end
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

-- Gradient Card Style Helper
local function AddCardStyle(frame, cornerRadius)
    frame.BackgroundColor3 = THEME.Background
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, cornerRadius or 20)

    local grad = Instance.new("UIGradient", frame)
    grad.Rotation = 35
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, THEME.CardGrad1),
        ColorSequenceKeypoint.new(0.55, THEME.CardGrad2),
        ColorSequenceKeypoint.new(1.00, THEME.CardGrad3),
    })

    local strokeGlow = Instance.new("UIStroke", frame)
    strokeGlow.Thickness = 3
    strokeGlow.Transparency = 0.85 -- Чуть прозрачнее, так как белый очень яркий
    strokeGlow.Color = THEME.StrokeGlow
    strokeGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local strokeMain = Instance.new("UIStroke", frame)
    strokeMain.Thickness = 1
    strokeMain.Transparency = 0.5
    strokeMain.Color = THEME.StrokeMain
    strokeMain.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    return strokeMain
end

-- Icon Loader
local function gl(i)
    if not IconList then
        pcall(function()
            IconList = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dummyrme/Library/refs/heads/main/Icon.lua'))()
        end)
    end

    if IconList and IconList.Icons and IconList.Icons[i] then
        local iconData = IconList.Icons[i]
        local spriteSheet = IconList.Spritesheets[tostring(iconData.Image)]
        return {
            Image = spriteSheet,
            ImageRectSize = iconData.ImageRectSize,
            ImageRectPosition = iconData.ImageRectPosition
        }
    end

    return {
        Image = "rbxassetid://" .. tostring(i):gsub("rbxassetid://", ""),
        ImageRectSize = Vector2.new(0, 0),
        ImageRectPosition = Vector2.new(0, 0)
    }
end

--// Config System Parsers
local ClassParser = {
    ["Toggle"] = {
        Save = function(Flag, data)
            return { type = "Toggle", flag = Flag, state = data.Value }
        end,
        Load = function(Flag, data)
            if MacLib.Options[Flag] and data.state ~= nil then
                MacLib.Options[Flag]:Set(data.state)
            end
        end
    },
    ["Slider"] = {
        Save = function(Flag, data)
            return { type = "Slider", flag = Flag, value = data.Value }
        end,
        Load = function(Flag, data)
            if MacLib.Options[Flag] and data.value then
                MacLib.Options[Flag]:Set(data.value)
            end
        end
    },
    ["Input"] = {
        Save = function(Flag, data)
            return { type = "Input", flag = Flag, text = data.Value }
        end,
        Load = function(Flag, data)
            if MacLib.Options[Flag] and data.text then
                MacLib.Options[Flag]:Set(data.text)
            end
        end
    },
    ["Dropdown"] = {
        Save = function(Flag, data)
            return { type = "Dropdown", flag = Flag, value = data.Value }
        end,
        Load = function(Flag, data)
            if MacLib.Options[Flag] and data.value then
                MacLib.Options[Flag]:Set(data.value)
            end
        end
    }
}

--// Library Functions
function MacLib:Window(Settings)
    local WindowFunctions = { Settings = Settings }
    local macLib = GetGui()

    -- Notification Holder
    local notifications = Instance.new("Frame")
    notifications.Name = "Notifications"
    notifications.BackgroundTransparency = 1
    notifications.Size = UDim2.new(0, 300, 1, -20)
    notifications.Position = UDim2.new(1, -320, 0, 10)
    notifications.AnchorPoint = Vector2.new(0, 0)
    notifications.Parent = macLib
    notifications.ZIndex = 100

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 10)
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.Parent = notifications

    -- Main Base
    local requestedSize = Settings.Size or UDim2.fromOffset(700, 450)
    local baseWidthOffset = requestedSize.X.Offset
    local baseHeightOffset = requestedSize.Y.Offset

    if requestedSize.X.Scale == 0 and baseWidthOffset > 0 then
        baseWidthOffset = math.floor(baseWidthOffset * 0.9)
    end
    if requestedSize.Y.Scale == 0 and baseHeightOffset > 0 then
        baseHeightOffset = math.floor(baseHeightOffset * 0.85)
    end

    local fullSize = UDim2.new(
        requestedSize.X.Scale,
        baseWidthOffset,
        requestedSize.Y.Scale,
        baseHeightOffset
    )

    local base = Instance.new("Frame")
    base.Name = "MainBase"
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = fullSize
    base.Parent = macLib
    base.ClipsDescendants = false

    AddCardStyle(base, 20)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            dragStart = input.Position
            startPos = base.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    base.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(base, TweenInfo.new(0.05), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            })
        end
    end)

    base.Size = UDim2.new(0, 0, 0, 0)
    base.Visible = true
    Tween(base, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = fullSize
    })

    -- Show/Hide GUI
    local guiOpen = true
    local function ShowWindow()
        if guiOpen then return end
        guiOpen = true
        base.Visible = true
        Tween(base, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = fullSize
        })
    end

    local function HideWindow()
        if not guiOpen then return end
        guiOpen = false
        Tween(base, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        task.delay(0.26, function()
            if not guiOpen then
                base.Visible = false
            end
        end)
    end

    WindowFunctions.Show = ShowWindow
    WindowFunctions.Hide = HideWindow
    function WindowFunctions:Toggle()
        if guiOpen then HideWindow() else ShowWindow() end
    end

    -- TopBar
    local topBarHeight = 32
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Parent = base
    topBar.BackgroundColor3 = THEME.SurfaceDark
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, -14, 0, topBarHeight)
    topBar.Position = UDim2.new(0, 7, 0, 7)

    local topBarCorner = Instance.new("UICorner", topBar)
    topBarCorner.CornerRadius = UDim.new(0, 12)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = topBar
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 16, 0, 0)
    titleLbl.Size = UDim2.new(1, -80, 1, 0)
    titleLbl.Font = THEME.FontBold
    titleLbl.Text = Settings.Title or "Ice Interface"
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = THEME.Text

    local titleGrad = Instance.new("UIGradient", titleLbl)
    -- Изменил градиент на бело-серый
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(200, 200, 200)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150)),
    })

    -- Close Button
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundColor3 = THEME.Surface
    closeBtn.Text = "X"
    closeBtn.Font = THEME.FontBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = THEME.Error
    closeBtn.AutoButtonColor = true

    local closeCorn = Instance.new("UICorner", closeBtn)
    closeCorn.CornerRadius = UDim.new(0, 8)
    local closeStroke = Instance.new("UIStroke", closeBtn)
    closeStroke.Color = THEME.StrokeMain
    closeStroke.Transparency = 0.7
    closeStroke.Thickness = 1

    closeBtn.MouseButton1Click:Connect(function()
        HideWindow()
        if WindowFunctions.onUnloadCallback then
            WindowFunctions.onUnloadCallback()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.LeftControl then
            WindowFunctions:Toggle()
        end
    end)

    -- Content Area
    local contentArea = Instance.new("Frame", base)
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 10, 0, 7 + topBarHeight + 6)
    contentArea.Size = UDim2.new(1, -20, 1, -(topBarHeight + 18))

    -- Sidebar width
    local sidebarWidth = 105
    
    local sideBar = Instance.new("ScrollingFrame", contentArea)
    sideBar.Size = UDim2.new(0, sidebarWidth, 1, 0)
    sideBar.BackgroundTransparency = 1
    sideBar.ScrollBarThickness = 2
    sideBar.BorderSizePixel = 0
    sideBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local sideList = Instance.new("UIListLayout", sideBar)
    sideList.Padding = UDim.new(0, 6)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder

    local sep = Instance.new("Frame", contentArea)
    sep.Size = UDim2.new(0, 1, 1, 0)
    sep.Position = UDim2.new(0, sidebarWidth + 10, 0, 0)
    sep.BackgroundColor3 = THEME.StrokeMain
    sep.BackgroundTransparency = 0.8
    sep.BorderSizePixel = 0

    local pages = Instance.new("Frame", contentArea)
    pages.Size = UDim2.new(1, -(sidebarWidth + 20), 1, 0)
    pages.Position = UDim2.new(0, sidebarWidth + 20, 0, 0)
    pages.BackgroundTransparency = 1
    pages.ClipsDescendants = true

    local currentTab = nil
    local tabButtons = {}

    --// Tab System
    function WindowFunctions:TabGroup()
        local GroupFuncs = {}

        function GroupFuncs:Tab(TabSettings)
            local TabFuncs = {}

            -- Tab Button
            local tabBtn = Instance.new("TextButton", sideBar)
            tabBtn.Size = UDim2.new(1, -4, 0, 32)
            tabBtn.BackgroundColor3 = THEME.Surface
            tabBtn.BackgroundTransparency = 1
            tabBtn.Text = ""
            tabBtn.AutoButtonColor = false

            local tabCorner = Instance.new("UICorner", tabBtn)
            tabCorner.CornerRadius = UDim.new(0, 10)

            local tabStroke = Instance.new("UIStroke", tabBtn)
            tabStroke.Transparency = 1
            tabStroke.Color = THEME.Accent
            tabStroke.Thickness = 1

            local selectBar = Instance.new("Frame", tabBtn)
            selectBar.Size = UDim2.new(0, 3, 1, -6)
            selectBar.Position = UDim2.new(0, 1, 0, 3)
            selectBar.BackgroundColor3 = THEME.Accent
            selectBar.BorderSizePixel = 0
            selectBar.BackgroundTransparency = 1

            local tabGrad = Instance.new("UIGradient", tabBtn)
            tabGrad.Rotation = 35
            tabGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, THEME.CardGrad1),
                ColorSequenceKeypoint.new(0.55, THEME.CardGrad2),
                ColorSequenceKeypoint.new(1.00, THEME.CardGrad3),
            })
            tabGrad.Enabled = false

            local tabIcon = Instance.new("ImageLabel", tabBtn)
            tabIcon.Size = UDim2.fromOffset(18, 18)
            tabIcon.Position = UDim2.new(0, 8, 0.5, -9)
            tabIcon.BackgroundTransparency = 1
            tabIcon.ImageColor3 = THEME.TextMuted

            if TabSettings.Image then
                local idata = gl(TabSettings.Image)
                tabIcon.Image = idata.Image
                tabIcon.ImageRectOffset = idata.ImageRectPosition
                tabIcon.ImageRectSize = idata.ImageRectSize
            end

            local tabTitle = Instance.new("TextLabel", tabBtn)
            tabTitle.BackgroundTransparency = 1
            tabTitle.Position = UDim2.new(0, 30, 0, 0)
            tabTitle.Size = UDim2.new(1, -32, 1, 0)
            tabTitle.Font = THEME.FontBold
            tabTitle.Text = TabSettings.Title or "Tab"
            tabTitle.TextSize = 15 
            tabTitle.TextColor3 = THEME.TextMuted
            tabTitle.TextXAlignment = Enum.TextXAlignment.Left

            local pageFrame = Instance.new("ScrollingFrame", pages)
            pageFrame.Size = UDim2.fromScale(1, 1)
            pageFrame.BackgroundTransparency = 1
            pageFrame.Visible = false
            pageFrame.ScrollBarThickness = 2
            pageFrame.ScrollBarImageColor3 = THEME.Accent
            pageFrame.BorderSizePixel = 0
            pageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            pageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

            local pageList = Instance.new("UIListLayout", pageFrame)
            pageList.Padding = UDim.new(0, 12)
            pageList.SortOrder = Enum.SortOrder.LayoutOrder

            local pagePad = Instance.new("UIPadding", pageFrame)
            pagePad.PaddingLeft = UDim.new(0, 4)
            pagePad.PaddingRight = UDim.new(0, 4)
            pagePad.PaddingTop = UDim.new(0, 4)
            pagePad.PaddingBottom = UDim.new(0, 10)

            local function Activate()
                if currentTab == tabBtn then return end

                for btn, data in pairs(tabButtons) do
                    Tween(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = THEME.Surface,
                        BackgroundTransparency = 1
                    })
                    Tween(data.Stroke, TweenInfo.new(0.2), { Transparency = 1 })
                    Tween(data.Title, TweenInfo.new(0.2), { TextColor3 = THEME.TextMuted })
                    Tween(data.Icon, TweenInfo.new(0.2), { ImageColor3 = THEME.TextMuted })
                    if data.Grad then data.Grad.Enabled = false end
                    if data.Bar then
                        Tween(data.Bar, TweenInfo.new(0.2), {
                            BackgroundTransparency = 1
                        })
                    end
                    data.Page.Visible = false
                end

                currentTab = tabBtn
                pageFrame.Visible = true
                pageFrame.Position = UDim2.new(0, 10, 0, 0)
                Tween(pageFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 0, 0, 0)
                })

                Tween(tabBtn, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                })
                Tween(tabStroke, TweenInfo.new(0.2), { Transparency = 0.4 })
                Tween(tabTitle, TweenInfo.new(0.2), { TextColor3 = THEME.Text })
                Tween(tabIcon, TweenInfo.new(0.2), { ImageColor3 = THEME.Accent })

                tabGrad.Enabled = true
                Tween(selectBar, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                })
            end

            tabBtn.MouseButton1Click:Connect(Activate)
            tabButtons[tabBtn] = {
                Page = pageFrame,
                Title = tabTitle,
                Icon = tabIcon,
                Stroke = tabStroke,
                Grad = tabGrad,
                Bar = selectBar
            }

            if currentTab == nil then Activate() end

            function TabFuncs:Select()
                Activate()
            end

            function TabFuncs:Section(SecSettings)
                local SecFuncs = {}

                local section = Instance.new("Frame", pageFrame)
                section.Size = UDim2.new(1, -2, 0, 0)
                section.AutomaticSize = Enum.AutomaticSize.Y
                section.BackgroundTransparency = 0
                section.ClipsDescendants = true

                AddCardStyle(section, 12)

                local outerPad = Instance.new("UIPadding", section)
                outerPad.PaddingTop = UDim.new(0, 4)
                outerPad.PaddingBottom = UDim.new(0, 4)
                outerPad.PaddingLeft = UDim.new(0, 2)
                outerPad.PaddingRight = UDim.new(0, 2)

                local headerHeight = 24
                local paddingSide = 8

                local headerBtn
                local headerLbl
                local arrow
                local collapsed = false

                if SecSettings.Title then
                    headerBtn = Instance.new("TextButton", section)
                    headerBtn.Size = UDim2.new(1, -paddingSide * 2, 0, headerHeight)
                    headerBtn.Position = UDim2.new(0, paddingSide, 0, 4)
                    headerBtn.BackgroundTransparency = 1
                    headerBtn.Text = ""

                    headerLbl = Instance.new("TextLabel", headerBtn)
                    headerLbl.Text = SecSettings.Title
                    headerLbl.Font = THEME.FontBold
                    headerLbl.TextSize = 16
                    headerLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    headerLbl.Size = UDim2.new(1, -20, 1, 0)
                    headerLbl.BackgroundTransparency = 1
                    headerLbl.TextXAlignment = Enum.TextXAlignment.Left

                    local secGrad = Instance.new("UIGradient", headerLbl)
                    -- Градиент заголовка секции: Белый -> Серый
                    secGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(220, 220, 220)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 180, 180)),
                    })

                    arrow = Instance.new("TextLabel", headerBtn)
                    arrow.Text = "▼"
                    arrow.TextColor3 = THEME.Accent
                    arrow.BackgroundTransparency = 1
                    arrow.Size = UDim2.new(0, 20, 1, 0)
                    arrow.Position = UDim2.new(1, -20, 0, 0)
                    arrow.TextSize = 12
                end

                local contentHolder = Instance.new("Frame", section)
                contentHolder.Name = "ContentHolder"
                contentHolder.BackgroundTransparency = 1
                contentHolder.Position = UDim2.new(0, paddingSide, 0, SecSettings.Title and (8 + headerHeight) or 6)
                contentHolder.Size = UDim2.new(1, -paddingSide * 2, 0, 0)
                contentHolder.AutomaticSize = Enum.AutomaticSize.Y

                local secLayout = Instance.new("UIListLayout", contentHolder)
                secLayout.Padding = UDim.new(0, 8)
                secLayout.SortOrder = Enum.SortOrder.LayoutOrder
                secLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

                local secPad = Instance.new("UIPadding", contentHolder)
                secPad.PaddingBottom = UDim.new(0, 6)

                if headerBtn then
                    headerBtn.MouseButton1Click:Connect(function()
                        collapsed = not collapsed
                        Tween(arrow, TweenInfo.new(0.2), {
                            Rotation = collapsed and -90 or 0
                        })

                        if collapsed then
                            Tween(contentHolder, TweenInfo.new(0.2), {
                                BackgroundTransparency = 1
                            })
                            contentHolder.Visible = false
                        else
                            contentHolder.Visible = true
                            Tween(contentHolder, TweenInfo.new(0.2), {
                                BackgroundTransparency = 1
                            })
                        end
                    end)
                end

                local function MakeElement(height)
                    local el = Instance.new("Frame", contentHolder)
                    el.Size = UDim2.new(1, 0, 0, height or 38)
                    el.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Темнее фон элемента
                    el.BackgroundTransparency = 0.5

                    local elCorn = Instance.new("UICorner", el)
                    elCorn.CornerRadius = UDim.new(0, 8)

                    local elStr = Instance.new("UIStroke", el)
                    elStr.Color = THEME.StrokeMain
                    elStr.Transparency = 0.9
                    elStr.Thickness = 1

                    return el
                end

                local function AddTitle(parent, text)
                    local lbl = Instance.new("TextLabel", parent)
                    lbl.Size = UDim2.new(1, -10, 1, 0)
                    lbl.Position = UDim2.new(0, 10, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = text or "Element"
                    lbl.Font = THEME.FontSemi
                    lbl.TextSize = 14
                    lbl.TextColor3 = THEME.Text
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    return lbl
                end

                -- [BUTTON]
                function SecFuncs:Button(BSettings, Flag)
                    local btnCont = MakeElement(36)
                    btnCont.BackgroundColor3 = THEME.Accent
                    btnCont.BackgroundTransparency = 0.9
                
                    local btn = Instance.new("TextButton", btnCont)
                    btn.Size = UDim2.fromScale(1, 1)
                    btn.BackgroundTransparency = 1
                    btn.Text = BSettings.Title or BSettings.Name or "Button"
                    btn.Font = THEME.FontBold
                    btn.TextColor3 = THEME.Accent
                    btn.TextSize = 14
                    btn.AutoButtonColor = true
                
                    -- đo hold time
                    local pressT = nil
                    btn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch
                        then
                            pressT = tick()
                        end
                    end)
                
                    btn.MouseButton1Click:Connect(function()
                        local hadPress = (pressT ~= nil)
                        local hold = 0
                        if pressT then
                            hold = tick() - pressT
                        end
                        pressT = nil
                
                        -- Callback nhận hold + hadPress
                        if BSettings.Callback then
                            BSettings.Callback(hold, hadPress)
                        end
                
                        Tween(btn, TweenInfo.new(0.1), { TextSize = 12 })
                        task.wait(0.1)
                        Tween(btn, TweenInfo.new(0.1), { TextSize = 14 })
                    end)
                
                    local Funcs = { Class = "Button" }
                    function Funcs:SetTitle(t) btn.Text = t end
                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end



                -- [TOGGLE] – có State cho script cũ
                function SecFuncs:Toggle(TSettings, Flag)
                    local togCont = MakeElement(38)
                    AddTitle(togCont, TSettings.Title or TSettings.Name)
                
                    local togBtn = Instance.new("TextButton", togCont)
                    togBtn.Size = UDim2.fromScale(1, 1)
                    togBtn.BackgroundTransparency = 1
                    togBtn.Text = ""
                
                    -- fallback: nếu GLOBAL_FADE nil thì dùng 0.1
                    local FADE = (type(GLOBAL_FADE) == "number") and GLOBAL_FADE or 0.1
                
                    local switchBg = Instance.new("Frame", togCont)
                    switchBg.Size = UDim2.fromOffset(40, 20)
                    switchBg.Position = UDim2.new(1, -50, 0.5, -10)
                    switchBg.BackgroundColor3 = THEME.Surface
                    switchBg.BackgroundTransparency = FADE
                    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
                
                    local knob = Instance.new("Frame", switchBg)
                    knob.Size = UDim2.fromOffset(16, 16)
                    knob.Position = UDim2.new(0, 2, 0.5, -8)
                    knob.BackgroundColor3 = THEME.Text
                    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
                
                    local toggled = TSettings.Default or false
                    local Funcs = { Class = "Toggle", Value = toggled, State = toggled }
                
                    local function applyVisual(state)
                        if state then
                            Tween(switchBg, TweenInfo.new(0.2), {
                                BackgroundColor3 = THEME.Accent,
                                BackgroundTransparency = 0
                            })
                            -- Чтобы белый кноб был виден на белом фоне (Accent), сделаем кноб темным при включении
                            Tween(knob, TweenInfo.new(0.2), { 
                                Position = UDim2.new(1, -18, 0.5, -8),
                                BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Темный цвет кноба при включении
                            })
                        else
                            Tween(switchBg, TweenInfo.new(0.2), {
                                BackgroundColor3 = THEME.Surface,
                                BackgroundTransparency = FADE
                            })
                            Tween(knob, TweenInfo.new(0.2), { 
                                Position = UDim2.new(0, 2, 0.5, -8),
                                BackgroundColor3 = THEME.Text -- Белый цвет кноба при выключении
                            })
                        end
                    end
                
                    -- không gọi callback khi set Default
                    applyVisual(toggled)
                
                    local function setState(state, fireCallback)
                        state = state and true or false
                        toggled = state
                        Funcs.Value = state
                        Funcs.State = state
                        applyVisual(state)
                        if fireCallback and TSettings.Callback then
                            TSettings.Callback(state)
                        end
                    end
                
                    togBtn.MouseButton1Click:Connect(function()
                        setState(not toggled, true)
                    end)
                
                    function Funcs:Set(v)
                        setState(v, true)
                    end
                    Funcs.UpdateState = Funcs.Set
                
                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end


                -- [SLIDER]
                function SecFuncs:Slider(SSettings, Flag)
                    local slidCont = MakeElement(50)
                    local titleLbl = AddTitle(slidCont, SSettings.Title or SSettings.Name)
                    titleLbl.Size = UDim2.new(1, -10, 0, 25)

                    local valLbl = Instance.new("TextLabel", slidCont)
                    valLbl.Size = UDim2.new(0, 50, 0, 25)
                    valLbl.Position = UDim2.new(1, -60, 0, 0)
                    valLbl.BackgroundTransparency = 1
                    valLbl.Text = tostring(SSettings.Default or SSettings.Minimum)
                    valLbl.TextColor3 = THEME.Accent
                    valLbl.Font = THEME.FontBold
                    valLbl.TextSize = 13
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    local slideBg = Instance.new("Frame", slidCont)
                    slideBg.Size = UDim2.new(0.85, -20, 0, 4)
                    slideBg.Position = UDim2.new(0, 10, 0, 32)
                    slideBg.BackgroundColor3 = THEME.Surface
                    Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)

                    local fill = Instance.new("Frame", slideBg)
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = THEME.Accent
                    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                    local min, max = SSettings.Minimum or 0, SSettings.Maximum or 100
                    local value = SSettings.Default or min
                    local Funcs = { Class = "Slider", Value = value }

                    local function Update(input)
                        local sizeX = slideBg.AbsoluteSize.X
                        local mousePos = (input.Position.X - slideBg.AbsolutePosition.X)
                        local percent = math.clamp(mousePos / sizeX, 0, 1)
                        value = math.floor(min + (max - min) * percent)
                        Funcs.Value = value

                        Tween(fill, TweenInfo.new(0.05), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        })
                        valLbl.Text = tostring(value)
                        if SSettings.Callback then SSettings.Callback(value) end
                    end

                    local percent = (value - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    valLbl.Text = tostring(value)

                    local draggingSlider = false
                    local btn = Instance.new("TextButton", slideBg)
                    btn.Size = UDim2.fromScale(1, 1)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""

                    btn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSlider = true
                            Update(input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSlider = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                            Update(input)
                        end
                    end)

                    function Funcs:Set(v)
                        value = math.clamp(v, min, max)
                        local p = (value - min) / (max - min)
                        Tween(fill, TweenInfo.new(0.2), {
                            Size = UDim2.new(p, 0, 1, 0)
                        })
                        valLbl.Text = tostring(value)
                        if SSettings.Callback then SSettings.Callback(value) end
                    end
                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end

                -- [DROPDOWN]
                function SecFuncs:Dropdown(DSettings, Flag)
                    local dropCont = MakeElement(44)
                    dropCont.ClipsDescendants = true

                    local titleLbl = Instance.new("TextLabel", dropCont)
                    titleLbl.Size = UDim2.new(1, -10, 0, 20)
                    titleLbl.Position = UDim2.new(0, 10, 0, 4)
                    titleLbl.BackgroundTransparency = 1
                    titleLbl.Text = DSettings.Title or DSettings.Name or "Dropdown"
                    titleLbl.Font = THEME.FontSemi
                    titleLbl.TextSize = 14
                    titleLbl.TextColor3 = THEME.Text
                    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

                    local current = DSettings.Default or "..."
                    local Funcs = { Class = "Dropdown", Value = current }

                    local selectedLbl = Instance.new("TextLabel", dropCont)
                    selectedLbl.Size = UDim2.new(0, 110, 0, 20)
                    selectedLbl.Position = UDim2.new(1, -140, 0, 4)
                    selectedLbl.Text = current
                    selectedLbl.Font = THEME.FontBold
                    selectedLbl.TextColor3 = THEME.Text
                    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
                    selectedLbl.BackgroundTransparency = 1
                    selectedLbl.TextSize = 13

                    local arrow = Instance.new("TextLabel", dropCont)
                    arrow.Text = "▼"
                    arrow.Size = UDim2.new(0, 20, 0, 20)
                    arrow.Position = UDim2.new(1, -26, 0, 4)
                    arrow.BackgroundTransparency = 1
                    arrow.TextColor3 = THEME.TextMuted
                    arrow.TextSize = 12

                    local openBtn = Instance.new("TextButton", dropCont)
                    openBtn.Size = UDim2.new(1, 0, 1, 0)
                    openBtn.BackgroundTransparency = 1
                    openBtn.Text = ""

                    local listFrame = Instance.new("Frame", dropCont)
                    listFrame.Size = UDim2.new(1, -10, 0, 0)
                    listFrame.Position = UDim2.new(0, 5, 0, 26)
                    listFrame.BackgroundTransparency = 1
                    listFrame.Visible = false
                    local lLayout = Instance.new("UIListLayout", listFrame)
                    lLayout.Padding = UDim.new(0, 4)

                    local expanded = false

                    local function RefreshList()
                        for _, c in pairs(listFrame:GetChildren()) do
                            if c:IsA("TextButton") then
                                c:Destroy()
                            end
                        end

                        local opts = DSettings.Options or {}
                        for _, opt in ipairs(opts) do
                            local optBtn = Instance.new("TextButton", listFrame)
                            optBtn.Size = UDim2.new(1, 0, 0, 26)
                            optBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                            optBtn.Text = opt
                            optBtn.Font = THEME.FontNormal
                            optBtn.TextColor3 = THEME.Text
                            optBtn.TextSize = 13
                            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)

                            local optStr = Instance.new("UIStroke", optBtn)
                            optStr.Color = THEME.StrokeMain
                            optStr.Transparency = 0.7
                            optStr.Thickness = 1

                            optBtn.MouseButton1Click:Connect(function()
                                current = opt
                                Funcs.Value = opt
                                selectedLbl.Text = opt
                                selectedLbl.TextColor3 = THEME.Text
                                if DSettings.Callback then DSettings.Callback(opt) end
                                expanded = false
                                listFrame.Visible = false
                                Tween(dropCont, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                                    Size = UDim2.new(1, 0, 0, 44)
                                })
                                Tween(arrow, TweenInfo.new(0.25), { Rotation = 0 })
                            end)
                        end
                        listFrame.Size = UDim2.new(1, -10, 0, #opts * 30)
                    end

                    RefreshList()

                    openBtn.MouseButton1Click:Connect(function()
                        expanded = not expanded
                        if expanded then
                            listFrame.Visible = true
                            local extra = listFrame.Size.Y.Offset
                            Tween(dropCont, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                                Size = UDim2.new(1, 0, 0, 44 + extra + 4)
                            })
                            Tween(arrow, TweenInfo.new(0.25), { Rotation = 180 })
                        else
                            listFrame.Visible = false
                            Tween(dropCont, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                                Size = UDim2.new(1, 0, 0, 44)
                            })
                            Tween(arrow, TweenInfo.new(0.25), { Rotation = 0 })
                        end
                    end)

                    function Funcs:Set(v)
                        current = v
                        selectedLbl.Text = v
                        selectedLbl.TextColor3 = THEME.Text
                    end

                    function Funcs:Refresh(list)
                        DSettings.Options = list
                        RefreshList()
                    end

                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end

                -- [INPUT] – chữ đậm, font đẹp hơn
                function SecFuncs:Input(ISettings, Flag)
                    local inpCont = MakeElement(38)
                    AddTitle(inpCont, ISettings.Title or ISettings.Name)

                    local boxBg = Instance.new("Frame", inpCont)
                    boxBg.Size = UDim2.new(0, 60, 0, 26)
                    boxBg.Position = UDim2.new(1, -70, 0.5, -13)
                    boxBg.BackgroundColor3 = THEME.Background
                    Instance.new("UICorner", boxBg).CornerRadius = UDim.new(0, 6)
                    local bStr = Instance.new("UIStroke", boxBg)
                    bStr.Color = THEME.StrokeMain
                    bStr.Transparency = 0.8

                    local box = Instance.new("TextBox", boxBg)
                    box.Size = UDim2.new(1, -10, 1, 0)
                    box.Position = UDim2.new(0, 5, 0, 0)
                    box.BackgroundTransparency = 1
                    box.Text = ISettings.Default or ""
                    box.PlaceholderText = ISettings.Placeholder or "..."
                    box.TextColor3 = THEME.Text
                    box.Font = THEME.FontBold       -- Đậm, rõ
                    box.TextSize = 14               -- To hơn 1 chút
                    box.TextStrokeTransparency = 0.8
                    box.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                    local Funcs = { Class = "Input", Value = box.Text }

                    box.FocusLost:Connect(function()
                        Funcs.Value = box.Text
                        if ISettings.Callback then ISettings.Callback(box.Text) end
                    end)

                    function Funcs:Set(t)
                        box.Text = t
                        Funcs.Value = t
                    end
                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end

                -- [LABEL]
                function SecFuncs:Label(Settings)
                    local lbl = MakeElement(24)
                    lbl.BackgroundTransparency = 1
                    local stroke = lbl:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke:Destroy() end
                    local title = AddTitle(lbl, Settings.Title or Settings.Name)
                    title.Font = THEME.FontNormal
                end

                -- [PARAGRAPH]
                function SecFuncs:Paragraph(Settings)
                    local par = MakeElement(44)
                    par.BackgroundTransparency = 0.25
                    local stroke = par:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        stroke.Transparency = 0.5
                        stroke.Thickness = 1
                    end

                    local title = AddTitle(par, Settings.Title or Settings.Header)
                    title.Font = THEME.FontBold
                    title.TextSize = 14

                    local desc = Instance.new("TextLabel", par)
                    desc.Size = UDim2.new(1, -20, 1, -22)
                    desc.Position = UDim2.new(0, 10, 0, 20)
                    desc.BackgroundTransparency = 1
                    desc.Text = Settings.Desc or Settings.Body or ""
                    desc.TextColor3 = THEME.Text
                    desc.TextSize = 13
                    desc.TextWrapped = true
                    desc.TextXAlignment = Enum.TextXAlignment.Left
                    desc.TextYAlignment = Enum.TextYAlignment.Top
                    desc.Font = THEME.FontSemi
                end

                -- [DIVIDER]
                function SecFuncs:Divider()
                    local div = Instance.new("Frame", contentHolder)
                    div.Size = UDim2.new(1, 0, 0, 1)
                    div.BackgroundColor3 = THEME.StrokeMain
                    div.BackgroundTransparency = 0.8
                    div.BorderSizePixel = 0
                end

                return SecFuncs
            end

            return TabFuncs
        end

        return GroupFuncs
    end

    -- Notification API
    function WindowFunctions:Notify(NSettings)
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 70)
        notif.BackgroundTransparency = 1
        notif.Parent = notifications

        local card = Instance.new("Frame", notif)
        card.Size = UDim2.new(1, 0, 1, 0)
        card.Position = UDim2.new(1, 40, 0, 0)
        card.BackgroundTransparency = 1

        AddCardStyle(card, 12)

        local title = Instance.new("TextLabel", card)
        title.Position = UDim2.new(0, 12, 0, 8)
        title.Size = UDim2.new(1, -24, 0, 20)
        title.BackgroundTransparency = 1
        title.Font = THEME.FontBold
        title.Text = NSettings.Title or "Notification"
        title.TextColor3 = THEME.Accent
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left

        local desc = Instance.new("TextLabel", card)
        desc.Position = UDim2.new(0, 12, 0, 30)
        desc.Size = UDim2.new(1, -24, 0, 32)
        desc.BackgroundTransparency = 1
        desc.Font = THEME.FontNormal
        desc.Text = NSettings.Desc or "Description"
        desc.TextColor3 = THEME.Text
        desc.TextSize = 13
        desc.TextWrapped = true
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top

        Tween(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0
        })

        task.delay(NSettings.Duration or 3, function()
            Tween(card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 40, 0, 0),
                BackgroundTransparency = 1
            })
            task.wait(0.36)
            notif:Destroy()
        end)
    end

    function WindowFunctions:Unload()
        if WindowFunctions.onUnloadCallback then WindowFunctions.onUnloadCallback() end
        macLib:Destroy()
    end

    function WindowFunctions.onUnloaded(callback)
        WindowFunctions.onUnloadCallback = callback
    end

    return WindowFunctions
end

--// Config System
function MacLib:SetFolder(Folder)
    MacLib.Folder = Folder
    if not isfolder(MacLib.Folder) then makefolder(MacLib.Folder) end
    if not isfolder(MacLib.Folder .. "/settings") then makefolder(MacLib.Folder .. "/settings") end
end

function MacLib:SaveConfig(Name)
    if not Name then return false, "No name" end
    local data = {}
    for flag, option in pairs(MacLib.Options) do
        if ClassParser[option.Class] then
            table.insert(data, ClassParser[option.Class].Save(flag, option))
        end
    end
    writefile(MacLib.Folder .. "/settings/" .. Name .. ".json", HttpService:JSONEncode(data))
    return true
end

function MacLib:LoadConfig(Name)
    if not isfile(MacLib.Folder .. "/settings/" .. Name .. ".json") then
        return false, "No file"
    end
    local data = HttpService:JSONDecode(readfile(MacLib.Folder .. "/settings/" .. Name .. ".json"))
    for _, option in pairs(data) do
        if ClassParser[option.type] then
            ClassParser[option.type].Load(option.flag, option)
        end
    end
    return true
end

function MacLib:RefreshConfigList()
    local list = listfiles(MacLib.Folder .. "/settings")
    local out = {}
    for _, file in pairs(list) do
        if file:sub(-5) == ".json" then
            local pos = file:find(".json", 1, true)
            local start = pos
            local char = file:sub(pos, pos)
            while char ~= "/" and char ~= "\\" and char ~= "" do
                pos = pos - 1
                char = file:sub(pos, pos)
            end
            if char == "/" or char == "\\" then
                table.insert(out, file:sub(pos + 1, start - 1))
            end
        end
    end
    return out
end

--// Demo
function MacLib:Demo()
    local Window = MacLib:Window({ Title = "Ice Interface", Size = UDim2.fromOffset(650, 400) })
    local Group = Window:TabGroup()
    local Tab = Group:Tab({ Title = "Main", Image = "rbxassetid://10709791437" })
    local Section = Tab:Section({ Title = "Features" })

    Section:Toggle({ Title = "Auto Farm", Default = false, Callback = function(v) print("Farm:", v) end }, "AutoFarm")
    Section:Slider({ Title = "WalkSpeed", Default = 16, Minimum = 16, Maximum = 100, Callback = function(v) print("Speed:", v) end }, "WalkSpeed")
    Section:Dropdown({ Title = "Target Mode", Options = { "Nearest", "Random" }, Default = "Nearest", Callback = function(v) print("Mode:", v) end }, "TargetMode")
    Section:Input({ Title = "Webhook URL", Default = "", Callback = function(v) print("Webhook:", v) end }, "Webhook")
    Section:Paragraph({ Title = "Info", Desc = "This is a sample paragraph with Ice Finder styling." })
    Section:Button({ Title = "Server Hop", Callback = function() Window:Notify({ Title = "System", Desc = "Hopping..." }) end })

    MacLib:SetFolder("IceLib")
end

return MacLib
