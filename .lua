local MacLib = {
    Options = {},
    Folder = "IceConfig",
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

--// Theme Palette (Glass/Dark Modern)
local THEME = {
    Background    = Color3.fromRGB(10, 10, 10),     -- Очень темный фон
    Surface       = Color3.fromRGB(30, 30, 30),     -- Цвет поверхностей
    Accent        = Color3.fromRGB(0, 122, 255),    -- Акцентный цвет (синий)
    Text          = Color3.fromRGB(255, 255, 255),  -- Белый текст
    TextMuted     = Color3.fromRGB(150, 150, 150),  -- Приглушенный текст
    Stroke        = Color3.fromRGB(255, 255, 255),  -- Цвет обводки
    Error         = Color3.fromRGB(255, 50, 50),    -- Цвет ошибки/закрытия
    
    -- Прозрачность
    BgTrans       = 0.3,  -- Прозрачность основы
    SurfTrans     = 0.7,  -- Прозрачность элементов
    StrokeTrans   = 0.85, -- Прозрачность тонких обводок
    
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
    newGui.Name = "IceLibUI"
    newGui.ScreenInsets = Enum.ScreenInsets.None
    newGui.ResetOnSpawn = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder = 10000
    newGui.IgnoreGuiInset = true

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

-- Helper для внутренних элементов (тонкая обводка)
local function AddInnerStyle(frame, cornerRadius)
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, cornerRadius or 12)

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

--// Library Functions
function MacLib:Window(Settings)
    local WindowFunctions = { Settings = Settings }
    local macLib = GetGui()

    -- Notification Holder
    local notifications = Instance.new("Frame")
    notifications.Name = "Notifications"
    notifications.BackgroundTransparency = 1
    notifications.Size = UDim2.new(0, 300, 1, -20)
    notifications.Position = UDim2.new(1, -320, 0, 30)
    notifications.AnchorPoint = Vector2.new(0, 0)
    notifications.Parent = macLib
    notifications.ZIndex = 105

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 10)
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notifLayout.Parent = notifications

    -- Main Base
    local requestedSize = Settings.Size or UDim2.fromOffset(650, 400)
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

    -- Основная обводка окна (UI Stroke вместо тени)
    Instance.new("UICorner", base).CornerRadius = UDim.new(0, 20)
    local mainStroke = Instance.new("UIStroke", base)
    mainStroke.Thickness = 1.5 -- Чуть толще, чем внутри
    mainStroke.Transparency = 0.6 -- Более заметная
    mainStroke.Color = THEME.Stroke
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Dragging
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

    -- Show/Hide & Close Button
    local guiOpen = true
    local function ShowWindow()
        if guiOpen then return end
        guiOpen = true
        base.Visible = true
        Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = fullSize, BackgroundTransparency = THEME.BgTrans })
        Tween(mainStroke, TweenInfo.new(0.3), {Transparency = 0.6})
    end
    local function HideWindow()
        if not guiOpen then return end
        guiOpen = false
        Tween(base, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1 })
        Tween(mainStroke, TweenInfo.new(0.2), {Transparency = 1})
        task.delay(0.2, function() if not guiOpen then base.Visible = false end end)
    end
    WindowFunctions.Toggle = function() if guiOpen then HideWindow() else ShowWindow() end end

    -- Close Button (Кнопка закрытия)
    local closeBtn = Instance.new("TextButton", base)
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×" -- Красивый крестик
    closeBtn.Font = THEME.FontNormal
    closeBtn.TextSize = 26
    closeBtn.TextColor3 = THEME.TextMuted
    closeBtn.ZIndex = 2
    
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, TweenInfo.new(0.2), {TextColor3 = THEME.Error}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, TweenInfo.new(0.2), {TextColor3 = THEME.TextMuted}) end)
    closeBtn.MouseButton1Click:Connect(HideWindow)

    -- Init Animation
    base.Size = UDim2.new(0, 0, 0, 0)
    base.Visible = true
    Tween(base, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = fullSize })

    -- Sidebar
    local sidebarWidth = 160
    local sideBar = Instance.new("Frame", base)
    sideBar.Name = "SideBar"
    sideBar.Size = UDim2.new(0, sidebarWidth, 1, -20)
    sideBar.Position = UDim2.new(0, 10, 0, 10)
    sideBar.BackgroundColor3 = THEME.Surface
    sideBar.BackgroundTransparency = 0.85
    AddInnerStyle(sideBar, 16)

    local titleLbl = Instance.new("TextLabel", sideBar)
    titleLbl.Size = UDim2.new(1, -20, 0, 24)
    titleLbl.Position = UDim2.new(0, 12, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Settings.Title or "Library"
    titleLbl.Font = THEME.FontBold
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = THEME.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local subTitle = Instance.new("TextLabel", sideBar)
    subTitle.Size = UDim2.new(1, -20, 0, 16)
    subTitle.Position = UDim2.new(0, 12, 0, 36)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = Settings.Subtitle or "Configuration"
    subTitle.Font = THEME.FontSemi
    subTitle.TextSize = 12
    subTitle.TextColor3 = THEME.TextMuted
    subTitle.TextXAlignment = Enum.TextXAlignment.Left

    local tabContainer = Instance.new("ScrollingFrame", sideBar)
    tabContainer.Size = UDim2.new(1, -10, 1, -70)
    tabContainer.Position = UDim2.new(0, 5, 0, 65)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Content Area
    local contentArea = Instance.new("Frame", base)
    contentArea.Size = UDim2.new(1, -(sidebarWidth + 45), 1, -20)
    contentArea.Position = UDim2.new(0, sidebarWidth + 25, 0, 10)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true

    local pagesFolder = Instance.new("Folder", contentArea)
    local currentTab = nil

    --// Tab System
    function WindowFunctions:TabGroup()
        local GroupFuncs = {}
        function GroupFuncs:Tab(TabSettings)
            local TabFuncs = {}

            local tabBtn = Instance.new("TextButton", tabContainer)
            tabBtn.Size = UDim2.new(1, 0, 0, 34)
            tabBtn.BackgroundColor3 = THEME.Accent
            tabBtn.BackgroundTransparency = 1
            tabBtn.Text = ""
            tabBtn.AutoButtonColor = false
            Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 10)

            local tIcon = Instance.new("ImageLabel", tabBtn)
            tIcon.Size = UDim2.fromOffset(18, 18)
            tIcon.Position = UDim2.new(0, 10, 0.5, -9)
            tIcon.BackgroundTransparency = 1
            tIcon.ImageColor3 = THEME.TextMuted
            
            if TabSettings.Image then
                local idata = gl(TabSettings.Image)
                tIcon.Image = idata.Image
                tIcon.ImageRectOffset = idata.ImageRectPosition
                tIcon.ImageRectSize = idata.ImageRectSize
            end

            local tTitle = Instance.new("TextLabel", tabBtn)
            tTitle.Size = UDim2.new(1, -36, 1, 0)
            tTitle.Position = UDim2.new(0, 36, 0, 0)
            tTitle.BackgroundTransparency = 1
            tTitle.Text = TabSettings.Title or "Tab"
            tTitle.TextColor3 = THEME.TextMuted
            tTitle.Font = THEME.FontSemi
            tTitle.TextSize = 13
            tTitle.TextXAlignment = Enum.TextXAlignment.Left

            local page = Instance.new("ScrollingFrame", pagesFolder)
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.ScrollBarThickness = 2
            page.ScrollBarImageColor3 = THEME.Accent
            page.CanvasSize = UDim2.new(0,0,0,0)
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            
            local pLayout = Instance.new("UIListLayout", page)
            pLayout.Padding = UDim.new(0, 10)
            pLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local pPad = Instance.new("UIPadding", page)
            pPad.PaddingTop = UDim.new(0, 5)
            pPad.PaddingBottom = UDim.new(0, 10)
            pPad.PaddingRight = UDim.new(0, 6)
            pPad.PaddingLeft = UDim.new(0, 2)

            local function Activate()
                if currentTab == tabBtn then return end
                for _, t in pairs(tabContainer:GetChildren()) do
                    if t:IsA("TextButton") then
                        Tween(t, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                        Tween(t:FindFirstChild("TextLabel"), TweenInfo.new(0.2), { TextColor3 = THEME.TextMuted })
                        Tween(t:FindFirstChild("ImageLabel"), TweenInfo.new(0.2), { ImageColor3 = THEME.TextMuted })
                    end
                end
                for _, p in pairs(pagesFolder:GetChildren()) do p.Visible = false end

                currentTab = tabBtn
                page.Visible = true
                Tween(tabBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.85 })
                Tween(tTitle, TweenInfo.new(0.2), { TextColor3 = THEME.Accent })
                Tween(tIcon, TweenInfo.new(0.2), { ImageColor3 = THEME.Accent })
                
                page.CanvasPosition = Vector2.new(0,0)
                page.Position = UDim2.new(0, 15, 0, 0)
                Tween(page, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = UDim2.new(0,0,0,0) })
            end

            tabBtn.MouseButton1Click:Connect(Activate)
            if currentTab == nil then Activate() end

            function TabFuncs:Section(SecSettings)
                local SecFuncs = {}
                local sectionCont = Instance.new("Frame", page)
                sectionCont.Size = UDim2.new(1, 0, 0, 0)
                sectionCont.AutomaticSize = Enum.AutomaticSize.Y
                sectionCont.BackgroundTransparency = 1
                
                if SecSettings.Title then
                    local secTitle = Instance.new("TextLabel", sectionCont)
                    secTitle.Text = SecSettings.Title
                    secTitle.Font = THEME.FontBold
                    secTitle.TextSize = 12
                    secTitle.TextColor3 = THEME.Text
                    secTitle.Size = UDim2.new(1, 0, 0, 24)
                    secTitle.BackgroundTransparency = 1
                    secTitle.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UIPadding", sectionCont).PaddingTop = UDim.new(0, 28)
                end

                local secLayout = Instance.new("UIListLayout", sectionCont)
                secLayout.Padding = UDim.new(0, 8)
                secLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local function MakeElement(height)
                    local el = Instance.new("Frame", sectionCont)
                    el.Size = UDim2.new(1, 0, 0, height or 40)
                    el.BackgroundColor3 = THEME.Surface
                    el.BackgroundTransparency = THEME.SurfTrans
                    AddInnerStyle(el, 10)
                    return el
                end

                -- [BUTTON]
                function SecFuncs:Button(BSettings)
                    local btnFr = MakeElement(38)
                    local btn = Instance.new("TextButton", btnFr)
                    btn.Size = UDim2.new(1, 0, 1, 0)
                    btn.BackgroundTransparency = 1
                    btn.Text = BSettings.Title or "Button"
                    btn.Font = THEME.FontSemi
                    btn.TextColor3 = THEME.Text
                    btn.TextSize = 13
                    
                    btn.MouseButton1Click:Connect(function()
                        Tween(btnFr, TweenInfo.new(0.1), { BackgroundTransparency = 0.4 })
                        task.wait(0.1)
                        Tween(btnFr, TweenInfo.new(0.3), { BackgroundTransparency = THEME.SurfTrans })
                        if BSettings.Callback then BSettings.Callback() end
                    end)
                end

                -- [TOGGLE]
                function SecFuncs:Toggle(TSettings, Flag)
                    local togFr = MakeElement(40)
                    local title = Instance.new("TextLabel", togFr)
                    title.Size = UDim2.new(1, -50, 1, 0)
                    title.Position = UDim2.new(0, 12, 0, 0)
                    title.BackgroundTransparency = 1
                    title.Text = TSettings.Title or "Toggle"
                    title.Font = THEME.FontSemi
                    title.TextColor3 = THEME.Text
                    title.TextSize = 13
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local switch = Instance.new("Frame", togFr)
                    switch.Size = UDim2.fromOffset(36, 20)
                    switch.Position = UDim2.new(1, -46, 0.5, -10)
                    switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
                    
                    local knob = Instance.new("Frame", switch)
                    knob.Size = UDim2.fromOffset(16, 16)
                    knob.Position = UDim2.new(0, 2, 0.5, -8)
                    knob.BackgroundColor3 = THEME.TextMuted
                    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
                    
                    local btn = Instance.new("TextButton", togFr)
                    btn.Size = UDim2.new(1,0,1,0)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""

                    local toggled = TSettings.Default or false
                    local Funcs = { Value = toggled }
                    
                    local function Update(state)
                        toggled = state
                        Funcs.Value = state
                        Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(50, 50, 50) })
                        Tween(knob, TweenInfo.new(0.2), { 
                            Position = state and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                            BackgroundColor3 = state and THEME.Text or THEME.TextMuted
                        })
                        if TSettings.Callback then TSettings.Callback(state) end
                    end
                    
                    Update(toggled)
                    btn.MouseButton1Click:Connect(function() Update(not toggled) end)
                    if Flag then MacLib.Options[Flag] = Funcs end
                end

                -- [SLIDER]
                function SecFuncs:Slider(SSettings, Flag)
                    local slidFr = MakeElement(54)
                    local title = Instance.new("TextLabel", slidFr)
                    title.Size = UDim2.new(1, -10, 0, 24)
                    title.Position = UDim2.new(0, 12, 0, 2)
                    title.BackgroundTransparency = 1
                    title.Text = SSettings.Title or "Slider"
                    title.Font = THEME.FontSemi
                    title.TextColor3 = THEME.Text
                    title.TextSize = 13
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local valLbl = Instance.new("TextLabel", slidFr)
                    valLbl.Size = UDim2.new(0, 40, 0, 24)
                    valLbl.Position = UDim2.new(1, -52, 0, 2)
                    valLbl.BackgroundTransparency = 1
                    valLbl.Text = tostring(SSettings.Default or 0)
                    valLbl.Font = THEME.FontBold
                    valLbl.TextColor3 = THEME.Accent
                    valLbl.TextSize = 12
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    local bgBar = Instance.new("Frame", slidFr)
                    bgBar.Size = UDim2.new(1, -24, 0, 4)
                    bgBar.Position = UDim2.new(0, 12, 0, 36)
                    bgBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
                    if Flag then MacLib.Options[Flag] = Funcs end
                end

                -- [LABEL]
                function SecFuncs:Label(Text)
                    local lFr = MakeElement(28)
                    lFr.BackgroundTransparency = 1
                    lFr:FindFirstChild("UIStroke"):Destroy()
                    local t = Instance.new("TextLabel", lFr)
                    t.Size = UDim2.new(1, -24, 1, 0)
                    t.Position = UDim2.new(0, 12, 0, 0)
                    t.BackgroundTransparency = 1
                    t.Text = Text
                    t.Font = THEME.FontNormal
                    t.TextColor3 = THEME.TextMuted
                    t.TextSize = 12
                    t.TextXAlignment = Enum.TextXAlignment.Left
                end
                return SecFuncs
            end
            return TabFuncs
        end
        return GroupFuncs
    end

    function WindowFunctions:Notify(NSettings)
        local notif = Instance.new("Frame", notifications)
        notif.Size = UDim2.new(1, 0, 0, 40)
        notif.BackgroundTransparency = 1
        
        local card = Instance.new("Frame", notif)
        card.Size = UDim2.new(1, 0, 1, 0)
        card.Position = UDim2.new(0, -30, 0, 0)
        card.BackgroundColor3 = THEME.Surface
        card.BackgroundTransparency = 0.1
        AddInnerStyle(card, 10)
        
        local t = Instance.new("TextLabel", card)
        t.Size = UDim2.new(1, -20, 1, 0)
        t.Position = UDim2.new(0, 12, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = (NSettings.Title or "Alert") .. ": " .. (NSettings.Desc or "")
        t.Font = THEME.FontSemi
        t.TextColor3 = THEME.Text
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextTruncate = Enum.TextTruncate.AtEnd
        
        Tween(card, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0,0,0,0) })
        task.delay(NSettings.Duration or 3, function()
            Tween(card, TweenInfo.new(0.3), { Position = UDim2.new(1,0,0,0), BackgroundTransparency = 1 })
            task.wait(0.3)
            notif:Destroy()
        end)
    end
    return WindowFunctions
end
return MacLib
