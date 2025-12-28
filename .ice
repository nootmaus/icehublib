local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}

-- [ НАСТРОЙКИ ТЕМЫ ]
local THEME = {
    Bg = Color3.fromRGB(25, 25, 30),
    Item = Color3.fromRGB(45, 45, 50),
    Stroke = Color3.fromRGB(80, 80, 90),
    Accent = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(50, 200, 100),
    Red = Color3.fromRGB(255, 70, 70),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160)
}

-- [ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]
local function CreateTween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

local function ApplyGlassStyle(obj, radius)
    obj.BackgroundColor3 = THEME.Item
    obj.BackgroundTransparency = 0.4
    obj.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 8)
    
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = THEME.Stroke
    stroke.Thickness = 1.2
    stroke.Transparency = 0.5
    
    return stroke
end

-- [ СИСТЕМА УВЕДОМЛЕНИЙ ]
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "IceNotifications"
NotifyGui.Parent = CoreGui
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotifyContainer = Instance.new("Frame", NotifyGui)
NotifyContainer.Size = UDim2.new(0, 300, 1, 0)
NotifyContainer.Position = UDim2.new(1, -310, 0, 20) -- Справа сверху
NotifyContainer.BackgroundTransparency = 1

local NotifyList = Instance.new("UIListLayout", NotifyContainer)
NotifyList.Padding = UDim.new(0, 8)
NotifyList.VerticalAlignment = Enum.VerticalAlignment.Top
NotifyList.SortOrder = Enum.SortOrder.LayoutOrder

function Library:Notify(title, text, duration)
    local frame = Instance.new("Frame", NotifyContainer)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.Position = UDim2.new(1, 100, 0, 0) -- Старт за экраном
    frame.BackgroundTransparency = 1
    
    -- Анимация появления (Glass Effect)
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    ApplyGlassStyle(bg, 8)
    
    local titleLbl = Instance.new("TextLabel", bg)
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = THEME.Green
    titleLbl.Size = UDim2.new(1, -10, 0, 20)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgLbl = Instance.new("TextLabel", bg)
    msgLbl.Text = text
    msgLbl.Font = Enum.Font.GothamMedium
    msgLbl.TextSize = 12
    msgLbl.TextColor3 = THEME.Text
    msgLbl.Size = UDim2.new(1, -10, 0, 30)
    msgLbl.Position = UDim2.new(0, 10, 0, 25)
    msgLbl.BackgroundTransparency = 1
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextWrapped = true

    -- Линия таймера
    local bar = Instance.new("Frame", bg)
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.Position = UDim2.new(0, 0, 1, -2)
    bar.BackgroundColor3 = THEME.Green
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    -- Анимация входа
    frame.Position = UDim2.new(1, 50, 0, 0)
    CreateTween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    CreateTween(bar, {Size = UDim2.new(0, 0, 0, 2)}, duration or 3)

    task.delay(duration or 3, function()
        CreateTween(frame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.4)
        task.wait(0.4)
        frame:Destroy()
    end)
end

