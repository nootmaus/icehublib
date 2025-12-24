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
local UserInputService = MacLib.GetService("UserInputService")
local Players = MacLib.GetService("Players")
local CoreGui = MacLib.GetService("CoreGui")

--// Theme Palette
local THEME = {
    Background    = Color3.fromRGB(15, 15, 15),
    Surface       = Color3.fromRGB(25, 25, 25), -- Немного светлее фона для контейнеров
    Accent        = Color3.fromRGB(60, 130, 246),
    Text          = Color3.fromRGB(240, 240, 240),
    TextMuted     = Color3.fromRGB(160, 160, 160),
    Stroke        = Color3.fromRGB(60, 60, 60), -- Цвет обводки
    CloseRed      = Color3.fromRGB(255, 70, 70),
    
    -- Opacity
    BgTrans       = 0.1,
    SurfTrans     = 0.5,
    StrokeTrans   = 0.5, -- Прозрачность обводки
    
    -- Fonts
    FontBold      = Enum.Font.GothamBold, 
    FontSemi      = Enum.Font.Gotham,
    FontNormal    = Enum.Font.Gotham,
}

local IconList

--// Helper Functions
local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.Name = "IceCleanUI_Rebuilt"
    newGui.IgnoreGuiInset = true
    newGui.ResetOnSpawn = false
    newGui.DisplayOrder = 10000
    
    local parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or (gethui and gethui()) or CoreGui
    newGui.Parent = parent
    return newGui
end

local function Tween(inst, info, props)
    if not inst then return end
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function AddStroke(frame, thickness, transp, color)
    local s = Instance.new("UIStroke", frame)
    s.Color = color or THEME.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transp or THEME.StrokeTrans
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function AddCorner(frame, radius)
    local c = Instance.new("UICorner", frame)
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

