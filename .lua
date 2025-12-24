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

--// iOS Dark Theme Palette
local THEME = {
    -- iOS System Grays
    MainBg       = Color3.fromRGB(28, 28, 30),   -- SystemGray6
    SidebarBg    = Color3.fromRGB(44, 44, 46),   -- SystemGray5
    ElementBg    = Color3.fromRGB(58, 58, 60),   -- SystemGray4
    
    -- Text
    Text         = Color3.fromRGB(255, 255, 255),
    TextMuted    = Color3.fromRGB(174, 174, 178), -- SystemGray2
    
    -- Accents
    AccentBlue   = Color3.fromRGB(10, 132, 255),  -- iOS Blue
    AccentGreen  = Color3.fromRGB(48, 209, 88),   -- iOS Green (For Toggles)
    Destructive  = Color3.fromRGB(255, 69, 58),   -- iOS Red (For Close)
    
    -- Stroke
    Stroke       = Color3.fromRGB(255, 255, 255),
    StrokeTrans  = 0.92, -- Очень слабая обводка, как блик
    
    -- Fonts (Gotham is closest to San Francisco)
    FontTitle    = Enum.Font.GothamBold,
    FontStd      = Enum.Font.GothamMedium,
}

local IconList

--// Helper Functions
local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.Name = "Ice_iOS"
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

-- iOS Animation Info
local Spring = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local FastTween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function AddCorner(frame, radius)
    local c = Instance.new("UICorner", frame)
    c.CornerRadius = UDim.new(0, radius or 12) -- iOS style is rounder
    return c
end

