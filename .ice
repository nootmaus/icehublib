local IceLibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- iOS-inspired Theme with Glassmorphism
local THEME = {
    Primary = Color3.fromRGB(10, 132, 255),      -- iOS Blue
    Secondary = Color3.fromRGB(88, 86, 214),     -- Purple
    Success = Color3.fromRGB(52, 199, 89),       -- Green
    Danger = Color3.fromRGB(255, 59, 48),        -- Red
    Warning = Color3.fromRGB(255, 149, 0),       -- Orange
    
    -- Background Colors with transparency
    Background = {
        Primary = Color3.fromRGB(28, 28, 30),
        Secondary = Color3.fromRGB(44, 44, 46),
        Tertiary = Color3.fromRGB(58, 58, 60)
    },
    
    -- Text Colors
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(142, 142, 147),
        Disabled = Color3.fromRGB(99, 99, 102)
    },
    
    -- Glass Effects
    Glass = {
        Blur = 20,
        Transparency = 0.15,
        Intensity = 0.8
    }
}

-- Utility Functions
local function CreateRoundedFrame(parent, size, position, radius)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 14)
    corner.Parent = frame
    
    return frame
end

local function CreateLabel(parent, text, textSize, textColor, font)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextSize = textSize or 14
    label.TextColor3 = textColor or THEME.Text.Primary
    label.Font = font or Enum.Font.SourceSansSemibold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    return label
end

local function ApplyGlassEffect(frame, intensity)
    frame.BackgroundColor3 = THEME.Background.Secondary
    frame.BackgroundTransparency = THEME.Glass.Transparency + (intensity or 0)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.9
    stroke.Thickness = 1
    stroke.Parent = frame
    
    return stroke
end

local function CreateSmoothButton(parent, text, callback)
    local buttonFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 44), nil, 12)
    ApplyGlassEffect(buttonFrame)
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = buttonFrame
    
    local label = CreateLabel(buttonFrame, text, 16, THEME.Text.Primary, Enum.Font.SourceSansBold)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(1, -30, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://10709790937" -- Chevron icon
    icon.Parent = buttonFrame
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = THEME.Glass.Transparency - 0.1
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = THEME.Glass.Transparency
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.Primary,
            BackgroundTransparency = 0.7
        }):Play()
        
        task.wait(0.1)
        
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.Background.Secondary,
            BackgroundTransparency = THEME.Glass.Transparency
        }):Play()
        
        if callback then
            callback()
        end
    end)
    
    return buttonFrame
end

