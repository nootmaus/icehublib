local IceLibrary = {}

-- [ СЕРВИСЫ ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [ ТЕМА ]
local THEME = {
    Bg = Color3.fromRGB(25, 25, 30),
    Item = Color3.fromRGB(60, 60, 70),
    Stroke = Color3.fromRGB(80, 80, 90),
    Accent = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(50, 200, 100)
}

-- [ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]
local function CreateTween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

local function ApplyGlassStyle(obj, radius)
    obj.BackgroundColor3 = THEME.Item
    obj.BackgroundTransparency = 0.5
    obj.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 8)
    
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = THEME.Stroke
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    
    local grad = Instance.new("UIGradient", obj)
    grad.Rotation = 45
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 180, 190))
    }
    return stroke
end

-- [ ОСНОВНАЯ ФУНКЦИЯ ОКНА ]
function IceLibrary:CreateWindow(hubName)
    if CoreGui:FindFirstChild("IceLibUI") then CoreGui.IceLibUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceLibUI"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 280, 0, 0) -- Старт свернутым для анимации
    MainFrame.Position = UDim2.new(0.5, -140, 0.4, 0)
    MainFrame.BackgroundColor3 = THEME.Bg
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = THEME.Stroke
    MainStroke.Thickness = 2.5
    MainStroke.Transparency = 0.4

    -- Заголовок
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = hubName or "Ice Hub"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 14
    Title.TextColor3 = THEME.Accent
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Контейнер
    local Container = Instance.new("ScrollingFrame", MainFrame)
    Container.Size = UDim2.new(1, -16, 1, -50)
    Container.Position = UDim2.new(0, 8, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = THEME.Stroke
    
    local UIList = Instance.new("UIListLayout", Container)
    UIList.Padding = UDim.new(0, 6)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Анимация открытия
    MainFrame:TweenSize(UDim2.new(0, 280, 0, 400), "Out", "Back", 0.6, true)

    -- Обновление скролла
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
    end)

    local Window = {}

    -- [ КНОПКА ]
    function Window:Button(text, callback)
        local btn = Instance.new("TextButton", Container)
        btn.Size = UDim2.new(0.95, 0, 0, 32)
        btn.Text = text
        btn.TextColor3 = THEME.Accent
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        
        local s = ApplyGlassStyle(btn, 8)
        
        btn.MouseEnter:Connect(function() 
            CreateTween(btn, {BackgroundTransparency = 0.3})
            CreateTween(s, {Color = THEME.Accent, Transparency = 0})
        end)
        btn.MouseLeave:Connect(function() 
            CreateTween(btn, {BackgroundTransparency = 0.5})
            CreateTween(s, {Color = THEME.Stroke, Transparency = 0.5})
        end)
        
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- [ ТОГГЛ (ПЕРЕКЛЮЧАТЕЛЬ) ]
    function Window:Toggle(text, default, callback)
        local state = default or false
        local btn = Instance.new("TextButton", Container)
        btn.Size = UDim2.new(0.95, 0, 0, 32)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and THEME.Green or THEME.Accent
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        
        local s = ApplyGlassStyle(btn, 8)

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            btn.TextColor3 = state and THEME.Green or THEME.Accent
            if callback then callback(state) end
        end)
    end

    -- [ ЛЕЙБЛ ]
    function Window:Label(text)
        local labFrame = Instance.new("Frame", Container)
        labFrame.Size = UDim2.new(0.95, 0, 0, 25)
        labFrame.BackgroundTransparency = 1
        
        local lab = Instance.new("TextLabel", labFrame)
        lab.Size = UDim2.new(1, 0, 1, 0)
        lab.BackgroundTransparency = 1
        lab.Text = text
        lab.TextColor3 = Color3.fromRGB(180, 180, 180)
        lab.Font = Enum.Font.Gotham
        lab.TextSize = 12
    end
    
    -- [ БИНД КЛАВИШИ ]
    function Window:Keybind(text, defaultKey, callback)
        local key = defaultKey or Enum.KeyCode.F
        local waiting = false
        
        local frame = Instance.new("Frame", Container)
        frame.Size = UDim2.new(0.95, 0, 0, 32)
        ApplyGlassStyle(frame, 8)
        
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = THEME.Accent
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.3, 0, 0.7, 0)
        btn.Position = UDim2.new(0.65, 0, 0.15, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = key.Name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            waiting = true
            btn.Text = "..."
            btn.TextColor3 = THEME.Green
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                btn.Text = key.Name
                btn.TextColor3 = Color3.new(1,1,1)
                waiting = false
            elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key and not waiting then
                if callback then callback() end
            end
        end)
    end

    return Window
end

return IceLibrary