-- [ ОСНОВНОЕ ОКНО ]
function Library.new(titleText)
    local Window = {}
    
    if CoreGui:FindFirstChild("IceLibraryUI") then CoreGui.IceLibraryUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceLibraryUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0) 
    MainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
    MainFrame.BackgroundColor3 = THEME.Bg
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainStroke = ApplyGlassStyle(MainFrame, 12)
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.3
    MainStroke.Color = Color3.fromRGB(60, 60, 60)

    -- Шапка
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Header)
    Title.Text = titleText or "Ice Hub"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 16
    Title.TextColor3 = THEME.Accent
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local function MkHeaderBtn(txt, off, cb)
        local b = Instance.new("TextButton", Header)
        b.Size = UDim2.new(0, 28, 0, 28)
        b.Position = UDim2.new(1, off, 0, 6)
        b.Text = txt
        b.TextColor3 = THEME.Accent
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        ApplyGlassStyle(b, 6)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    -- Контент
    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, 0, 1, -45)
    Container.Position = UDim2.new(0, 0, 0, 45)
    Container.BackgroundTransparency = 1

    local SettingsPage = Instance.new("ScrollingFrame", MainFrame)
    SettingsPage.Size = UDim2.new(1, -12, 1, -50)
    SettingsPage.Position = UDim2.new(0, 6, 0, 45)
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Visible = false
    SettingsPage.ScrollBarThickness = 2
    SettingsPage.ScrollBarImageColor3 = THEME.Stroke
    
    local SettingsList = Instance.new("UIListLayout", SettingsPage)
    SettingsList.Padding = UDim.new(0, 6)
    SettingsList.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local MainScroll = Instance.new("ScrollingFrame", Container)
    MainScroll.Size = UDim2.new(1, -12, 1, -10)
    MainScroll.Position = UDim2.new(0, 6, 0, 0)
    MainScroll.BackgroundTransparency = 1
    MainScroll.ScrollBarThickness = 2
    MainScroll.ScrollBarImageColor3 = THEME.Stroke

    local MainList = Instance.new("UIListLayout", MainScroll)
    MainList.Padding = UDim.new(0, 6)
    MainList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Логика переключения
    local Minimized = false
    MkHeaderBtn("_", -35, function()
        Minimized = not Minimized
        if Minimized then
            MainFrame:TweenSize(UDim2.new(0, 300, 0, 40), "Out", "Quad", 0.2, true)
            Container.Visible = false
            SettingsPage.Visible = false
        else
            MainFrame:TweenSize(UDim2.new(0, 300, 0, 400), "Out", "Quad", 0.2, true)
            if not SettingsPage.Visible then Container.Visible = true end
        end
    end)

    local SetOpen = false
    MkHeaderBtn("S", -70, function()
        SetOpen = not SetOpen
        SettingsPage.Visible = SetOpen
        Container.Visible = not SetOpen
    end)

    task.spawn(function()
        task.wait(0.1)
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 400), "Out", "Back", 0.5, true)
    end)

    -- [ ФУНКЦИОНАЛ НАСТРОЕК ]

    -- 1. Кнопка
    function Window:Button(text, callback)
        local btn = Instance.new("TextButton", SettingsPage)
        btn.Size = UDim2.new(0.98, 0, 0, 34)
        btn.Text = text
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        local s = ApplyGlassStyle(btn, 6)

        btn.MouseEnter:Connect(function() CreateTween(s, {Color = THEME.Accent, Transparency = 0.2}) end)
        btn.MouseLeave:Connect(function() CreateTween(s, {Color = THEME.Stroke, Transparency = 0.5}) end)
        
        btn.MouseButton1Click:Connect(function()
            CreateTween(btn, {TextSize = 11}, 0.1)
            task.wait(0.1)
            CreateTween(btn, {TextSize = 13}, 0.1)
            if callback then callback() end
        end)
    end

    -- 2. Тогл (Переключатель)
    function Window:Toggle(text, default, callback)
        local state = default or false
        local btn = Instance.new("TextButton", SettingsPage)
        btn.Size = UDim2.new(0.98, 0, 0, 34)
        btn.Text = ""
        btn.AutoButtonColor = false
        local s = ApplyGlassStyle(btn, 6)

        local title = Instance.new("TextLabel", btn)
        title.Text = text
        title.Font = Enum.Font.GothamMedium
        title.TextColor3 = THEME.Text
        title.TextSize = 13
        title.Size = UDim2.new(0.7, 0, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left

        local status = Instance.new("Frame", btn)
        status.Size = UDim2.new(0, 20, 0, 20)
        status.Position = UDim2.new(1, -30, 0.5, -10)
        status.BackgroundColor3 = state and THEME.Green or THEME.Item
        Instance.new("UICorner", status).CornerRadius = UDim.new(0, 4)
        
        local function Update()
            CreateTween(status, {BackgroundColor3 = state and THEME.Green or THEME.Item}, 0.2)
            if callback then callback(state) end
        end
        Update()

        btn.MouseButton1Click:Connect(function()
            state = not state
            Update()
        end)
    end

    -- 3. Слайдер (Ползунок)
    function Window:Slider(text, min, max, default, callback)
        local value = default or min
        local dragging = false
        
        local frame = Instance.new("Frame", SettingsPage)
        frame.Size = UDim2.new(0.98, 0, 0, 50)
        ApplyGlassStyle(frame, 6)
        
        local label = Instance.new("TextLabel", frame)
        label.Text = text
        label.TextColor3 = THEME.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.Size = UDim2.new(0.5, 0, 0, 30)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local valLabel = Instance.new("TextLabel", frame)
        valLabel.Text = tostring(value)
        valLabel.TextColor3 = THEME.SubText
        valLabel.Font = Enum.Font.Gotham
        valLabel.TextSize = 12
        valLabel.Size = UDim2.new(0.4, 0, 0, 30)
        valLabel.Position = UDim2.new(0.55, 0, 0, 0)
        valLabel.BackgroundTransparency = 1
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local slideBg = Instance.new("TextButton", frame) -- Используем кнопку для клика
        slideBg.Text = ""
        slideBg.Size = UDim2.new(0.9, 0, 0, 4)
        slideBg.Position = UDim2.new(0.05, 0, 0.75, 0)
        slideBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
        slideBg.AutoButtonColor = false
        Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame", slideBg)
        fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.Green
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local function Update(input)
            local pos = UDim2.new(math.clamp((input.Position.X - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1), 0, 1, 0)
            fill.Size = pos
            local newVal = math.floor(min + ((max - min) * pos.X.Scale))
            valLabel.Text = tostring(newVal)
            if callback then callback(newVal) end
        end
        
        slideBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Update(input)
            end
        end)
        
        slideBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Update(input)
            end
        end)
    end

    -- 4. Бинд (Клавиша)
    function Window:Bind(text, default, callback)
        local key = default or Enum.KeyCode.E
        local binding = false
        
        local btn = Instance.new("TextButton", SettingsPage)
        btn.Size = UDim2.new(0.98, 0, 0, 34)
        btn.Text = ""
        btn.AutoButtonColor = false
        ApplyGlassStyle(btn, 6)
        
        local label = Instance.new("TextLabel", btn)
        label.Text = text
        label.TextColor3 = THEME.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local keyLabel = Instance.new("TextLabel", btn)
        keyLabel.Text = key.Name
        keyLabel.TextColor3 = THEME.Green
        keyLabel.Font = Enum.Font.GothamBold
        keyLabel.TextSize = 13
        keyLabel.Size = UDim2.new(0.3, 0, 1, 0)
        keyLabel.Position = UDim2.new(0.65, 0, 0, 0)
        keyLabel.BackgroundTransparency = 1
        keyLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        btn.MouseButton1Click:Connect(function()
            binding = true
            keyLabel.Text = "..."
            keyLabel.TextColor3 = THEME.Red
            
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    keyLabel.Text = key.Name
                    keyLabel.TextColor3 = THEME.Green
                    binding = false
                    if callback then callback(key) end
                    conn:Disconnect()
                end
            end)
        end)
    end
    
    -- 5. ТекстБокс (Ввод текста)
    function Window:Input(text, default, callback)
        local frame = Instance.new("Frame", SettingsPage)
        frame.Size = UDim2.new(0.98, 0, 0, 40)
        ApplyGlassStyle(frame, 6)
        
        local label = Instance.new("TextLabel", frame)
        label.Text = text
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.TextColor3 = THEME.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.5, 0, 0.7, 0)
        box.Position = UDim2.new(0.45, 0, 0.15, 0)
        box.Text = default or ""
        box.PlaceholderText = "..."
        box.BackgroundColor3 = Color3.fromRGB(30,30,30)
        box.TextColor3 = THEME.Accent
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        
        box.FocusLost:Connect(function(enter)
            if callback then callback(box.Text) end
        end)
    end

    -- [ ЛОГИ ГЛАВНОГО МЕНЮ ]
    function Window:ClearLogs()
        for _, c in ipairs(MainScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
    end

    function Window:AddLog(name, value, callback)
        local btn = Instance.new("TextButton", MainScroll)
        btn.Size = UDim2.new(0.98, 0, 0, 36)
        btn.Text = ""
        btn.AutoButtonColor = false
        local s = ApplyGlassStyle(btn, 6)
        
        local n = Instance.new("TextLabel", btn)
        n.Text = name
        n.Font = Enum.Font.GothamBold
        n.TextColor3 = THEME.Text
        n.TextSize = 13
        n.Size = UDim2.new(0.6, 0, 1, 0)
        n.Position = UDim2.new(0, 10, 0, 0)
        n.BackgroundTransparency = 1
        n.TextXAlignment = Enum.TextXAlignment.Left
        
        local v = Instance.new("TextLabel", btn)
        v.Text = value
        v.Font = Enum.Font.Gotham
        v.TextColor3 = THEME.Green
        v.TextSize = 12
        v.Size = UDim2.new(0.35, 0, 1, 0)
        v.Position = UDim2.new(0.6, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.TextXAlignment = Enum.TextXAlignment.Right
        
        btn.MouseEnter:Connect(function() CreateTween(s, {Color = THEME.Accent, Transparency = 0.2}) end)
        btn.MouseLeave:Connect(function() CreateTween(s, {Color = THEME.Stroke, Transparency = 0.5}) end)
        if callback then btn.MouseButton1Click:Connect(callback) end
    end
    
    -- Автосайз скролла
    SettingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SettingsPage.CanvasSize = UDim2.new(0,0,0, SettingsList.AbsoluteContentSize.Y + 10)
    end)
    MainList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MainScroll.CanvasSize = UDim2.new(0,0,0, MainList.AbsoluteContentSize.Y + 10)
    end)

    return Window
end

return Library
