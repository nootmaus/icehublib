local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function Library:CreateWindow(Name)
    if CoreGui:FindFirstChild("IceHubUI") then CoreGui.IceHubUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceHubUI"
    ScreenGui.Parent = CoreGui

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -200, 0.4, 0)
    Main.Size = UDim2.new(0, 400, 0, 350)
    Main.Active = true
    Main.Draggable = true

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(60, 120, 200)
    Stroke.Thickness = 2

    local TopBar = Instance.new("Frame", Main)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 30)

    local TitleLbl = Instance.new("TextLabel", TopBar)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 10, 0, 0)
    TitleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.Text = Name
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("Frame", Main)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.Size = UDim2.new(1, 0, 1, -30)

    local Tabs = {}
    local FirstTab = true

    local TabButtons = Instance.new("Frame", TopBar)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Position = UDim2.new(0.5, 0, 0, 0)
    TabButtons.Size = UDim2.new(0.5, -5, 1, 0)
    
    local TabList = Instance.new("UIListLayout", TabButtons)
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TabList.Padding = UDim.new(0, 5)

    function Library:CreateTab(TabName)
        local TabScroll = Instance.new("ScrollingFrame", TabContainer)
        TabScroll.BackgroundTransparency = 1
        TabScroll.Size = UDim2.new(1, -10, 1, -10)
        TabScroll.Position = UDim2.new(0, 5, 0, 5)
        TabScroll.ScrollBarThickness = 2
        TabScroll.Visible = FirstTab
        
        local List = Instance.new("UIListLayout", TabScroll)
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Padding = UDim.new(0, 5)
        
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
        end)

        local TabBtn = Instance.new("TextButton", TabButtons)
        TabBtn.BackgroundColor3 = FirstTab and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(40, 40, 45)
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 80, 1, -4)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = TabName
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.TextSize = 12

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabButtons:GetChildren()) do 
                if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 45) end 
            end
            TabScroll.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        end)

        FirstTab = false
        
        local Elements = {}

        function Elements:Label(Text)
            local Lab = Instance.new("TextLabel", TabScroll)
            Lab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Lab.Size = UDim2.new(1, 0, 0, 25)
            Lab.Font = Enum.Font.Gotham
            Lab.Text = Text
            Lab.TextColor3 = Color3.fromRGB(200, 200, 200)
            Lab.TextSize = 12
        end

        function Elements:Button(Text, Callback)
            local Btn = Instance.new("TextButton", TabScroll)
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Btn.Size = UDim2.new(1, 0, 0, 30)
            Btn.Font = Enum.Font.GothamBold
            Btn.Text = Text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 12
            Btn.MouseButton1Click:Connect(Callback)
        end

        function Elements:Toggle(Text, Default, Callback)
            local Toggled = Default or false
            local Frame = Instance.new("Frame", TabScroll)
            Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Frame.Size = UDim2.new(1, 0, 0, 30)
            
            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Size = UDim2.new(0.7, 0, 1, 0)
            Lbl.Font = Enum.Font.Gotham
            Lbl.Text = Text
            Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Btn = Instance.new("TextButton", Frame)
            Btn.BackgroundColor3 = Toggled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 60)
            Btn.Position = UDim2.new(1, -40, 0.5, -10)
            Btn.Size = UDim2.new(0, 30, 0, 20)
            Btn.Text = ""

            Btn.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Btn.BackgroundColor3 = Toggled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 60)
                pcall(Callback, Toggled)
            end)
        end

        function Elements:Input(Text, Default, Callback)
            local Frame = Instance.new("Frame", TabScroll)
            Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Frame.Size = UDim2.new(1, 0, 0, 30)
            
            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Size = UDim2.new(0.5, 0, 1, 0)
            Lbl.Font = Enum.Font.Gotham
            Lbl.Text = Text
            Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Box = Instance.new("TextBox", Frame)
            Box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            Box.Position = UDim2.new(1, -70, 0.5, -10)
            Box.Size = UDim2.new(0, 60, 0, 20)
            Box.Font = Enum.Font.Gotham
            Box.Text = tostring(Default)
            Box.TextColor3 = Color3.fromRGB(255, 255, 255)
            Box.TextSize = 12
            
            Box.FocusLost:Connect(function()
                pcall(Callback, Box.Text)
            end)
        end

        function Elements:Bind(Text, Default, Callback)
            local Frame = Instance.new("Frame", TabScroll)
            Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Frame.Size = UDim2.new(1, 0, 0, 30)
            
            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Size = UDim2.new(0.5, 0, 1, 0)
            Lbl.Font = Enum.Font.Gotham
            Lbl.Text = Text
            Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Btn = Instance.new("TextButton", Frame)
            Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            Btn.Position = UDim2.new(1, -80, 0.5, -10)
            Btn.Size = UDim2.new(0, 70, 0, 20)
            Btn.Font = Enum.Font.Gotham
            Btn.Text = Default.Name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 11

            local listening = false
            Btn.MouseButton1Click:Connect(function()
                listening = true
                Btn.Text = "..."
                Btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    Btn.Text = input.KeyCode.Name
                    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    pcall(Callback, input.KeyCode)
                end
            end)
        end

        return Elements
    end
    return Library
end
return Library