-- Main Window Creation
function IceLibrary:CreateWindow(title, subtitle)
    -- Clean up existing UI
    if CoreGui:FindFirstChild("IceiOSUI") then
        CoreGui.IceiOSUI:Destroy()
    end
    
    -- Create Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceiOSUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    -- Create Main Container
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 360, 0, 600)
    MainContainer.Position = UDim2.new(0.5, -180, 0.5, -300)
    MainContainer.BackgroundTransparency = 1
    MainContainer.Parent = ScreenGui
    
    -- Apply Glass Background
    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = THEME.Background.Primary
    Background.BackgroundTransparency = 0.05
    Background.Parent = MainContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = Background
    
    local topGradient = Instance.new("UIGradient")
    topGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 132, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 132, 255))
    }
    topGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 1)
    }
    topGradient.Rotation = 90
    topGradient.Parent = Background
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 120)
    Header.BackgroundTransparency = 1
    Header.Parent = MainContainer
    
    local Title = CreateLabel(Header, title, 28, THEME.Text.Primary, Enum.Font.SourceSansBold)
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 60)
    
    if subtitle then
        local Subtitle = CreateLabel(Header, subtitle, 14, THEME.Text.Secondary)
        Subtitle.Size = UDim2.new(1, -40, 0, 20)
        Subtitle.Position = UDim2.new(0, 20, 0, 90)
    end
    
    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, -40, 0, 40)
    TabsContainer.Position = UDim2.new(0, 20, 0, 130)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = MainContainer
    
    -- Content Area
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -40, 1, -180)
    ContentFrame.Position = UDim2.new(0, 20, 0, 180)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 2
    ContentFrame.ScrollBarImageColor3 = THEME.Text.Secondary
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.Parent = MainContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame
    
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Management
    local tabs = {}
    local currentTab = nil
    
    local function SwitchTab(tabName)
        if currentTab then
            currentTab.Content.Visible = false
            TweenService:Create(currentTab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1,
                TextColor3 = THEME.Text.Secondary
            }):Play()
        end
        
        currentTab = tabs[tabName]
        currentTab.Content.Visible = true
        
        TweenService:Create(currentTab.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.8,
            TextColor3 = THEME.Primary
        }):Play()
    end
    
    -- Function to create a new tab
    local function CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.BackgroundColor3 = THEME.Primary
        TabButton.BackgroundTransparency = 1
        TabButton.Text = name
        TabButton.TextColor3 = THEME.Text.Secondary
        TabButton.Font = Enum.Font.SourceSansSemibold
        TabButton.TextSize = 14
        TabButton.Parent = TabsContainer
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 2
        TabContent.ScrollBarImageColor3 = THEME.Text.Secondary
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        
        local TabList = Instance.new("UIListLayout")
        TabList.Padding = UDim.new(0, 8)
        TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabList.SortOrder = Enum.SortOrder.LayoutOrder
        TabList.Parent = TabContent
        
        TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 20)
        end)
        
        tabs[name] = {
            Button = TabButton,
            Content = TabContent,
            Elements = {}
        }
        
        TabButton.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
        
        if not currentTab then
            SwitchTab(name)
        end
        
        -- Arrange tabs
        local tabCount = #TabsContainer:GetChildren() - 1
        for i, child in ipairs(TabsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.Position = UDim2.new(0, (i-1) * 85, 0, 0)
            end
        end
        
        return TabContent
    end
    
    -- Create default tabs
    local MainTab = CreateTab("Main")
    local SettingsTab = CreateTab("Settings")
    
    -- Window Controls
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 20)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.TextColor3 = THEME.Text.Primary
    CloseButton.TextSize = 24
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = Header
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -75, 0, 20)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = THEME.Text.Primary
    MinimizeButton.TextSize = 24
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Parent = Header
    
    -- Draggable window
    local dragging = false
    local dragInput, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Button actions
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        local targetSize = ContentFrame.Visible and UDim2.new(1, -40, 0, 0) or UDim2.new(1, -40, 1, -180)
        ContentFrame.Visible = not ContentFrame.Visible
        TabsContainer.Visible = not TabsContainer.Visible
        
        TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = ContentFrame.Visible and UDim2.new(0, 360, 0, 600) or UDim2.new(0, 360, 0, 160)
        }):Play()
    end)
    
    -- Public API
    local IceUI = {}
    
    -- Add Button
    function IceUI:Button(name, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local button = CreateSmoothButton(targetTab, name, callback)
        button.Parent = targetTab
        return button
    end
    
    -- Add Toggle
    function IceUI:Toggle(name, defaultValue, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local toggleFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 44), nil, 12)
        ApplyGlassEffect(toggleFrame)
        
        local label = CreateLabel(toggleFrame, name, 16, THEME.Text.Primary, Enum.Font.SourceSansSemibold)
        label.Size = UDim2.new(0.7, -20, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 51, 0, 31)
        toggleButton.Position = UDim2.new(1, -66, 0.5, -15.5)
        toggleButton.BackgroundColor3 = defaultValue and THEME.Success or THEME.Background.Tertiary
        toggleButton.AutoButtonColor = false
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleButton
        
        local toggleKnob = Instance.new("Frame")
        toggleKnob.Size = UDim2.new(0, 27, 0, 27)
        toggleKnob.Position = defaultValue and UDim2.new(1, -28, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
        toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleKnob.Parent = toggleButton
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = toggleKnob
        
        local state = defaultValue or false
        
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = state and THEME.Success or THEME.Background.Tertiary
            }):Play()
            
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -28, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
            }):Play()
            
            if callback then
                callback(state)
            end
        end)
        
        return {
            Set = function(value)
                state = value
                toggleButton.BackgroundColor3 = state and THEME.Success or THEME.Background.Tertiary
                toggleKnob.Position = state and UDim2.new(1, -28, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
            end,
            Get = function()
                return state
            end
        }
    end
    
    -- Add Slider
    function IceUI:Slider(name, min, max, defaultValue, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local sliderFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 70), nil, 12)
        ApplyGlassEffect(sliderFrame)
        
        local label = CreateLabel(sliderFrame, name, 16, THEME.Text.Primary, Enum.Font.SourceSansSemibold)
        label.Size = UDim2.new(1, -30, 0, 20)
        label.Position = UDim2.new(0, 15, 0, 10)
        
        local valueLabel = CreateLabel(sliderFrame, tostring(defaultValue or min), 14, THEME.Text.Secondary)
        valueLabel.Size = UDim2.new(0, 60, 0, 20)
        valueLabel.Position = UDim2.new(1, -75, 0, 10)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -30, 0, 4)
        track.Position = UDim2.new(0, 15, 1, -24)
        track.BackgroundColor3 = THEME.Background.Tertiary
        track.Parent = sliderFrame
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0.5, 0, 1, 0)
        fill.BackgroundColor3 = THEME.Primary
        fill.Parent = track
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = UDim2.new(0.5, -10, 0.5, -10)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Text = ""
        knob.AutoButtonColor = false
        knob.Parent = track
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        
        local dragging = false
        local currentValue = defaultValue or min
        
        local function UpdateValue(value)
            currentValue = math.clamp(value, min, max)
            local ratio = (currentValue - min) / (max - min)
            
            TweenService:Create(fill, TweenInfo.new(0.1), {
                Size = UDim2.new(ratio, 0, 1, 0)
            }):Play()
            
            TweenService:Create(knob, TweenInfo.new(0.1), {
                Position = UDim2.new(ratio, -10, 0.5, -10)
            }):Play()
            
            valueLabel.Text = string.format("%.1f", currentValue)
            
            if callback then
                callback(currentValue)
            end
        end
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                local value = min + (max - min) * math.clamp(relativeX, 0, 1)
                UpdateValue(value)
            end
        end)
        
        UpdateValue(currentValue)
        
        return {
            Set = function(value)
                UpdateValue(value)
            end,
            Get = function()
                return currentValue
            end
        }
    end
    
    -- Add Dropdown
    function IceUI:Dropdown(name, options, defaultOption, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local dropdownFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 44), nil, 12)
        ApplyGlassEffect(dropdownFrame)
        
        local label = CreateLabel(dropdownFrame, name, 16, THEME.Text.Primary, Enum.Font.SourceSansSemibold)
        label.Size = UDim2.new(0.7, -20, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        
        local selectedLabel = CreateLabel(dropdownFrame, defaultOption or "Select...", 14, THEME.Text.Secondary)
        selectedLabel.Size = UDim2.new(0, 100, 1, 0)
        selectedLabel.Position = UDim2.new(1, -120, 0, 0)
        selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0, 16, 0, 16)
        arrow.Position = UDim2.new(1, -30, 0.5, -8)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://10709790937"
        arrow.ImageColor3 = THEME.Text.Secondary
        arrow.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(1, 0, 1, 0)
        dropdownButton.BackgroundTransparency = 1
        dropdownButton.Text = ""
        dropdownButton.Parent = dropdownFrame
        
        local optionsFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 50), 12)
        ApplyGlassEffect(optionsFrame)
        optionsFrame.Visible = false
        optionsFrame.ClipsDescendants = true
        
        local optionsList = Instance.new("UIListLayout")
        optionsList.Padding = UDim.new(0, 2)
        optionsList.SortOrder = Enum.SortOrder.LayoutOrder
        optionsList.Parent = optionsFrame
        
        local isOpen = false
        local selected = defaultOption
        
        local function UpdateHeight()
            optionsFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 40, 200))
        end
        
        local function ToggleDropdown()
            isOpen = not isOpen
            optionsFrame.Visible = isOpen
            
            TweenService:Create(arrow, TweenInfo.new(0.2), {
                Rotation = isOpen and 180 or 0
            }):Play()
            
            UpdateHeight()
        end
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 40)
            optionButton.BackgroundTransparency = 1
            optionButton.Text = ""
            optionButton.LayoutOrder = i
            optionButton.Parent = optionsFrame
            
            local optionLabel = CreateLabel(optionButton, option, 14, THEME.Text.Primary)
            optionLabel.Size = UDim2.new(1, -20, 1, 0)
            optionLabel.Position = UDim2.new(0, 15, 0, 0)
            
            optionButton.MouseEnter:Connect(function()
                optionLabel.TextColor3 = THEME.Primary
            end)
            
            optionButton.MouseLeave:Connect(function()
                if option ~= selected then
                    optionLabel.TextColor3 = THEME.Text.Primary
                end
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selected = option
                selectedLabel.Text = option
                ToggleDropdown()
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        dropdownButton.MouseButton1Click:Connect(ToggleDropdown)
        
        UpdateHeight()
        
        return {
            Set = function(option)
                if table.find(options, option) then
                    selected = option
                    selectedLabel.Text = option
                end
            end,
            Get = function()
                return selected
            end
        }
    end
    
    -- Add Label
    function IceUI:Label(text, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local labelFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 30), nil, 12)
        ApplyGlassEffect(labelFrame)
        
        local label = CreateLabel(labelFrame, text, 14, THEME.Text.Secondary)
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.TextXAlignment = Enum.TextXAlignment.Center
        
        return label
    end
    
    -- Add Input Box
    function IceUI:Input(name, placeholder, defaultValue, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local inputFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 44), nil, 12)
        ApplyGlassEffect(inputFrame)
        
        local label = CreateLabel(inputFrame, name, 16, THEME.Text.Primary, Enum.Font.SourceSansSemibold)
        label.Size = UDim2.new(0.4, -20, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0.6, -20, 0.6, 0)
        textBox.Position = UDim2.new(0.4, 0, 0.2, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text = defaultValue or ""
        textBox.PlaceholderText = placeholder or "Type here..."
        textBox.TextColor3 = THEME.Text.Primary
        textBox.PlaceholderColor3 = THEME.Text.Secondary
        textBox.Font = Enum.Font.SourceSans
        textBox.TextSize = 14
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.Parent = inputFrame
        
        textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textBox.Text)
            end
        end)
        
        return {
            Set = function(value)
                textBox.Text = value
            end,
            Get = function()
                return textBox.Text
            end
        }
    end
    
    -- Add Keybind
    function IceUI:Keybind(name, defaultKey, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local keybindFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 44), nil, 12)
        ApplyGlassEffect(keybindFrame)
        
        local label = CreateLabel(keybindFrame, name, 16, THEME.Text.Primary, Enum.Font.SourceSansSemibold)
        label.Size = UDim2.new(0.7, -20, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        
        local keyButton = Instance.new("TextButton")
        keyButton.Size = UDim2.new(0, 80, 0, 30)
        keyButton.Position = UDim2.new(1, -90, 0.5, -15)
        keyButton.BackgroundColor3 = THEME.Background.Tertiary
        keyButton.Text = defaultKey and defaultKey.Name or "None"
        keyButton.TextColor3 = THEME.Text.Primary
        keyButton.Font = Enum.Font.SourceSansSemibold
        keyButton.TextSize = 12
        keyButton.Parent = keybindFrame
        
        local keyCorner = Instance.new("UICorner")
        keyCorner.CornerRadius = UDim.new(0, 8)
        keyCorner.Parent = keyButton
        
        local listening = false
        local currentKey = defaultKey
        
        keyButton.MouseButton1Click:Connect(function()
            listening = true
            keyButton.Text = "..."
            keyButton.TextColor3 = THEME.Primary
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    keyButton.Text = input.KeyCode.Name
                    keyButton.TextColor3 = THEME.Text.Primary
                    
                    if callback then
                        callback(input.KeyCode)
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    listening = false
                    currentKey = Enum.UserInputType.MouseButton1
                    keyButton.Text = "Mouse1"
                    keyButton.TextColor3 = THEME.Text.Primary
                    
                    if callback then
                        callback(Enum.UserInputType.MouseButton1)
                    end
                end
            elseif currentKey then
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    if callback then
                        callback(currentKey, true)
                    end
                elseif input.UserInputType == currentKey then
                    if callback then
                        callback(currentKey, true)
                    end
                end
            end
        end)
        
        return {
            Set = function(key)
                currentKey = key
                keyButton.Text = key and key.Name or "None"
            end,
            Get = function()
                return currentKey
            end
        }
    end
    
    -- Add Color Picker
    function IceUI:ColorPicker(name, defaultColor, callback, tabName)
        local targetTab = tabName and tabs[tabName] and tabs[tabName].Content or MainTab
        local colorFrame = CreateRoundedFrame(targetTab, UDim2.new(1, 0, 0, 44), nil, 12)
        ApplyGlassEffect(colorFrame)
        
        local label = CreateLabel(colorFrame, name, 16, THEME.Text.Primary, Enum.Font.SourceSansSemibold)
        label.Size = UDim2.new(0.7, -20, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        
        local colorPreview = Instance.new("Frame")
        colorPreview.Size = UDim2.new(0, 30, 0, 30)
        colorPreview.Position = UDim2.new(1, -40, 0.5, -15)
        colorPreview.BackgroundColor3 = defaultColor or THEME.Primary
        colorPreview.Parent = colorFrame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 6)
        colorCorner.Parent = colorPreview
        
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(1, 0, 1, 0)
        colorButton.BackgroundTransparency = 1
        colorButton.Text = ""
        colorButton.Parent = colorFrame
        
        local currentColor = defaultColor or THEME.Primary
        
        colorButton.MouseButton1Click:Connect(function()
            -- In a real implementation, you would open a color picker dialog
            -- For simplicity, we'll cycle through theme colors
            local colors = {THEME.Primary, THEME.Secondary, THEME.Success, THEME.Danger, THEME.Warning}
            local nextColor = colors[((table.find(colors, currentColor) or 1) % #colors) + 1]
            
            currentColor = nextColor
            colorPreview.BackgroundColor3 = nextColor
            
            if callback then
                callback(nextColor)
            end
        end)
        
        return {
            Set = function(color)
                currentColor = color
                colorPreview.BackgroundColor3 = color
            end,
            Get = function()
                return currentColor
            end
        }
    end
    
    -- Create new tab
    function IceUI:CreateTab(name)
        CreateTab(name)
        return name
    end
    
    -- Notification system
    function IceUI:Notify(title, message, duration)
        duration = duration or 5
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 300, 0, 80)
        notification.Position = UDim2.new(1, -320, 1, -100)
        notification.BackgroundColor3 = THEME.Background.Secondary
        notification.BackgroundTransparency = 0.1
        notification.Parent = ScreenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = notification
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.9
        stroke.Thickness = 1
        stroke.Parent = notification
        
        local titleLabel = CreateLabel(notification, title, 16, THEME.Text.Primary, Enum.Font.SourceSansBold)
        titleLabel.Size = UDim2.new(1, -20, 0, 25)
        titleLabel.Position = UDim2.new(0, 15, 0, 10)
        
        local messageLabel = CreateLabel(notification, message, 14, THEME.Text.Secondary)
        messageLabel.Size = UDim2.new(1, -20, 0, 40)
        messageLabel.Position = UDim2.new(0, 15, 0, 35)
        messageLabel.TextWrapped = true
        
        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -320, 1, -120)
        }):Play()
        
        task.wait(duration)
        
        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -320, 1, -100)
        }):Play()
        
        task.wait(0.3)
        notification:Destroy()
    end
    
    -- Update window title
    function IceUI:SetTitle(newTitle)
        Title.Text = newTitle
    end
    
    -- Toggle window visibility
    function IceUI:ToggleVisibility()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    
    -- Destroy window
    function IceUI:Destroy()
        ScreenGui:Destroy()
    end
    
    return IceUI
end

return IceLibrary