-- Icon Loader
local function gl(i)
    if not IconList then
        pcall(function() IconList = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dummyrme/Library/refs/heads/main/Icon.lua'))() end)
    end
    if IconList and IconList.Icons and IconList.Icons[i] then
        local d = IconList.Icons[i]
        local s = IconList.Spritesheets[tostring(d.Image)]
        return { Image = s, ImageRectSize = d.ImageRectSize, ImageRectPosition = d.ImageRectPosition }
    end
    return { Image = "rbxassetid://"..tostring(i):gsub("rbxassetid://",""), ImageRectSize = Vector2.new(0,0), ImageRectPosition = Vector2.new(0,0) }
end

--// Library Start
function MacLib:Window(Settings)
    local WindowFunctions = { Settings = Settings }
    local gui = GetGui()

    local sizeX = Settings.Size and Settings.Size.X.Offset or 680
    local sizeY = Settings.Size and Settings.Size.Y.Offset or 450
    local fullSize = UDim2.fromOffset(sizeX, sizeY)

    -- 1. Main Container (Base)
    local base = Instance.new("Frame", gui)
    base.Name = "Main"
    base.Size = UDim2.fromOffset(0, 0) -- Starts small for animation
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = THEME.Background
    base.BackgroundTransparency = THEME.BgTrans
    base.ClipsDescendants = true
    
    AddCorner(base, 10)
    AddStroke(base, 1.5, 0.2, THEME.Accent) -- Основная обводка хаба

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = base.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    base.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(base, TweenInfo.new(0.05), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)})
        end
    end)

    --// LAYOUT STRUCTURE //
    local padding = 10
    local topHeaderHeight = 50
    local sidebarWidth = 180

    -- 2. Top Header (Отдельный фрейм для Названия и Кнопки закрытия)
    local topHeader = Instance.new("Frame", base)
    topHeader.Name = "TopHeader"
    topHeader.Size = UDim2.new(1, - (padding*2), 0, topHeaderHeight)
    topHeader.Position = UDim2.new(0, padding, 0, padding)
    topHeader.BackgroundColor3 = THEME.Surface
    topHeader.BackgroundTransparency = 0.8
    AddCorner(topHeader, 8)
    AddStroke(topHeader, 1, 0.7)

    -- Title & Subtitle inside Header
    local titleLbl = Instance.new("TextLabel", topHeader)
    titleLbl.Size = UDim2.new(1, -50, 0, 22)
    titleLbl.Position = UDim2.new(0, 12, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Settings.Title or "Ice Hub"
    titleLbl.Font = THEME.FontBold
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = THEME.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", topHeader)
    subLbl.Size = UDim2.new(1, -50, 0, 16)
    subLbl.Position = UDim2.new(0, 12, 0, 26)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = Settings.Subtitle or "Configuration"
    subLbl.Font = THEME.FontNormal
    subLbl.TextSize = 12
    subLbl.TextColor3 = THEME.TextMuted
    subLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button (Inside Header)
    local closeBtn = Instance.new("TextButton", topHeader)
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -15) -- Centered vertically in header
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    AddCorner(closeBtn, 6)
    local closeStroke = AddStroke(closeBtn, 1, 0.8)

    local closeIcon = Instance.new("ImageLabel", closeBtn)
    closeIcon.Size = UDim2.fromOffset(12, 12)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Position = UDim2.fromScale(0.5, 0.5)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Image = "rbxassetid://6031094678"
    closeIcon.ImageColor3 = THEME.TextMuted

    -- 3. Sidebar Container (Отдельный фрейм для табов)
    local sidebarFrame = Instance.new("Frame", base)
    sidebarFrame.Name = "Sidebar"
    sidebarFrame.Size = UDim2.new(0, sidebarWidth, 1, -(topHeaderHeight + (padding*3)))
    sidebarFrame.Position = UDim2.new(0, padding, 0, topHeaderHeight + (padding*2))
    sidebarFrame.BackgroundColor3 = THEME.Surface
    sidebarFrame.BackgroundTransparency = 0.8
    AddCorner(sidebarFrame, 8)
    AddStroke(sidebarFrame, 1, 0.7)

    -- Container specifically for Buttons (Scrollable)
    local tabContainer = Instance.new("ScrollingFrame", sidebarFrame)
    tabContainer.Name = "TabButtons"
    tabContainer.Size = UDim2.new(1, -10, 1, -10)
    tabContainer.Position = UDim2.new(0, 5, 0, 5)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 2
    tabContainer.ScrollBarImageColor3 = THEME.Accent
    tabContainer.CanvasSize = UDim2.new(0,0,0,0)
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- 4. Content Container (Отдельный фрейм для функций)
    local contentOuter = Instance.new("Frame", base)
    contentOuter.Name = "Content"
    contentOuter.Size = UDim2.new(1, -(sidebarWidth + (padding*3)), 1, -(topHeaderHeight + (padding*3)))
    contentOuter.Position = UDim2.new(0, sidebarWidth + (padding*2), 0, topHeaderHeight + (padding*2))
    contentOuter.BackgroundColor3 = THEME.Surface
    contentOuter.BackgroundTransparency = 0.9 -- Чуть прозрачнее
    contentOuter.ClipsDescendants = true
    AddCorner(contentOuter, 8)
    AddStroke(contentOuter, 1, 0.7)

    -- Animation Logic
    local isOpen = true
    
    local function Open()
        if isOpen then return end
        isOpen = true
        base.Visible = true
        Tween(base, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = fullSize })
    end

    local function Close()
        if not isOpen then return end
        isOpen = false
        Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(sizeX*0.8, sizeY*0.8) })
        task.delay(0.25, function() if not isOpen then base.Visible = false end end)
    end
    
    WindowFunctions.Toggle = function() if isOpen then Close() else Open() end end

    -- Close Button Events
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, TweenInfo.new(0.2), { BackgroundColor3 = THEME.CloseRed, BackgroundTransparency = 0 })
        Tween(closeIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.new(1,1,1) })
        Tween(closeStroke, TweenInfo.new(0.2), { Transparency = 1 })
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40,40,40), BackgroundTransparency = 0.5 })
        Tween(closeIcon, TweenInfo.new(0.2), { ImageColor3 = THEME.TextMuted })
        Tween(closeStroke, TweenInfo.new(0.2), { Transparency = 0.8 })
    end)
    closeBtn.MouseButton1Click:Connect(Close)

    isOpen = false
    Open()

    --// TABS LOGIC //
    local currentTabBtn = nil

    function WindowFunctions:TabGroup()
        local Group = {}
        function Group:Tab(TabSettings)
            local Tab = {}
            
            -- Create Button in the TabContainer (Scrolling)
            local btn = Instance.new("TextButton", tabContainer)
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = THEME.Surface
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            AddCorner(btn, 6)
            local btnStroke = AddStroke(btn, 1, 1) -- Invisible initially

            local ico = Instance.new("ImageLabel", btn)
            ico.Size = UDim2.fromOffset(16, 16)
            ico.Position = UDim2.new(0, 10, 0.5, -8)
            ico.BackgroundTransparency = 1
            ico.ImageColor3 = THEME.TextMuted
            
            if TabSettings.Image then
                local d = gl(TabSettings.Image)
                ico.Image = d.Image
                ico.ImageRectOffset = d.ImageRectPosition
                ico.ImageRectSize = d.ImageRectSize
            end
            
            local txt = Instance.new("TextLabel", btn)
            txt.Size = UDim2.new(1, -35, 1, 0)
            txt.Position = UDim2.new(0, 32, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = TabSettings.Title or "Tab"
            txt.TextColor3 = THEME.TextMuted
            txt.Font = THEME.FontSemi
            txt.TextSize = 13
            txt.TextXAlignment = Enum.TextXAlignment.Left

            -- Create Page in ContentOuter
            local page = Instance.new("ScrollingFrame", contentOuter)
            page.Size = UDim2.new(1, -10, 1, -10)
            page.Position = UDim2.new(0, 5, 0, 5)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.CanvasSize = UDim2.new(0,0,0,0)
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.ScrollBarThickness = 2
            page.ScrollBarImageColor3 = THEME.TextMuted
            page.BorderSizePixel = 0
            
            local pageLayout = Instance.new("UIListLayout", page)
            pageLayout.Padding = UDim.new(0, 8)
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local function Activate()
                if currentTabBtn == btn then return end
                
                -- Deactivate others
                for _, child in pairs(tabContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        Tween(child, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                        local s = child:FindFirstChild("UIStroke")
                        if s then Tween(s, TweenInfo.new(0.2), { Transparency = 1 }) end
                        local t = child:FindFirstChild("TextLabel")
                        if t then Tween(t, TweenInfo.new(0.2), { TextColor3 = THEME.TextMuted }) end
                        local i = child:FindFirstChild("ImageLabel")
                        if i then Tween(i, TweenInfo.new(0.2), { ImageColor3 = THEME.TextMuted }) end
                    end
                end
                
                for _, p in pairs(contentOuter:GetChildren()) do
                    if p:IsA("ScrollingFrame") then p.Visible = false end
                end
                
                currentTabBtn = btn
                page.Visible = true

                -- Activate current
                Tween(btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = THEME.Accent })
                Tween(btnStroke, TweenInfo.new(0.2), { Transparency = 0.5, Color = THEME.Accent })
                Tween(txt, TweenInfo.new(0.2), { TextColor3 = THEME.Text })
                Tween(ico, TweenInfo.new(0.2), { ImageColor3 = THEME.Accent })
            end
            
            btn.MouseButton1Click:Connect(Activate)
            if currentTabBtn == nil then Activate() end

            --// ELEMENTS //
            function Tab:Section(Title)
                local section = {}
                
                if Title then
                    local tFrame = Instance.new("Frame", page)
                    tFrame.Size = UDim2.new(1, 0, 0, 25)
                    tFrame.BackgroundTransparency = 1
                    local l = Instance.new("TextLabel", tFrame)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.Text = Title
                    l.Font = THEME.FontBold
                    l.TextColor3 = THEME.Text
                    l.TextSize = 14
                    l.TextXAlignment = Enum.TextXAlignment.Left
                end
                
                local function CreateContainer(h)
                    local f = Instance.new("Frame", page)
                    f.Size = UDim2.new(1, -6, 0, h or 40)
                    f.BackgroundColor3 = THEME.Surface
                    f.BackgroundTransparency = THEME.SurfTrans
                    AddCorner(f, 6)
                    AddStroke(f, 1, 0.85)
                    return f
                end

                function section:Button(BData)
                    local f = CreateContainer(36)
                    local b = Instance.new("TextButton", f)
                    b.Size = UDim2.new(1,0,1,0)
                    b.BackgroundTransparency = 1
                    b.Text = BData.Title or "Button"
                    b.TextColor3 = THEME.Text
                    b.Font = THEME.FontSemi
                    b.TextSize = 13
                    
                    b.MouseButton1Click:Connect(function()
                        Tween(f, TweenInfo.new(0.1), { BackgroundColor3 = THEME.Accent, BackgroundTransparency = 0.6 })
                        task.wait(0.1)
                        Tween(f, TweenInfo.new(0.3), { BackgroundColor3 = THEME.Surface, BackgroundTransparency = THEME.SurfTrans })
                        if BData.Callback then BData.Callback() end
                    end)
                end

                function section:Toggle(TData)
                    local f = CreateContainer(38)
                    local lab = Instance.new("TextLabel", f)
                    lab.Size = UDim2.new(1, -50, 1, 0)
                    lab.Position = UDim2.new(0, 10, 0, 0)
                    lab.BackgroundTransparency = 1
                    lab.Text = TData.Title or "Toggle"
                    lab.TextColor3 = THEME.Text
                    lab.Font = THEME.FontSemi
                    lab.TextSize = 13
                    lab.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local zone = Instance.new("Frame", f)
                    zone.Size = UDim2.fromOffset(34, 18)
                    zone.Position = UDim2.new(1, -44, 0.5, -9)
                    zone.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    AddCorner(zone, 20)
                    
                    local circle = Instance.new("Frame", zone)
                    circle.Size = UDim2.fromOffset(14, 14)
                    circle.Position = UDim2.new(0, 2, 0.5, -7)
                    circle.BackgroundColor3 = THEME.TextMuted
                    AddCorner(circle, 20)
                    
                    local btn = Instance.new("TextButton", f)
                    btn.Size = UDim2.new(1,0,1,0)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    
                    local state = TData.Default or false
                    local function Update()
                        Tween(zone, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(40,40,40) })
                        Tween(circle, TweenInfo.new(0.2), { 
                            Position = state and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                            BackgroundColor3 = state and Color3.fromRGB(255,255,255) or THEME.TextMuted
                        })
                        if TData.Callback then TData.Callback(state) end
                    end
                    Update()
                    btn.MouseButton1Click:Connect(function() state = not state; Update() end)
                    return { Set = function(v) state = v; Update() end }
                end

                function section:Slider(SData)
                    local f = CreateContainer(50)
                    local title = Instance.new("TextLabel", f)
                    title.Size = UDim2.new(1, -12, 0, 20)
                    title.Position = UDim2.new(0, 10, 0, 4)
                    title.BackgroundTransparency = 1
                    title.Text = SData.Title or "Slider"
                    title.TextColor3 = THEME.Text
                    title.Font = THEME.FontSemi
                    title.TextSize = 13
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local valLab = Instance.new("TextLabel", f)
                    valLab.Size = UDim2.new(0, 40, 0, 20)
                    valLab.Position = UDim2.new(1, -50, 0, 4)
                    valLab.BackgroundTransparency = 1
                    valLab.Text = tostring(SData.Default or 0)
                    valLab.TextColor3 = THEME.Accent
                    valLab.Font = THEME.FontBold
                    valLab.TextSize = 12
                    valLab.TextXAlignment = Enum.TextXAlignment.Right
                    
                    local bar = Instance.new("Frame", f)
                    bar.Size = UDim2.new(1, -20, 0, 4)
                    bar.Position = UDim2.new(0, 10, 0, 32)
                    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    AddCorner(bar, 2)
                    
                    local fill = Instance.new("Frame", bar)
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = THEME.Accent
                    AddCorner(fill, 2)
                    
                    local btn = Instance.new("TextButton", f)
                    btn.Size = UDim2.new(1, -20, 0, 14)
                    btn.Position = UDim2.new(0, 10, 0, 27)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    
                    local min, max = SData.Minimum or 0, SData.Maximum or 100
                    local val = SData.Default or min
                    
                    local function Set(v)
                        val = math.clamp(v, min, max)
                        valLab.Text = tostring(math.floor(val))
                        local p = (val - min)/(max - min)
                        Tween(fill, TweenInfo.new(0.05), { Size = UDim2.new(p, 0, 1, 0) })
                        if SData.Callback then SData.Callback(val) end
                    end
                    Set(val)
                    
                    local dragging = false
                    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                    UserInputService.InputChanged:Connect(function(i)
                        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                            local sizeX = bar.AbsoluteSize.X
                            local pos = i.Position.X - bar.AbsolutePosition.X
                            local p = math.clamp(pos/sizeX, 0, 1)
                            Set(min + (max-min)*p)
                        end
                    end)
                end

                return section
            end
            return Tab
        end
        return Group
    end
    
    return WindowFunctions
end

return MacLib
