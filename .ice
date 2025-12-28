local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [ THEME CONFIG ]
local Colors = {
    Main = Color3.fromRGB(15, 15, 20),
    Section = Color3.fromRGB(25, 25, 30),
    Stroke = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Green = Color3.fromRGB(50, 205, 50),
    Red = Color3.fromRGB(205, 50, 50)
}

function Library:CreateWindow(Config)
    if CoreGui:FindFirstChild("IceHub_UI") then CoreGui.IceHub_UI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceHub_UI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Colors.Main
    MainFrame.Position = UDim2.new(0.5, -250, 0.4, 0)
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Colors.Stroke
    MainStroke.Thickness = 2

    -- Dragging
    local Dragging, DragInput, DragStart, StartPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Colors.Section
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BorderSizePixel = 0
    
    local SideCorner = Instance.new("UICorner", Sidebar)
    SideCorner.CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Text = Config.Name or "ICE HUB"
    Title.Font = Enum.Font.GothamBlack
    Title.TextColor3 = Colors.Accent
    Title.TextSize = 20
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1

    local TabContainer = Instance.new("Frame", Sidebar)
    TabContainer.Name = "TabContainer"
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 60)
    TabContainer.Size = UDim2.new(1, -20, 1, -70)
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Content Area
    local Content = Instance.new("Frame", MainFrame)
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 140, 0, 10)
    Content.Size = UDim2.new(1, -150, 1, -20)

    local Tabs = {}
    local FirstTab = true

    function Library:CreateTab(TabName)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Name = TabName
        TabButton.BackgroundColor3 = Colors.Main
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = TabName
        TabButton.TextColor3 = Colors.TextDark
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        
        local BtnCorner = Instance.new("UICorner", TabButton)
        BtnCorner.CornerRadius = UDim.new(0, 6)
        
        local BtnStroke = Instance.new("UIStroke", TabButton)
        BtnStroke.Color = Colors.Stroke
        BtnStroke.Thickness = 1
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local TabPage = Instance.new("ScrollingFrame", Content)
        TabPage.Name = TabName
        TabPage.BackgroundTransparency = 1
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.ScrollBarThickness = 2
        TabPage.Visible = false
        
        local PageList = Instance.new("UIListLayout", TabPage)
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        if FirstTab then
            FirstTab = false
            TabPage.Visible = true
            TabButton.TextColor3 = Colors.Accent
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            BtnStroke.Color = Colors.Accent
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Colors.TextDark, BackgroundColor3 = Colors.Main}):Play()
                    TweenService:Create(v.UIStroke, TweenInfo.new(0.2), {Color = Colors.Stroke}):Play()
                end
            end
            
            TabPage.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Colors.Accent, BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Colors.Accent}):Play()
        end)

        local Elements = {}

        function Elements:Section(Text)
            local SecFrame = Instance.new("Frame", TabPage)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Size = UDim2.new(1, 0, 0, 25)
            
            local Label = Instance.new("TextLabel", SecFrame)
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamBlack
            Label.TextColor3 = Colors.TextDark
            Label.TextSize = 12
            Label.Text = string.upper(Text)
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Elements:Toggle(Text, Default, Callback)
            local Toggled = Default or false
            local Callback = Callback or function() end

            local Frame = Instance.new("Frame", TabPage)
            Frame.BackgroundColor3 = Colors.Section
            Frame.Size = UDim2.new(1, 0, 0, 40)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            
            local Label = Instance.new("TextLabel", Frame)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = Colors.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = Text

            local Switch = Instance.new("TextButton", Frame)
            Switch.Text = ""
            Switch.Position = UDim2.new(1, -50, 0.5, -10)
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame", Switch)
            Circle.BackgroundColor3 = Colors.Text
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            Switch.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Callback(Toggled)
                
                local TargetPos = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local TargetColor = Toggled and Colors.Accent or Color3.fromRGB(50, 50, 50)
                
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = TargetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
            end)
        end

        function Elements:Button(Text, Callback)
            local ButtonFrame = Instance.new("Frame", TabPage)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)

            local Btn = Instance.new("TextButton", ButtonFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundColor3 = Colors.Section
            Btn.Font = Enum.Font.GothamBold
            Btn.Text = Text
            Btn.TextColor3 = Colors.Text
            Btn.TextSize = 13
            
            local Corner = Instance.new("UICorner", Btn)
            Corner.CornerRadius = UDim.new(0, 6)
            
            local Stroke = Instance.new("UIStroke", Btn)
            Stroke.Color = Colors.Stroke
            Stroke.Thickness = 1
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Section}):Play()
                if Callback then Callback() end
            end)
        end

        function Elements:Input(Text, Default, Callback)
            local Frame = Instance.new("Frame", TabPage)
            Frame.BackgroundColor3 = Colors.Section
            Frame.Size = UDim2.new(1, 0, 0, 40)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            
            local Label = Instance.new("TextLabel", Frame)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = Colors.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = Text

            local Box = Instance.new("TextBox", Frame)
            Box.Position = UDim2.new(1, -110, 0.5, -12)
            Box.Size = UDim2.new(0, 100, 0, 24)
            Box.BackgroundColor3 = Colors.Main
            Box.TextColor3 = Colors.Accent
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 12
            Box.Text = tostring(Default)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
            
            Box.FocusLost:Connect(function()
                Callback(Box.Text)
            end)
        end

        function Elements:Keybind(Text, Default, Callback)
            local Frame = Instance.new("Frame", TabPage)
            Frame.BackgroundColor3 = Colors.Section
            Frame.Size = UDim2.new(1, 0, 0, 40)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            
            local Label = Instance.new("TextLabel", Frame)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = Colors.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = Text

            local BindBtn = Instance.new("TextButton", Frame)
            BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.BackgroundColor3 = Colors.Main
            BindBtn.TextColor3 = Colors.TextDark
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextSize = 11
            BindBtn.Text = Default.Name
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
            
            local Listening = false

            BindBtn.MouseButton1Click:Connect(function()
                Listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Colors.Accent
            end)

            UserInputService.InputBegan:Connect(function(input)
                if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    Listening = false
                    BindBtn.Text = input.KeyCode.Name
                    BindBtn.TextColor3 = Colors.TextDark
                    if Callback then Callback(input.KeyCode) end
                end
            end)
        end

        return Elements
    end

    return Library
end

return Library
