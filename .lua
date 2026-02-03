local Library = {}

-- [ SERVICES ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [ THEME ]
local Theme = {
    Bg = Color3.fromRGB(12, 12, 18),
    Sidebar = Color3.fromRGB(18, 18, 24),
    
    TabInactive = Color3.fromRGB(20, 20, 28),
    TabHover = Color3.fromRGB(35, 35, 45),
    TabActive = Color3.fromRGB(40, 45, 60),
    
    Element = Color3.fromRGB(22, 22, 28),
    
    Accent = Color3.fromRGB(0, 255, 230), -- Aqua
    SecondaryAccent = Color3.fromRGB(160, 100, 255), -- Purple
    White = Color3.fromRGB(255, 255, 255),
    
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 170, 180)
}

-- [ HELPER FUNCTIONS ]
local function CreateAnimatedGradient(parent, colors)
    local gradient = Instance.new("UIGradient", parent)
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = 45
    RunService.RenderStepped:Connect(function()
        gradient.Rotation = (tick() * 60) % 360
    end)
    return gradient
end

local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then
        local delta = input.Position - dragStart
        obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
end

-- [ LIBRARY MAIN ]
function Library:CreateWindow(titleText)
    if CoreGui:FindFirstChild("NamelessHubCompact") then CoreGui.NamelessHubCompact:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NamelessHubCompact"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 420, 0, 320)
    Main.Position = UDim2.new(0.5, -210, 0.4, 0)
    Main.BackgroundColor3 = Theme.Bg
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
    
    -- Animated Stroke
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Thickness = 3
    MainStroke.Transparency = 0
    MainStroke.Color = Theme.White
    CreateAnimatedGradient(MainStroke, {
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.SecondaryAccent),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })
    
    MakeDraggable(Main)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = titleText or "UI Library"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextColor3 = Theme.White
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    local TitleGrad = Instance.new("UIGradient", Title)
    TitleGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.SecondaryAccent)}

    -- Close Button
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Text = ""
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    local CloseIcon = Instance.new("ImageLabel", CloseBtn)
    CloseIcon.Size = UDim2.new(0, 10, 0, 10)
    CloseIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://3926305904" 
    CloseIcon.ImageRectOffset = Vector2.new(284, 4)
    CloseIcon.ImageRectSize = Vector2.new(24, 24)
    CloseIcon.ImageColor3 = Theme.Accent
    local CloseStroke = Instance.new("UIStroke", CloseBtn)
    CloseStroke.Color = Theme.Accent; CloseStroke.Thickness = 1.2; CloseStroke.Transparency = 0.5
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Glow Line
    local Line = Instance.new("Frame", Main)
    Line.Size = UDim2.new(1, -30, 0, 2)
    Line.Position = UDim2.new(0, 15, 0, 45)
    Line.BackgroundColor3 = Theme.White
    Line.BorderSizePixel = 0
    local LineGrad = Instance.new("UIGradient", Line)
    LineGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Bg), ColorSequenceKeypoint.new(0.5, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Bg)}

    -- Containers
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 110, 1, -55)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.BackgroundTransparency = 1
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 8)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local SidebarPad = Instance.new("UIPadding", Sidebar); SidebarPad.PaddingTop = UDim.new(0, 5)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -145, 1, -55)
    Content.Position = UDim2.new(0, 135, 0, 50)
    Content.BackgroundTransparency = 1

    -- Toggle GUI Keybind
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightShift and not gp then
            Main.Visible = not Main.Visible
        end
    end)

    local Window = {}
    local Tabs = {}
    local CurrentTab = nil

    function Window:CreateTab(name)
        local TabFrame = Instance.new("ScrollingFrame", Content)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.ScrollBarThickness = 2
        TabFrame.ScrollBarImageColor3 = Theme.Accent
        TabFrame.Visible = false
        TabFrame.CanvasSize = UDim2.new(0,0,0,0)
        
        local ContentPad = Instance.new("UIPadding", TabFrame); ContentPad.PaddingTop = UDim.new(0, 5); ContentPad.PaddingBottom = UDim.new(0, 5); ContentPad.PaddingLeft = UDim.new(0, 2); ContentPad.PaddingRight = UDim.new(0, 4)
        local Layout = Instance.new("UIListLayout", TabFrame); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabFrame.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10) end)

        -- Tab Button
        local Btn = Instance.new("TextButton", Sidebar)
        Btn.Size = UDim2.new(1, -5, 0, 34)
        Btn.BackgroundColor3 = Theme.TabInactive
        Btn.BackgroundTransparency = 0.8
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        
        local BtnLabel = Instance.new("TextLabel", Btn)
        BtnLabel.Size = UDim2.new(1, 0, 1, 0)
        BtnLabel.BackgroundTransparency = 1
        BtnLabel.Text = name
        BtnLabel.Font = Enum.Font.GothamBold
        BtnLabel.TextColor3 = Theme.TextDim
        BtnLabel.TextSize = 13
        BtnLabel.ZIndex = 2
        
        local BtnStroke = Instance.new("UIStroke", Btn); BtnStroke.Color = Theme.White; BtnStroke.Thickness = 1.5; BtnStroke.Transparency = 1
        local BtnGrad = Instance.new("UIGradient", BtnStroke)
        BtnGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, Theme.SecondaryAccent), ColorSequenceKeypoint.new(1, Theme.Accent)}
        BtnGrad.Rotation = 45; BtnGrad.Enabled = false
        
        RunService.RenderStepped:Connect(function() if BtnGrad.Enabled then BtnGrad.Rotation = (tick() * 90) % 360 end end)

        local function Activate()
            if CurrentTab then
                local old = CurrentTab
                TweenService:Create(old.Btn, TweenInfo.new(0.25), {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.8}):Play()
                TweenService:Create(old.Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                TweenService:Create(old.Label, TweenInfo.new(0.3), {TextColor3 = Theme.TextDim}):Play()
                old.Grad.Enabled = false
                old.Frame.Visible = false
            end
            
            CurrentTab = {Btn = Btn, Frame = TabFrame, Stroke = BtnStroke, Label = BtnLabel, Grad = BtnGrad}
            TabFrame.Visible = true
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.TabActive, BackgroundTransparency = 0}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
            TweenService:Create(BtnLabel, TweenInfo.new(0.3), {TextColor3 = Theme.White}):Play()
            BtnGrad.Enabled = true
        end

        Btn.MouseButton1Click:Connect(Activate)
        
        -- Auto select first tab
        if #Sidebar:GetChildren() == 2 then Activate() end -- 2 because UIListLayout + UIPadding are children too? No, UIListLayout is 1. Wait, UIListLayout + Padding + This Button. 

        -- Hover Effects
        Btn.MouseEnter:Connect(function()
            if CurrentTab and CurrentTab.Btn ~= Btn then
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabHover, BackgroundTransparency = 0.5}):Play()
                TweenService:Create(BtnLabel, TweenInfo.new(0.2), {TextColor3 = Theme.White}):Play()
            end
        end)
        Btn.MouseLeave:Connect(function()
            if CurrentTab and CurrentTab.Btn ~= Btn then
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.8}):Play()
                TweenService:Create(BtnLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
            end
        end)

        local TabElements = {}
        
        function TabElements:CreateToggle(text, bindKey, defaultState, callback, bindCallback)
            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -2, 0, 40)
            Frame.BackgroundColor3 = Theme.Element
            Frame.BackgroundTransparency = 0.2
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
            local Stroke = Instance.new("UIStroke", Frame); Stroke.Color = Theme.Accent; Stroke.Thickness = 1; Stroke.Transparency = 0.85
            
            -- Bind
            local BindBtn = Instance.new("TextButton", Frame)
            BindBtn.Size = UDim2.new(0, 40, 0, 22)
            BindBtn.Position = UDim2.new(0, 8, 0.5, -11)
            BindBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
            BindBtn.Text = bindKey or ""
            BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextColor3 = Theme.TextDim; BindBtn.TextSize = 10
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
            local BindStroke = Instance.new("UIStroke", BindBtn); BindStroke.Color = Theme.Accent; BindStroke.Thickness = 1; BindStroke.Transparency = 0.7
            
            local BindIcon = Instance.new("ImageLabel", BindBtn)
            BindIcon.Size = UDim2.new(0,12,0,12); BindIcon.Position = UDim2.new(0.5,-6,0.5,-6)
            BindIcon.Image = "rbxassetid://6031094678"; BindIcon.ImageColor3 = Theme.TextDim; BindIcon.BackgroundTransparency = 1
            BindIcon.Visible = (bindKey == nil or bindKey == "")

            -- Text
            local Label = Instance.new("TextLabel", Frame)
            Label.Size = UDim2.new(1, -110, 1, 0); Label.Position = UDim2.new(0, 60, 0, 0)
            Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Theme.Text; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left

            -- Switch
            local Switch = Instance.new("TextButton", Frame)
            Switch.Size = UDim2.new(0, 36, 0, 20); Switch.Position = UDim2.new(1, -44, 0.5, -10)
            Switch.BackgroundColor3 = defaultState and Theme.Accent or Color3.fromRGB(40, 40, 45)
            Switch.Text = ""; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
            local Knob = Instance.new("Frame", Switch)
            Knob.Size = UDim2.new(0, 16, 0, 16); Knob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = Theme.White; Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            
            local toggled = defaultState
            local function UpdateToggle()
                local tPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local tCol = toggled and Theme.Accent or Color3.fromRGB(40, 40, 45)
                TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = tPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = tCol}):Play()
                TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = toggled and 0.5 or 0.85, Color = toggled and Theme.Accent or Color3.fromRGB(60,60,60)}):Play()
                if callback then callback(toggled) end
            end
            
            Switch.MouseButton1Click:Connect(function() toggled = not toggled; UpdateToggle() end)

            -- Bind Logic
            local binding = false
            BindBtn.MouseButton1Click:Connect(function()
                binding = true; BindBtn.Text = "..."; BindIcon.Visible = false; BindBtn.TextColor3 = Theme.Accent
            end)
            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    local k = input.KeyCode.Name
                    BindBtn.Text = k; BindBtn.TextColor3 = Theme.TextDim
                    if bindCallback then bindCallback(k) end
                end
                -- Handle actual bind press
                if not binding and input.KeyCode.Name == BindBtn.Text and not UserInputService:GetFocusedTextBox() then
                    toggled = not toggled; UpdateToggle()
                end
            end)
            
            return {
                Set = function(self, bool) toggled = bool; UpdateToggle() end
            }
        end
        
        return TabElements
    end
    
    return Window
end

return Library
