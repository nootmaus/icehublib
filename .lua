local MacLib = {
    Options = {},
    Folder = "iOSConfig",
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

--// iOS / Glass Theme Palette
local THEME = {
    Background    = Color3.fromRGB(0, 0, 0),        -- Абсолютно черный для глубины
    Surface       = Color3.fromRGB(25, 25, 25),     -- Темно-серый для элементов
    Accent        = Color3.fromRGB(0, 122, 255),    -- iOS Blue (классический) или можно поставить серый
    Text          = Color3.fromRGB(255, 255, 255),  -- Белый текст
    TextMuted     = Color3.fromRGB(142, 142, 147),  -- Серый текст (iOS System Gray)
    Stroke        = Color3.fromRGB(255, 255, 255),  -- Белая обводка для стекла
    Error         = Color3.fromRGB(255, 59, 48),    -- iOS Red
    
    -- Прозрачность
    BgTrans       = 0.35, -- Прозрачность основного окна (Стекло)
    SurfTrans     = 0.60, -- Прозрачность кнопок/секций
    StrokeTrans   = 0.92, -- Очень тонкая, едва заметная обводка
    
    FontBold      = Enum.Font.GothamBold,
    FontSemi      = Enum.Font.GothamMedium,
    FontNormal    = Enum.Font.Gotham,
}

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
    newGui.Name = "iOS_Library"
    newGui.ScreenInsets = Enum.ScreenInsets.None
    newGui.ResetOnSpawn = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder = 10000
    newGui.IgnoreGuiInset = true -- Чтобы было на весь экран красиво

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

-- iOS Glass Style Helper
local function AddGlassStyle(frame, cornerRadius)
    frame.BackgroundColor3 = THEME.Surface
    frame.BorderSizePixel = 0
    -- Эффект стекла достигается темным фоном + высокой прозрачностью
    -- + тонкой светлой обводкой

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, cornerRadius or 18)

    -- Тонкая обводка (имитация блика на стекле)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Transparency = THEME.StrokeTrans
    stroke.Color = THEME.Stroke
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    return stroke
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
        Save = function(Flag, data) return { type = "Toggle", flag = Flag, state = data.Value } end,
        Load = function(Flag, data) if MacLib.Options[Flag] and data.state ~= nil then MacLib.Options[Flag]:Set(data.state) end end
    },
    ["Slider"] = {
        Save = function(Flag, data) return { type = "Slider", flag = Flag, value = data.Value } end,
        Load = function(Flag, data) if MacLib.Options[Flag] and data.value then MacLib.Options[Flag]:Set(data.value) end end
    },
    ["Input"] = {
        Save = function(Flag, data) return { type = "Input", flag = Flag, text = data.Value } end,
        Load = function(Flag, data) if MacLib.Options[Flag] and data.text then MacLib.Options[Flag]:Set(data.text) end end
    },
    ["Dropdown"] = {
        Save = function(Flag, data) return { type = "Dropdown", flag = Flag, value = data.Value } end,
        Load = function(Flag, data) if MacLib.Options[Flag] and data.value then MacLib.Options[Flag]:Set(data.value) end end
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
    notifications.Position = UDim2.new(1, -320, 0, 50)
    notifications.AnchorPoint = Vector2.new(0, 0)
    notifications.Parent = macLib
    notifications.ZIndex = 100

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 10)
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notifLayout.Parent = notifications

    -- Main Base (The Glass Window)
    local requestedSize = Settings.Size or UDim2.fromOffset(700, 450)
    local fullSize = UDim2.new(0, requestedSize.X.Offset, 0, requestedSize.Y.Offset)

    local base = Instance.new("Frame")
    base.Name = "MainBase"
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.Size = fullSize
    base.Parent = macLib
    base.ClipsDescendants = false
    base.BackgroundColor3 = THEME.Background
    base.BackgroundTransparency = THEME.BgTrans

    -- Blur Effect imitation (Dark overlay + Stroke)
    AddGlassStyle(base, 24)
    local baseStroke = base:FindFirstChildOfClass("UIStroke")
    if baseStroke then baseStroke.Transparency = 0.85 end -- Чуть более заметная граница окна

    -- Shadow
    local shadow = Instance.new("ImageLabel", base)
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 140, 1, 140)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.4
    shadow.ZIndex = -1
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ScaleType = Enum.ScaleType.Slice

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = base.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    base.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(base, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)

    base.Size = UDim2.new(0, 0, 0, 0)
    base.Visible = true
    Tween(base, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = fullSize })

    -- Show/Hide GUI
    local guiOpen = true
    local function ShowWindow()
        if guiOpen then return end
        guiOpen = true
        base.Visible = true
        Tween(base, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = fullSize, BackgroundTransparency = THEME.BgTrans })
        for _, c in pairs(base:GetDescendants()) do
            if c:IsA("UIStroke") then Tween(c, TweenInfo.new(0.4), {Transparency = THEME.StrokeTrans}) end
            if c:IsA("TextLabel") or c:IsA("TextButton") then Tween(c, TweenInfo.new(0.4), {TextTransparency = 0}) end
        end
    end
    local function HideWindow()
        if not guiOpen then return end
        guiOpen = false
        Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1 })
        for _, c in pairs(base:GetDescendants()) do
            if c:IsA("UIStroke") then Tween(c, TweenInfo.new(0.3), {Transparency = 1}) end
            if c:IsA("TextLabel") or c:IsA("TextButton") then Tween(c, TweenInfo.new(0.3), {TextTransparency = 1}) end
        end
        task.delay(0.3, function() if not guiOpen then base.Visible = false end end)
    end
    WindowFunctions.Toggle = function() if guiOpen then HideWindow() else ShowWindow() end end

    -- Sidebar / Navigation
    local sidebarWidth = 60 -- iOS style: thin icon sidebar or wide list? Let's go wide.
    local expandedSidebar = 180
    
    local sideBar = Instance.new("Frame", base)
    sideBar.Name = "SideBar"
    sideBar.Size = UDim2.new(0, expandedSidebar, 1, -20)
    sideBar.Position = UDim2.new(0, 10, 0, 10)
    sideBar.BackgroundColor3 = THEME.Surface
    sideBar.BackgroundTransparency = 0.9 -- Very transparent
    AddGlassStyle(sideBar, 16) -- Separated glass panel for sidebar

    local titleLbl = Instance.new("TextLabel", sideBar)
    titleLbl.Size = UDim2.new(1, -20, 0, 30)
    titleLbl.Position = UDim2.new(0, 15, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Settings.Title or "Script"
    titleLbl.Font = THEME.FontBold
    titleLbl.TextSize = 20
    titleLbl.TextColor3 = THEME.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local subTitle = Instance.new("TextLabel", sideBar)
    subTitle.Size = UDim2.new(1, -20, 0, 15)
    subTitle.Position = UDim2.new(0, 15, 0, 34)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = Settings.Subtitle or "iOS Config"
    subTitle.Font = THEME.FontNormal
    subTitle.TextSize = 12
    subTitle.TextColor3 = THEME.TextMuted
    subTitle.TextXAlignment = Enum.TextXAlignment.Left

    local tabContainer = Instance.new("ScrollingFrame", sideBar)
    tabContainer.Size = UDim2.new(1, 0, 1, -60)
    tabContainer.Position = UDim2.new(0, 0, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Content Area
    local contentArea = Instance.new("Frame", base)
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -(expandedSidebar + 30), 1, -20)
    contentArea.Position = UDim2.new(0, expandedSidebar + 20, 0, 10)
    contentArea.BackgroundTransparency = 1

    local pagesFolder = Instance.new("Folder", contentArea)
    local currentTab = nil

    --// Tab System
    function WindowFunctions:TabGroup()
        local GroupFuncs = {}
        function GroupFuncs:Tab(TabSettings)
            local TabFuncs = {}

            local tabBtn = Instance.new("TextButton", tabContainer)
            tabBtn.Size = UDim2.new(0.9, 0, 0, 36)
            tabBtn.BackgroundColor3 = THEME.Surface
            tabBtn.BackgroundTransparency = 1
            tabBtn.Text = ""
            tabBtn.AutoButtonColor = false
            
            local tCorner = Instance.new("UICorner", tabBtn)
            tCorner.CornerRadius = UDim.new(0, 10)

            local tIcon = Instance.new("ImageLabel", tabBtn)
            tIcon.Size = UDim2.fromOffset(20, 20)
            tIcon.Position = UDim2.new(0, 10, 0.5, -10)
            tIcon.BackgroundTransparency = 1
            tIcon.ImageColor3 = THEME.TextMuted
            
            if TabSettings.Image then
                local idata = gl(TabSettings.Image)
                tIcon.Image = idata.Image
                tIcon.ImageRectOffset = idata.ImageRectPosition
                tIcon.ImageRectSize = idata.ImageRectSize
            end

            local tTitle = Instance.new("TextLabel", tabBtn)
            tTitle.Size = UDim2.new(1, -40, 1, 0)
            tTitle.Position = UDim2.new(0, 38, 0, 0)
            tTitle.BackgroundTransparency = 1
            tTitle.Text = TabSettings.Title or "Tab"
            tTitle.TextColor3 = THEME.TextMuted
            tTitle.Font = THEME.FontSemi
            tTitle.TextSize = 14
            tTitle.TextXAlignment = Enum.TextXAlignment.Left

            local page = Instance.new("ScrollingFrame", pagesFolder)
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.ScrollBarThickness = 3
            page.ScrollBarImageColor3 = THEME.TextMuted
            page.CanvasSize = UDim2.new(0,0,0,0)
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            
            local pLayout = Instance.new("UIListLayout", page)
            pLayout.Padding = UDim.new(0, 12)
            pLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local pPad = Instance.new("UIPadding", page)
            pPad.PaddingTop = UDim.new(0, 2)
            pPad.PaddingBottom = UDim.new(0, 20)
            pPad.PaddingRight = UDim.new(0, 4)

            local function Activate()
                if currentTab == tabBtn then return end
                -- Deactivate old
                for _, t in pairs(tabContainer:GetChildren()) do
                    if t:IsA("TextButton") then
                        Tween(t, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                        Tween(t:FindFirstChild("TextLabel"), TweenInfo.new(0.2), { TextColor3 = THEME.TextMuted })
                        Tween(t:FindFirstChild("ImageLabel"), TweenInfo.new(0.2), { ImageColor3 = THEME.TextMuted })
                    end
                end
                for _, p in pairs(pagesFolder:GetChildren()) do p.Visible = false end

                -- Activate new
                currentTab = tabBtn
                page.Visible = true
                -- iOS selection style: Slight background highlight
                Tween(tabBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = THEME.Accent }) -- Very faint highlight
                Tween(tTitle, TweenInfo.new(0.2), { TextColor3 = THEME.Text })
                Tween(tIcon, TweenInfo.new(0.2), { ImageColor3 = THEME.Text })
                
                -- Simple fade in for page
                page.CanvasPosition = Vector2.new(0,0)
                page.Position = UDim2.new(0, 0, 0, 10)
                Tween(page, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = UDim2.new(0,0,0,0) })
            end

            tabBtn.MouseButton1Click:Connect(Activate)
            if currentTab == nil then Activate() end

            --// Section System
            function TabFuncs:Section(SecSettings)
                local SecFuncs = {}
                
                -- Section Container (Transparent, just organizes elements)
                local sectionCont = Instance.new("Frame", page)
                sectionCont.Size = UDim2.new(1, 0, 0, 0)
                sectionCont.AutomaticSize = Enum.AutomaticSize.Y
                sectionCont.BackgroundTransparency = 1
                
                if SecSettings.Title then
                    local secTitle = Instance.new("TextLabel", sectionCont)
                    secTitle.Text = string.upper(SecSettings.Title)
                    secTitle.Font = THEME.FontBold
                    secTitle.TextSize = 11
                    secTitle.TextColor3 = THEME.TextMuted
                    secTitle.Size = UDim2.new(1, 0, 0, 20)
                    secTitle.BackgroundTransparency = 1
                    secTitle.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local pad = Instance.new("UIPadding", sectionCont)
                    pad.PaddingTop = UDim.new(0, 24) -- Space for title
                end

                local secLayout = Instance.new("UIListLayout", sectionCont)
                secLayout.Padding = UDim.new(0, 8)
                secLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local function MakeElement(height)
                    local el = Instance.new("Frame", sectionCont)
                    el.Size = UDim2.new(1, 0, 0, height or 42)
                    el.BackgroundColor3 = THEME.Surface
                    el.BackgroundTransparency = THEME.SurfTrans
                    
                    local c = Instance.new("UICorner", el)
                    c.CornerRadius = UDim.new(0, 12)
                    
                    local s = Instance.new("UIStroke", el)
                    s.Color = THEME.Stroke
                    s.Transparency = THEME.StrokeTrans
                    s.Thickness = 1
                    
                    return el
                end

                -- [BUTTON]
                function SecFuncs:Button(BSettings)
                    local btnFr = MakeElement(40)
                    -- iOS Button usually accent color or standard grey
                    -- Let's make it standard grey but highlights on hover
                    
                    local btn = Instance.new("TextButton", btnFr)
                    btn.Size = UDim2.new(1, 0, 1, 0)
                    btn.BackgroundTransparency = 1
                    btn.Text = BSettings.Title or "Button"
                    btn.Font = THEME.FontSemi
                    btn.TextColor3 = THEME.Text
                    btn.TextSize = 14
                    
                    btn.MouseButton1Click:Connect(function()
                        Tween(btnFr, TweenInfo.new(0.1), { BackgroundTransparency = 0.4 }) -- Flash
                        task.wait(0.1)
                        Tween(btnFr, TweenInfo.new(0.3), { BackgroundTransparency = THEME.SurfTrans })
                        if BSettings.Callback then BSettings.Callback() end
                    end)
                end

                -- [TOGGLE]
                function SecFuncs:Toggle(TSettings, Flag)
                    local togFr = MakeElement(42)
                    
                    local title = Instance.new("TextLabel", togFr)
                    title.Size = UDim2.new(1, -60, 1, 0)
                    title.Position = UDim2.new(0, 12, 0, 0)
                    title.BackgroundTransparency = 1
                    title.Text = TSettings.Title or "Toggle"
                    title.Font = THEME.FontSemi
                    title.TextColor3 = THEME.Text
                    title.TextSize = 14
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local switch = Instance.new("Frame", togFr)
                    switch.Size = UDim2.fromOffset(40, 24)
                    switch.Position = UDim2.new(1, -52, 0.5, -12)
                    switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Off state
                    local sCorner = Instance.new("UICorner", switch)
                    sCorner.CornerRadius = UDim.new(1, 0)
                    
                    local knob = Instance.new("Frame", switch)
                    knob.Size = UDim2.fromOffset(20, 20)
                    knob.Position = UDim2.new(0, 2, 0.5, -10)
                    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    local kCorner = Instance.new("UICorner", knob)
                    kCorner.CornerRadius = UDim.new(1, 0)
                    
                    local btn = Instance.new("TextButton", togFr)
                    btn.Size = UDim2.new(1,0,1,0)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""

                    local toggled = TSettings.Default or false
                    local Funcs = { Value = toggled }
                    
                    local function Update(state)
                        toggled = state
                        Funcs.Value = state
                        Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(60, 60, 60) })
                        Tween(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(0, 18, 0.5, -10) or UDim2.new(0, 2, 0.5, -10) })
                        if TSettings.Callback then TSettings.Callback(state) end
                    end
                    
                    Update(toggled)
                    btn.MouseButton1Click:Connect(function() Update(not toggled) end)
                    function Funcs:Set(v) Update(v) end
                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end

                -- [SLIDER]
                function SecFuncs:Slider(SSettings, Flag)
                    local slidFr = MakeElement(56)
                    
                    local title = Instance.new("TextLabel", slidFr)
                    title.Size = UDim2.new(1, -10, 0, 24)
                    title.Position = UDim2.new(0, 12, 0, 2)
                    title.BackgroundTransparency = 1
                    title.Text = SSettings.Title or "Slider"
                    title.Font = THEME.FontSemi
                    title.TextColor3 = THEME.Text
                    title.TextSize = 14
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local valLbl = Instance.new("TextLabel", slidFr)
                    valLbl.Size = UDim2.new(0, 40, 0, 24)
                    valLbl.Position = UDim2.new(1, -52, 0, 2)
                    valLbl.BackgroundTransparency = 1
                    valLbl.Text = tostring(SSettings.Default or 0)
                    valLbl.Font = THEME.FontBold
                    valLbl.TextColor3 = THEME.TextMuted
                    valLbl.TextSize = 13
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    local bgBar = Instance.new("Frame", slidFr)
                    bgBar.Size = UDim2.new(1, -24, 0, 6)
                    bgBar.Position = UDim2.new(0, 12, 0, 36)
                    bgBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)
                    
                    local fill = Instance.new("Frame", bgBar)
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = THEME.Accent
                    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                    local min, max = SSettings.Minimum or 0, SSettings.Maximum or 100
                    local val = SSettings.Default or min
                    local Funcs = { Value = val }

                    local function Set(v)
                        val = math.clamp(v, min, max)
                        Funcs.Value = val
                        valLbl.Text = tostring(math.floor(val))
                        local p = (val - min)/(max - min)
                        Tween(fill, TweenInfo.new(0.1), { Size = UDim2.new(p, 0, 1, 0) })
                        if SSettings.Callback then SSettings.Callback(val) end
                    end
                    
                    Set(val)
                    
                    local btn = Instance.new("TextButton", slidFr)
                    btn.Size = UDim2.new(1, -24, 0, 20)
                    btn.Position = UDim2.new(0, 12, 0, 28)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    
                    local dragging = false
                    btn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
                    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
                            local sizeX = bgBar.AbsoluteSize.X
                            local pos = inp.Position.X - bgBar.AbsolutePosition.X
                            local p = math.clamp(pos/sizeX, 0, 1)
                            Set(min + (max-min)*p)
                        end
                    end)
                    
                    function Funcs:Set(v) Set(v) end
                    if Flag then MacLib.Options[Flag] = Funcs end
                    return Funcs
                end

                -- [LABEL/PARAGRAPH]
                function SecFuncs:Label(Text)
                    local lFr = MakeElement(30)
                    lFr.BackgroundTransparency = 1
                    lFr:FindFirstChild("UIStroke"):Destroy()
                    
                    local t = Instance.new("TextLabel", lFr)
                    t.Size = UDim2.new(1, -24, 1, 0)
                    t.Position = UDim2.new(0, 12, 0, 0)
                    t.BackgroundTransparency = 1
                    t.Text = Text
                    t.Font = THEME.FontNormal
                    t.TextColor3 = THEME.TextMuted
                    t.TextSize = 13
                    t.TextXAlignment = Enum.TextXAlignment.Left
                    t.TextWrapped = true
                end

                return SecFuncs
            end
            return TabFuncs
        end
        return GroupFuncs
    end

    function WindowFunctions:Notify(NSettings)
        local notif = Instance.new("Frame", notifications)
        notif.Size = UDim2.new(1, 0, 0, 50)
        notif.BackgroundTransparency = 1
        
        local card = Instance.new("Frame", notif)
        card.Size = UDim2.new(1, 0, 1, 0)
        card.Position = UDim2.new(1, 20, 0, 0)
        card.BackgroundColor3 = Color3.fromRGB(30,30,30)
        card.BackgroundTransparency = 0.2
        AddGlassStyle(card, 12)
        
        local t = Instance.new("TextLabel", card)
        t.Size = UDim2.new(1, -20, 0, 20)
        t.Position = UDim2.new(0, 10, 0, 5)
        t.BackgroundTransparency = 1
        t.Text = NSettings.Title or "Notify"
        t.Font = THEME.FontBold
        t.TextColor3 = THEME.Text
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        
        local d = Instance.new("TextLabel", card)
        d.Size = UDim2.new(1, -20, 0, 20)
        d.Position = UDim2.new(0, 10, 0, 22)
        d.BackgroundTransparency = 1
        d.Text = NSettings.Desc or ""
        d.Font = THEME.FontNormal
        d.TextColor3 = THEME.TextMuted
        d.TextSize = 12
        d.TextXAlignment = Enum.TextXAlignment.Left
        
        Tween(card, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0,0,0,0) })
        task.delay(3, function()
            Tween(card, TweenInfo.new(0.3), { Position = UDim2.new(1,20,0,0) })
            task.wait(0.3)
            notif:Destroy()
        end)
    end

    return WindowFunctions
end

return MacLib
