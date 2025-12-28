local IceLibrary = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local THEME = {
    Bg = Color3.fromRGB(25, 25, 30),
    Item = Color3.fromRGB(40, 45, 60),
    Stroke = Color3.fromRGB(80, 80, 90),
    Accent = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(50, 200, 100),
    Text = Color3.fromRGB(240, 240, 240)
}

local function ApplyGlass(obj)
    obj.BackgroundColor3 = THEME.Item
    obj.BackgroundTransparency = 0.3
    obj.BorderSizePixel = 0
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", obj)
    s.Color = THEME.Stroke
    s.Transparency = 0.6
    return s
end

function IceLibrary:CreateWindow(hubName)
    if CoreGui:FindFirstChild("IceLibUI") then CoreGui.IceLibUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceLibUI"
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
    MainFrame.BackgroundColor3 = THEME.Bg
    MainFrame.Active = true
    MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    -- Header
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = hubName
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = THEME.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local SetBtn = Instance.new("TextButton", Header)
    SetBtn.Size = UDim2.new(0, 30, 0, 30)
    SetBtn.Position = UDim2.new(1, -35, 0, 5)
    SetBtn.Text = "S"
    SetBtn.BackgroundColor3 = THEME.Item
    SetBtn.TextColor3 = THEME.Accent
    Instance.new("UICorner", SetBtn).CornerRadius = UDim.new(0, 6)

    -- Containers
    local MainContainer = Instance.new("ScrollingFrame", MainFrame)
    MainContainer.Size = UDim2.new(1, -20, 1, -50)
    MainContainer.Position = UDim2.new(0, 10, 0, 45)
    MainContainer.BackgroundTransparency = 1
    MainContainer.ScrollBarThickness = 2
    
    local SettingsContainer = Instance.new("ScrollingFrame", MainFrame)
    SettingsContainer.Size = UDim2.new(1, -20, 1, -50)
    SettingsContainer.Position = UDim2.new(0, 10, 0, 45)
    SettingsContainer.BackgroundTransparency = 1
    SettingsContainer.ScrollBarThickness = 2
    SettingsContainer.Visible = false

    local function MakeList(scroll)
        local l = Instance.new("UIListLayout", scroll)
        l.Padding = UDim.new(0, 5)
        l.HorizontalAlignment = Enum.HorizontalAlignment.Center
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
        end)
    end
    MakeList(MainContainer)
    MakeList(SettingsContainer)

    -- Tabs Logic
    SetBtn.MouseButton1Click:Connect(function()
        SettingsContainer.Visible = not SettingsContainer.Visible
        MainContainer.Visible = not SettingsContainer.Visible
    end)

    local Funcs = {}

    local function CreateElement(parent, type, text, callback, default)
        local Frame = Instance.new("Frame", parent)
        Frame.Size = UDim2.new(1, 0, 0, 34)
        ApplyGlass(Frame)
        
        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = THEME.Text
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        if type == "Button" then
            local Btn = Instance.new("TextButton", Frame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Label.Text = text -- Center text for button
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Center
            Btn.MouseButton1Click:Connect(callback)
            
        elseif type == "Toggle" then
            local State = default or false
            local TglBtn = Instance.new("TextButton", Frame)
            TglBtn.Size = UDim2.new(0, 40, 0, 20)
            TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
            TglBtn.BackgroundColor3 = State and THEME.Green or Color3.fromRGB(60,60,60)
            TglBtn.Text = ""
            Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 4)
            
            TglBtn.MouseButton1Click:Connect(function()
                State = not State
                TglBtn.BackgroundColor3 = State and THEME.Green or Color3.fromRGB(60,60,60)
                if callback then callback(State) end
            end)

        elseif type == "Input" then
            local Box = Instance.new("TextBox", Frame)
            Box.Size = UDim2.new(0, 60, 0, 20)
            Box.Position = UDim2.new(1, -70, 0.5, -10)
            Box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Box.TextColor3 = THEME.Green
            Box.Text = tostring(default or "")
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 12
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
            
            Box.FocusLost:Connect(function(enter)
                if callback then callback(Box.Text) end
            end)
            
        elseif type == "Keybind" then
            local BindBtn = Instance.new("TextButton", Frame)
            BindBtn.Size = UDim2.new(0, 80, 0, 20)
            BindBtn.Position = UDim2.new(1, -90, 0.5, -10)
            BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            BindBtn.Text = (default and default.Name) or "None"
            BindBtn.TextColor3 = THEME.Accent
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextSize = 11
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
            
            local listening = false
            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = THEME.Green
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    BindBtn.Text = input.KeyCode.Name
                    BindBtn.TextColor3 = THEME.Accent
                    if callback then callback(input.KeyCode) end
                end
            end)
        end
    end

    function Funcs:Button(text, cb) CreateElement(MainContainer, "Button", text, cb) end
    function Funcs:Label(text) CreateElement(MainContainer, "Label", text) end
    
    -- Settings Page Elements
    local SetFuncs = {}
    function SetFuncs:Toggle(text, def, cb) CreateElement(SettingsContainer, "Toggle", text, cb, def) end
    function SetFuncs:Input(text, def, cb) CreateElement(SettingsContainer, "Input", text, cb, def) end
    function SetFuncs:Keybind(text, def, cb) CreateElement(SettingsContainer, "Keybind", text, cb, def) end
    function SetFuncs:Button(text, cb) CreateElement(SettingsContainer, "Button", text, cb) end
    
    Funcs.Settings = SetFuncs
    return Funcs
end

return IceLibrary
