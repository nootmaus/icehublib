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

--// Theme Palette (Dark Glass & Clean)
local THEME = {
    Background    = Color3.fromRGB(12, 12, 12),     -- Почти черный
    Surface       = Color3.fromRGB(28, 28, 28),     -- Темно-серый
    Accent        = Color3.fromRGB(60, 130, 246),   -- Приятный синий
    Text          = Color3.fromRGB(240, 240, 240),  -- Белый
    TextMuted     = Color3.fromRGB(160, 160, 160),  -- Серый
    Stroke        = Color3.fromRGB(255, 255, 255),  -- Обводка
    CloseRed      = Color3.fromRGB(255, 70, 70),    -- Цвет закрытия
    
    -- Opacity settings
    BgTrans       = 0.25, -- Полупрозрачный фон
    SurfTrans     = 0.60, -- Полупрозрачные элементы
    StrokeTrans   = 0.90, -- Еле заметная обводка
}

local IconList

--// Helper Functions
local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.Name = "IceCleanUI"
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

local function AddStroke(frame, thickness, transp)
    local s = Instance.new("UIStroke", frame)
    s.Color = THEME.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transp or THEME.StrokeTrans
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function SmoothScroll(content, input)
    -- Простая логика, т.к. ScrollingFrame в Roblox уже имеет сглаживание,
    -- мы просто настраиваем его внешний вид в коде ниже.
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

    -- Размеры
    local sizeX = Settings.Size and Settings.Size.X.Offset or 650
    local sizeY = Settings.Size and Settings.Size.Y.Offset or 400
    local fullSize = UDim2.fromOffset(sizeX, sizeY)

    -- Main Container
    local base = Instance.new("Frame", gui)
    base.Name = "Main"
    base.Size = UDim2.fromOffset(0, 0) -- Start small for anim
    base.Position = UDim2.fromScale(0.5, 0.5)
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = THEME.Background
    base.BackgroundTransparency = THEME.BgTrans
    base.ClipsDescendants = true -- Важно для анимации

    Instance.new("UICorner", base).CornerRadius = UDim.new(0, 16)
    AddStroke(base, 1.5, 0.7) -- Внешняя обводка

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

    --// АНИМАЦИИ ОТКРЫТИЯ/ЗАКРЫТИЯ //--
    local isOpen = true
    
    -- Анимация открытия: Pop Up (Увеличение)
    base.Size = UDim2.fromOffset(sizeX * 0.9, sizeY * 0.9)
    base.BackgroundTransparency = 1
    local mainStroke = base:FindFirstChildOfClass("UIStroke")
    if mainStroke then mainStroke.Transparency = 1 end

    local function Open()
        if isOpen then return end
        isOpen = true
        base.Visible = true
        Tween(base, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = fullSize,
            BackgroundTransparency = THEME.BgTrans
        })
        if mainStroke then Tween(mainStroke, TweenInfo.new(0.4), { Transparency = 0.7 }) end
        
        -- Показываем контент
        for _, c in pairs(base:GetDescendants()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("ImageLabel") then
                if c.Name ~= "Shadow" then
                    Tween(c, TweenInfo.new(0.3), { TextTransparency = 0, ImageTransparency = 0, BackgroundTransparency = (c.Name == "CloseBtn" and 0 or 1) })
                end
            end
        end
    end

    local function Close()
        if not isOpen then return end
        isOpen = false
        -- Анимация: Fade Out + Scale Down (Уменьшение на 10%)
        Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(sizeX * 0.95, sizeY * 0.95), -- Немного уменьшаем
            BackgroundTransparency = 1
        })
        if mainStroke then Tween(mainStroke, TweenInfo.new(0.3), { Transparency = 1 }) end

        -- Скрываем контент быстрее
        for _, c in pairs(base:GetDescendants()) do
            if c:IsA("UIStroke") then Tween(c, TweenInfo.new(0.2), { Transparency = 1 }) end
            if c:IsA("TextLabel") then Tween(c, TweenInfo.new(0.2), { TextTransparency = 1 }) end
            if c:IsA("ImageLabel") then Tween(c, TweenInfo.new(0.2), { ImageTransparency = 1 }) end
            if c:IsA("Frame") and c ~= base then Tween(c, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end
        end

        task.delay(0.31, function()
            if not isOpen then base.Visible = false end
        end)
    end
    
    WindowFunctions.Toggle = function() if isOpen then Close() else Open() end end

    -- Запуск первой анимации
    isOpen = false 
    Open()

    --// CLOSE BUTTON (Красивая) //--
    local closeContainer = Instance.new("TextButton", base)
    closeContainer.Name = "CloseBtn"
    closeContainer.Size = UDim2.fromOffset(28, 28)
    closeContainer.Position = UDim2.new(1, -38, 0, 10)
    closeContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeContainer.BackgroundTransparency = 0.5 -- Слегка видна
    closeContainer.Text = ""
    closeContainer.AutoButtonColor = false
    Instance.new("UICorner", closeContainer).CornerRadius = UDim.new(1, 0) -- Круг
    local closeStroke = AddStroke(closeContainer, 1, 0.8)

    local closeIcon = Instance.new("ImageLabel", closeContainer)
    closeIcon.Size = UDim2.fromOffset(10, 10)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Position = UDim2.fromScale(0.5, 0.5)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Image = "rbxassetid://6031094678" -- Крестик
    closeIcon.ImageColor3 = THEME.TextMuted

    closeContainer.MouseEnter:Connect(function()
        Tween(closeContainer, TweenInfo.new(0.2), { BackgroundColor3 = THEME.CloseRed, BackgroundTransparency = 0 })
        Tween(closeIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.new(1,1,1) })
        Tween(closeStroke, TweenInfo.new(0.2), { Transparency = 1 })
    end)
    closeContainer.MouseLeave:Connect(function()
        Tween(closeContainer, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40,40,40), BackgroundTransparency = 0.5 })
        Tween(closeIcon, TweenInfo.new(0.2), { ImageColor3 = THEME.TextMuted })
        Tween(closeStroke, TweenInfo.new(0.2), { Transparency = 0.8 })
    end)
    closeContainer.MouseButton1Click:Connect(Close)


    --// Sidebar & Content Layout //--
    local sidebarWidth = 170
    
    local sidebar = Instance.new("ScrollingFrame", base)
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -20)
    sidebar.Position = UDim2.new(0, 10, 0, 10)
    sidebar.BackgroundTransparency = 1
    sidebar.ScrollBarThickness = 0 -- Скрываем скроллбар тут
    
    local contentFrame = Instance.new("Frame", base)
    contentFrame.Size = UDim2.new(1, -(sidebarWidth + 30), 1, -20)
    contentFrame.Position = UDim2.new(0, sidebarWidth + 20, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true

    local tabListLayout = Instance.new("UIListLayout", sidebar)
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Title info in sidebar
    local infoFrame = Instance.new("Frame", sidebar)
    infoFrame.Size = UDim2.new(1, 0, 0, 50)
    infoFrame.BackgroundTransparency = 1
    infoFrame.LayoutOrder = -1
    
    local titleLbl = Instance.new("TextLabel", infoFrame)
    titleLbl.Size = UDim2.new(1, 0, 0, 20)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Settings.Title or "UI"
    titleLbl.Font = THEME.FontBold
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = THEME.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", infoFrame)
    subLbl.Size = UDim2.new(1, 0, 0, 15)
    subLbl.Position = UDim2.new(0, 10, 0, 26)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = Settings.Subtitle or ""
    subLbl.Font = THEME.FontNormal
    subLbl.TextSize = 12
    subLbl.TextColor3 = THEME.TextMuted
    subLbl.TextXAlignment = Enum.TextXAlignment.Left

    local currentTabBtn = nil
    
    function WindowFunctions:TabGroup()
        local Group = {}
        function Group:Tab(TabSettings)
            local Tab = {}
            
            -- Tab Button
            local btn = Instance.new("TextButton", sidebar)
            btn.Size = UDim2.new(1, -10, 0, 36)
            btn.BackgroundColor3 = THEME.Surface
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            local btnStroke = AddStroke(btn, 1, 1) -- invisible initially

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
            txt.Position = UDim2.new(0, 36, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = TabSettings.Title or "Tab"
            txt.TextColor3 = THEME.TextMuted
            txt.Font = THEME.FontSemi
            txt.TextSize = 13
            txt.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Tab Content Scroll
            local page = Instance.new("ScrollingFrame", contentFrame)
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.CanvasSize = UDim2.new(0,0,0,0)
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            
            -- // КРАСИВЫЙ СКРОЛЛБАР //
            page.ScrollBarThickness = 2 -- Очень тонкий
            page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
            page.ScrollBarImageTransparency = 0.8 -- Еле виден, пока не наведешь
            page.BorderSizePixel = 0
            
            local pageLayout = Instance.new("UIListLayout", page)
            pageLayout.Padding = UDim.new(0, 8)
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            Instance.new("UIPadding", page).PaddingRight = UDim.new(0, 8) -- Отступ от скролла

            local function Activate()
                if currentTabBtn == btn then return end
                
                -- Deactivate old
                for _, child in pairs(sidebar:GetChildren()) do
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
                
                for _, p in pairs(contentFrame:GetChildren()) do
                    if p:IsA("ScrollingFrame") then p.Visible = false end
                end
                
                currentTabBtn = btn
                page.Visible = true
                page.CanvasPosition = Vector2.new(0,0)

                -- Activate new
                Tween(btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.85, BackgroundColor3 = THEME.Accent })
                Tween(btnStroke, TweenInfo.new(0.2), { Transparency = 1 }) -- No stroke on active, just fill? Or slight stroke.
                Tween(txt, TweenInfo.new(0.2), { TextColor3 = THEME.Text })
                Tween(ico, TweenInfo.new(0.2), { ImageColor3 = THEME.Accent })
                
                -- Fade in content
                page.Position = UDim2.new(0, 0, 0, 10)
                page.BackgroundTransparency = 1
                Tween(page, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = UDim2.new(0,0,0,0) })
            end
            
            btn.MouseButton1Click:Connect(Activate)
            if currentTabBtn == nil then Activate() end
            
            --// SECTIONS & ELEMENTS //--
            function Tab:Section(Title)
                local section = {}
                
                if Title then
                    local tFrame = Instance.new("Frame", page)
                    tFrame.Size = UDim2.new(1, 0, 0, 30)
                    tFrame.BackgroundTransparency = 1
                    
                    local l = Instance.new("TextLabel", tFrame)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.Position = UDim2.new(0, 2, 0, 0)
                    l.BackgroundTransparency = 1
                    l.Text = Title
                    l.Font = THEME.FontBold
                    l.TextColor3 = THEME.Text
                    l.TextSize = 14
                    l.TextXAlignment = Enum.TextXAlignment.Left
                    
                    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 5)
                end
                
                local function CreateContainer(h)
                    local f = Instance.new("Frame", page)
                    f.Size = UDim2.new(1, 0, 0, h or 40)
                    f.BackgroundColor3 = THEME.Surface
                    f.BackgroundTransparency = THEME.SurfTrans
                    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
                    AddStroke(f, 1, 0.85)
                    return f
                end

                function section:Button(BData)
                    local f = CreateContainer(38)
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
                    local f = CreateContainer(40)
                    
                    local lab = Instance.new("TextLabel", f)
                    lab.Size = UDim2.new(1, -50, 1, 0)
                    lab.Position = UDim2.new(0, 12, 0, 0)
                    lab.BackgroundTransparency = 1
                    lab.Text = TData.Title or "Toggle"
                    lab.TextColor3 = THEME.Text
                    lab.Font = THEME.FontSemi
                    lab.TextSize = 13
                    lab.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local zone = Instance.new("Frame", f)
                    zone.Size = UDim2.fromOffset(34, 18)
                    zone.Position = UDim2.new(1, -44, 0.5, -9)
                    zone.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    Instance.new("UICorner", zone).CornerRadius = UDim.new(1, 0)
                    
                    local circle = Instance.new("Frame", zone)
                    circle.Size = UDim2.fromOffset(14, 14)
                    circle.Position = UDim2.new(0, 2, 0.5, -7)
                    circle.BackgroundColor3 = THEME.TextMuted
                    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
                    
                    local btn = Instance.new("TextButton", f)
                    btn.Size = UDim2.new(1,0,1,0)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    
                    local state = TData.Default or false
                    
                    local function Update()
                        Tween(zone, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(50,50,50) })
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
                    title.Position = UDim2.new(0, 12, 0, 4)
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
                    bar.Size = UDim2.new(1, -24, 0, 4)
                    bar.Position = UDim2.new(0, 12, 0, 32)
                    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
                    
                    local fill = Instance.new("Frame", bar)
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = THEME.Accent
                    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
                    
                    local btn = Instance.new("TextButton", f)
                    btn.Size = UDim2.new(1, -24, 0, 14)
                    btn.Position = UDim2.new(0, 12, 0, 27)
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
    
    -- Notify
    function WindowFunctions:Notify(Data)
        local n = Instance.new("Frame", gui) -- Можно в отдельный контейнер
        -- Простой notify для примера, чтобы не загромождать код
    end
    
    return WindowFunctions
end

return MacLib