local function AddStroke(frame, thickness)
    local s = Instance.new("UIStroke", frame)
    s.Color = THEME.Stroke
    s.Thickness = thickness or 1
    s.Transparency = THEME.StrokeTrans
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

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

    local sizeX = Settings.Size and Settings.Size.X.Offset or 700
    local sizeY = Settings.Size and Settings.Size.Y.Offset or 420
    local fullSize = UDim2.fromOffset(sizeX, sizeY)

    -- 1. Main Base (The "iPad" look)
    local base = Instance.new("Frame", gui)
    base.Name = "MainBase"
    base.Size = UDim2.fromOffset(0, 0)
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = THEME.MainBg
    base.BackgroundTransparency = 0.1 -- Slight transparency for glass feel
    base.ClipsDescendants = true
    
    AddCorner(base, 16)
    AddStroke(base, 1)

    -- Dragging
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

    --// LAYOUT CONSTANTS //
    local padding = 12
    local topBarHeight = 44 -- Standard iOS nav bar height
    local sidebarWidth = 190

    -- 2. Top Header (Navigation Bar Style)
    local header = Instance.new("Frame", base)
    header.Name = "Header"
    header.Size = UDim2.new(1, -(padding*2), 0, topBarHeight)
    header.Position = UDim2.new(0, padding, 0, padding)
    header.BackgroundColor3 = THEME.SidebarBg
    header.BackgroundTransparency = 0.5
    AddCorner(header, 10)
    -- No stroke for header to look cleaner
    
    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 15, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Settings.Title or "Settings"
    titleLbl.Font = THEME.FontTitle
    titleLbl.TextSize = 17
    titleLbl.TextColor3 = THEME.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- iOS Close Button (Red Circle)
    local closeContainer = Instance.new("TextButton", header)
    closeContainer.Size = UDim2.fromOffset(28, 28)
    closeContainer.Position = UDim2.new(1, -34, 0.5, -14)
    closeContainer.BackgroundColor3 = Color3.fromRGB(40,40,40) -- Idle state
    closeContainer.Text = ""
    closeContainer.AutoButtonColor = false
    AddCorner(closeContainer, 100) -- Perfect Circle

    local closeIcon = Instance.new("ImageLabel", closeContainer)
    closeIcon.Size = UDim2.fromOffset(10, 10)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Position = UDim2.fromScale(0.5, 0.5)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Image = "rbxassetid://6031094678"
    closeIcon.ImageColor3 = THEME.TextMuted

    -- 3. Sidebar (Left Panel)
    local sidebar = Instance.new("Frame", base)
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -(topBarHeight + (padding*3)))
    sidebar.Position = UDim2.new(0, padding, 0, topBarHeight + (padding*2))
    sidebar.BackgroundColor3 = THEME.SidebarBg
    sidebar.BackgroundTransparency = 0.6
    AddCorner(sidebar, 10)
    AddStroke(sidebar, 1)

    local tabContainer = Instance.new("ScrollingFrame", sidebar)
    tabContainer.Size = UDim2.new(1, -10, 1, -10)
    tabContainer.Position = UDim2.new(0, 5, 0, 5)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContainer.CanvasSize = UDim2.new(0,0,0,0)
    
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- 4. Content Area (Right Panel)
    local content = Instance.new("Frame", base)
    content.Name = "Content"
    content.Size = UDim2.new(1, -(sidebarWidth + (padding*3)), 1, -(topBarHeight + (padding*3)))
    content.Position = UDim2.new(0, sidebarWidth + (padding*2), 0, topBarHeight + (padding*2))
    content.BackgroundColor3 = THEME.MainBg
    content.BackgroundTransparency = 1 -- Content floats on main bg
    content.ClipsDescendants = true

    -- Open/Close Logic
    local isOpen = true
    local function Open()
        if isOpen then return end
        isOpen = true
        base.Visible = true
        Tween(base, Spring, { Size = fullSize })
    end
    local function Close()
        if not isOpen then return end
        isOpen = false
        Tween(base, Spring, { Size = UDim2.fromOffset(sizeX*0.9, sizeY*0.9) })
        task.delay(0.3, function() if not isOpen then base.Visible = false end end)
    end
    WindowFunctions.Toggle = function() if isOpen then Close() else Open() end end

    closeContainer.MouseButton1Click:Connect(Close)
    closeContainer.MouseEnter:Connect(function()
        Tween(closeContainer, FastTween, { BackgroundColor3 = THEME.Destructive })
        Tween(closeIcon, FastTween, { ImageColor3 = Color3.new(1,1,1) })
    end)
    closeContainer.MouseLeave:Connect(function()
        Tween(closeContainer, FastTween, { BackgroundColor3 = Color3.fromRGB(40,40,40) })
        Tween(closeIcon, FastTween, { ImageColor3 = THEME.TextMuted })
    end)

    isOpen = false
    Open()

    --// TABS SYSTEM //
    local currentTab = nil

    function WindowFunctions:TabGroup()
        local Group = {}
        function Group:Tab(TabSettings)
            local Tab = {}
            
            -- Sidebar Button (iOS List Item Style)
            local btn = Instance.new("TextButton", tabContainer)
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = THEME.AccentBlue
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            AddCorner(btn, 8)

            local ico = Instance.new("ImageLabel", btn)
            ico.Size = UDim2.fromOffset(18, 18)
            ico.Position = UDim2.new(0, 10, 0.5, -9)
            ico.BackgroundTransparency = 1
            ico.ImageColor3 = THEME.TextMuted
            if TabSettings.Image then
                local d = gl(TabSettings.Image)
                ico.Image = d.Image
                ico.ImageRectOffset = d.ImageRectPosition
                ico.ImageRectSize = d.ImageRectSize
            end

            local txt = Instance.new("TextLabel", btn)
            txt.Size = UDim2.new(1, -40, 1, 0)
            txt.Position = UDim2.new(0, 38, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = TabSettings.Title or "Tab"
            txt.TextColor3 = THEME.TextMuted
            txt.Font = THEME.FontStd
            txt.TextSize = 14
            txt.TextXAlignment = Enum.TextXAlignment.Left

            -- Page (Right Side)
            local page = Instance.new("ScrollingFrame", content)
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.ScrollBarThickness = 3
            page.ScrollBarImageColor3 = THEME.TextMuted
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.CanvasSize = UDim2.new(0,0,0,0)
            
            local pageLayout = Instance.new("UIListLayout", page)
            pageLayout.Padding = UDim.new(0, 10)
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Activation Logic
            local function Activate()
                if currentTab == btn then return end
                
                -- Reset others
                for _, c in pairs(tabContainer:GetChildren()) do
                    if c:IsA("TextButton") then
                        Tween(c, FastTween, { BackgroundTransparency = 1 })
                        local t = c:FindFirstChild("TextLabel")
                        local i = c:FindFirstChild("ImageLabel")
                        if t then Tween(t, FastTween, { TextColor3 = THEME.TextMuted }) end
                        if i then Tween(i, FastTween, { ImageColor3 = THEME.TextMuted }) end
                    end
                end
                for _, p in pairs(content:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible=false end end
                
                currentTab = btn
                page.Visible = true
                
                -- Activate self (Blue highlight bg)
                Tween(btn, FastTween, { BackgroundTransparency = 0.85, BackgroundColor3 = THEME.AccentBlue })
                Tween(txt, FastTween, { TextColor3 = THEME.AccentBlue })
                Tween(ico, FastTween, { ImageColor3 = THEME.AccentBlue })
            end
            
            btn.MouseButton1Click:Connect(Activate)
            if currentTab == nil then Activate() end

            --// ELEMENTS //
            
            -- Helper: iOS Group Container
            local function CreateGroup(h)
                local f = Instance.new("Frame", page)
                f.Size = UDim2.new(1, 0, 0, h or 44)
                f.BackgroundColor3 = THEME.ElementBg
                f.BackgroundTransparency = 0.5
                AddCorner(f, 10)
                -- AddStroke(f, 1) -- Optional for cleaner look
                return f
            end

            function Tab:Section(Title)
                local l = Instance.new("TextLabel", page)
                l.Size = UDim2.new(1, 0, 0, 24)
                l.BackgroundTransparency = 1
                l.Text = string.upper(Title)
                l.Font = Enum.Font.GothamBold
                l.TextColor3 = THEME.TextMuted
                l.TextSize = 11
                l.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UIPadding", l).PaddingLeft = UDim.new(0, 4)
            end

            function Tab:Button(BData)
                local f = CreateGroup(40)
                local b = Instance.new("TextButton", f)
                b.Size = UDim2.new(1,0,1,0)
                b.BackgroundTransparency = 1
                b.Text = BData.Title or "Button"
                b.TextColor3 = THEME.AccentBlue -- iOS Buttons are usually blue text
                b.Font = THEME.FontStd
                b.TextSize = 15
                
                b.MouseButton1Click:Connect(function()
                    Tween(f, TweenInfo.new(0.1), { BackgroundColor3 = THEME.AccentBlue, BackgroundTransparency = 0.8 })
                    task.wait(0.1)
                    Tween(f, TweenInfo.new(0.3), { BackgroundColor3 = THEME.ElementBg, BackgroundTransparency = 0.5 })
                    if BData.Callback then BData.Callback() end
                end)
            end

            function Tab:Toggle(TData)
                local f = CreateGroup(44)
                
                local lab = Instance.new("TextLabel", f)
                lab.Size = UDim2.new(1, -60, 1, 0)
                lab.Position = UDim2.new(0, 15, 0, 0)
                lab.BackgroundTransparency = 1
                lab.Text = TData.Title or "Toggle"
                lab.TextColor3 = THEME.Text
                lab.Font = THEME.FontStd
                lab.TextSize = 15
                lab.TextXAlignment = Enum.TextXAlignment.Left
                
                -- iOS Toggle Switch
                local switch = Instance.new("Frame", f)
                switch.Size = UDim2.fromOffset(50, 30)
                switch.Position = UDim2.new(1, -60, 0.5, -15)
                switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Off state
                AddCorner(switch, 100) -- Pill shape
                
                local knob = Instance.new("Frame", switch)
                knob.Size = UDim2.fromOffset(26, 26)
                knob.Position = UDim2.new(0, 2, 0.5, -13)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                AddCorner(knob, 100) -- Circle
                
                -- Shadow for knob to give depth
                local knobStroke = Instance.new("UIStroke", knob)
                knobStroke.Thickness = 2
                knobStroke.Transparency = 0.9
                knobStroke.Color = Color3.new(0,0,0)

                local btn = Instance.new("TextButton", f)
                btn.Size = UDim2.new(1,0,1,0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                
                local state = TData.Default or false
                local function Update()
                    Tween(switch, FastTween, { BackgroundColor3 = state and THEME.AccentGreen or Color3.fromRGB(60,60,60) })
                    Tween(knob, FastTween, { Position = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13) })
                    if TData.Callback then TData.Callback(state) end
                end
                Update()
                
                btn.MouseButton1Click:Connect(function() state = not state; Update() end)
                return { Set = function(v) state = v; Update() end }
            end

            function Tab:Slider(SData)
                local f = CreateGroup(60)
                
                local title = Instance.new("TextLabel", f)
                title.Size = UDim2.new(1, -20, 0, 20)
                title.Position = UDim2.new(0, 15, 0, 8)
                title.BackgroundTransparency = 1
                title.Text = SData.Title or "Slider"
                title.TextColor3 = THEME.Text
                title.Font = THEME.FontStd
                title.TextSize = 15
                title.TextXAlignment = Enum.TextXAlignment.Left
                
                local valLab = Instance.new("TextLabel", f)
                valLab.Size = UDim2.new(0, 50, 0, 20)
                valLab.Position = UDim2.new(1, -60, 0, 8)
                valLab.BackgroundTransparency = 1
                valLab.Text = tostring(SData.Default or 0)
                valLab.TextColor3 = THEME.TextMuted
                valLab.Font = THEME.FontStd
                valLab.TextSize = 14
                valLab.TextXAlignment = Enum.TextXAlignment.Right
                
                -- Slider Track
                local track = Instance.new("Frame", f)
                track.Size = UDim2.new(1, -30, 0, 4)
                track.Position = UDim2.new(0, 15, 0, 40)
                track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                AddCorner(track, 10)
                
                local fill = Instance.new("Frame", track)
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = THEME.AccentBlue
                AddCorner(fill, 10)
                
                -- iOS Knob (Thumb)
                local thumb = Instance.new("Frame", fill)
                thumb.Size = UDim2.fromOffset(18, 18)
                thumb.AnchorPoint = Vector2.new(0.5, 0.5)
                thumb.Position = UDim2.new(1, 0, 0.5, 0)
                thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                AddCorner(thumb, 100)
                -- Knob shadow
                local ts = Instance.new("UIStroke", thumb)
                ts.Transparency = 0.8
                ts.Thickness = 1
                
                local btn = Instance.new("TextButton", f)
                btn.Size = UDim2.new(1, -30, 0, 20)
                btn.Position = UDim2.new(0, 15, 0, 30)
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
                        local sizeX = track.AbsoluteSize.X
                        local pos = i.Position.X - track.AbsolutePosition.X
                        local p = math.clamp(pos/sizeX, 0, 1)
                        Set(min + (max-min)*p)
                    end
                end)
            end

            return Tab
        end
        return Group
    end
    
    return WindowFunctions
end

return MacLib
