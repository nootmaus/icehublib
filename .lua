local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Registry = {}
local TogglesToSave = {} 

local Theme = {
    Bg = Color3.fromRGB(12, 12, 18),
    Sidebar = Color3.fromRGB(18, 18, 24),
    TabInactive = Color3.fromRGB(20, 20, 28),
    TabHover = Color3.fromRGB(35, 35, 45),
    TabActive = Color3.fromRGB(40, 45, 60),
    Element = Color3.fromRGB(22, 22, 28),
    Accent = Color3.fromRGB(255, 60, 60),
    SecondaryAccent = Color3.fromRGB(180, 0, 0),
    White = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 170, 180)
}

local ConfigName = "NamelessHub_Config.json"
local CurrentScale = 1.0
local MenuBind = "RightShift" 

local function SaveSettings()
    if not writefile then return end
    
    local data = {
        Theme = {
            Main = {R = Theme.Accent.R, G = Theme.Accent.G, B = Theme.Accent.B},
            Sec = {R = Theme.SecondaryAccent.R, G = Theme.SecondaryAccent.G, B = Theme.SecondaryAccent.B}
        },
        Scale = CurrentScale,
        UIKey = MenuBind,
        Binds = {}
    }

    for name, bind in pairs(TogglesToSave) do
        data.Binds[name] = bind
    end

    writefile(ConfigName, HttpService:JSONEncode(data))
end

local function LoadSettings()
    if not isfile or not isfile(ConfigName) then return end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigName))
    end)

    if success and result then
        if result.Theme then
            Theme.Accent = Color3.new(result.Theme.Main.R, result.Theme.Main.G, result.Theme.Main.B)
            Theme.SecondaryAccent = Color3.new(result.Theme.Sec.R, result.Theme.Sec.G, result.Theme.Sec.B)
        end
        if result.Scale then
            CurrentScale = result.Scale
        end
        if result.UIKey then
            MenuBind = result.UIKey
        end
        if result.Binds then
            TogglesToSave = result.Binds
        end
    end
end

LoadSettings()

local function RegisterObject(obj, prop, themeType)
    table.insert(Registry, {Object = obj, Property = prop, ThemeType = themeType})
end

local function UpdateTheme()
    for _, data in ipairs(Registry) do
        if data.Object and data.Object.Parent then
            local color
            if data.ThemeType == "Accent" then color = Theme.Accent
            elseif data.ThemeType == "Secondary" then color = Theme.SecondaryAccent
            elseif data.ThemeType == "Text" then color = Theme.Text
            elseif data.ThemeType == "TextDim" then color = Theme.TextDim
            elseif data.ThemeType == "Gradient" then
                data.Object.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(0.5, Theme.SecondaryAccent),
                    ColorSequenceKeypoint.new(1, Theme.Accent)
                }
                color = nil
            elseif data.ThemeType == "TitleGradient" then
                data.Object.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.SecondaryAccent)
                }
                color = nil
            end
            
            if color then
                TweenService:Create(data.Object, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {[data.Property] = color}):Play()
            end
            
            if data.CustomUpdate then data.CustomUpdate() end
        end
    end
    SaveSettings()
end

local function CreateAnimatedGradient(parent, isTitle)
    local gradient = Instance.new("UIGradient", parent)
    
    if isTitle then
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent), 
            ColorSequenceKeypoint.new(1, Theme.SecondaryAccent)
        }
        RegisterObject(gradient, "Color", "TitleGradient")
    else
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent), 
            ColorSequenceKeypoint.new(0.5, Theme.SecondaryAccent), 
            ColorSequenceKeypoint.new(1, Theme.Accent)
        }
        RegisterObject(gradient, "Color", "Gradient")
        gradient.Rotation = 45
    end

    RunService.RenderStepped:Connect(function()
        if isTitle then
             gradient.Rotation = (tick() * 45) % 360
        else
             gradient.Rotation = (tick() * 60) % 360
        end
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
        TweenService:Create(obj, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
    end end)
end

function Library:CreateWindow(titleText)
    if CoreGui:FindFirstChild("NamelessHubCompact") then CoreGui.NamelessHubCompact:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NamelessHubCompact"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 0, 0, 0) 
    Main.Position = UDim2.new(0.5, -210, 0.4, 0)
    Main.BackgroundColor3 = Theme.Bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true 
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
    
    local MainScale = Instance.new("UIScale", Main)
    MainScale.Scale = CurrentScale
    
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 320)}):Play()
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Thickness = 3
    MainStroke.Transparency = 0
    MainStroke.Color = Theme.White
    CreateAnimatedGradient(MainStroke, false)
    
    MakeDraggable(Main)

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
    CreateAnimatedGradient(Title, true)

    local BtnContainer = Instance.new("Frame", Header)
    BtnContainer.Size = UDim2.new(0, 60, 1, 0)
    BtnContainer.Position = UDim2.new(1, -65, 0, 0)
    BtnContainer.BackgroundTransparency = 1

    local CloseBtn = Instance.new("TextButton", BtnContainer)
    CloseBtn.Name = "Close"
    CloseBtn.Text = ""
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -26, 0.5, -13)
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
    RegisterObject(CloseIcon, "ImageColor3", "Accent")

    local CloseStroke = Instance.new("UIStroke", CloseBtn)
    CloseStroke.Color = Theme.Accent; CloseStroke.Thickness = 1.2; CloseStroke.Transparency = 0.5
    RegisterObject(CloseStroke, "Color", "Accent")
    
    CloseBtn.MouseButton1Click:Connect(function() 
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.4)
        ScreenGui:Destroy() 
    end)

    local SettingsBtn = Instance.new("TextButton", BtnContainer)
    SettingsBtn.Name = "Settings"
    SettingsBtn.Text = "S"
    SettingsBtn.Font = Enum.Font.GothamBlack
    SettingsBtn.TextColor3 = Theme.TextDim
    SettingsBtn.TextSize = 14
    SettingsBtn.Size = UDim2.new(0, 26, 0, 26)
    SettingsBtn.Position = UDim2.new(1, -58, 0.5, -13)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 8)

    local SettingsStroke = Instance.new("UIStroke", SettingsBtn)
    SettingsStroke.Color = Theme.TextDim; SettingsStroke.Thickness = 1.2; SettingsStroke.Transparency = 0.8

    local Line = Instance.new("Frame", Main)
    Line.Size = UDim2.new(1, -30, 0, 2)
    Line.Position = UDim2.new(0, 15, 0, 45)
    Line.BackgroundColor3 = Theme.White
    Line.BorderSizePixel = 0
    Line.ZIndex = 2

    local LineGrad = Instance.new("UIGradient", Line)
    LineGrad.Rotation = 0 

    local function GetScannerColorSeq()
        return ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Bg),
            ColorSequenceKeypoint.new(0.45, Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Theme.White), 
            ColorSequenceKeypoint.new(0.55, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.Bg)
        }
    end

    local function UpdateHLineColor()
        LineGrad.Color = GetScannerColorSeq()
    end
    UpdateHLineColor()
    table.insert(Registry, {Object = Line, CustomUpdate = UpdateHLineColor})

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 110, 1, -55)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.BackgroundTransparency = 1
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 8)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local SidebarPad = Instance.new("UIPadding", Sidebar); SidebarPad.PaddingTop = UDim.new(0, 5)

    local VLine = Instance.new("Frame", Main)
    VLine.Name = "VerticalLine"
    VLine.Size = UDim2.new(0, 2, 1, -70) 
    VLine.Position = UDim2.new(0, 125, 0, 55)
    VLine.BackgroundColor3 = Theme.White
    VLine.BorderSizePixel = 0
    VLine.ZIndex = 2
    
    local VLineGrad = Instance.new("UIGradient", VLine)
    VLineGrad.Rotation = -90 
    
    local function UpdateVLineColor()
        VLineGrad.Color = GetScannerColorSeq()
    end
    UpdateVLineColor()
    table.insert(Registry, {Object = VLine, CustomUpdate = UpdateVLineColor})

    RunService.RenderStepped:Connect(function()
        local tickTime = tick()
        local scanPos = math.sin(tickTime * 1.5) * 0.8
        local pulse = 0.2 + (math.sin(tickTime * 3) * 0.1)
        
        VLineGrad.Offset = Vector2.new(0, scanPos)
        VLineGrad.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, pulse), 
            NumberSequenceKeypoint.new(1, 1)
        }
        
        LineGrad.Offset = Vector2.new(scanPos, 0)
        LineGrad.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, pulse), 
            NumberSequenceKeypoint.new(1, 1)
        }
    end)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -145, 1, -55)
    Content.Position = UDim2.new(0, 135, 0, 50)
    Content.BackgroundTransparency = 1

    local SettingsFrame = Instance.new("Frame", Main)
    SettingsFrame.Name = "SettingsOverlay"
    SettingsFrame.Size = UDim2.new(1, -20, 1, -60)
    SettingsFrame.Position = UDim2.new(0, 10, 0, 50)
    SettingsFrame.BackgroundColor3 = Theme.Bg
    SettingsFrame.BackgroundTransparency = 1 
    SettingsFrame.Visible = false
    SettingsFrame.ZIndex = 5
    
    local Blur = Instance.new("Frame", SettingsFrame)
    Blur.Size = UDim2.new(1,0,1,0)
    Blur.BackgroundColor3 = Theme.Bg
    Blur.BackgroundTransparency = 0.05
    Instance.new("UICorner", Blur).CornerRadius = UDim.new(0, 8)
    
    local ScaleSection = Instance.new("Frame", SettingsFrame)
    ScaleSection.Size = UDim2.new(1, 0, 0, 40)
    ScaleSection.Position = UDim2.new(0, 0, 0, 0)
    ScaleSection.BackgroundTransparency = 1
    ScaleSection.ZIndex = 6

    local ScaleLabel = Instance.new("TextLabel", ScaleSection)
    ScaleLabel.Text = "Interface Scale"
    ScaleLabel.Size = UDim2.new(1, 0, 0, 20)
    ScaleLabel.Font = Enum.Font.GothamBold
    ScaleLabel.TextColor3 = Theme.Text
    ScaleLabel.TextSize = 14
    ScaleLabel.BackgroundTransparency = 1
    
    local ScaleControl = Instance.new("Frame", ScaleSection)
    ScaleControl.Size = UDim2.new(0, 100, 0, 24)
    ScaleControl.Position = UDim2.new(0.5, -50, 0, 22)
    ScaleControl.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", ScaleControl).CornerRadius = UDim.new(0, 6)
    
    local ScaleDisp = Instance.new("TextLabel", ScaleControl)
    ScaleDisp.Size = UDim2.new(1, 0, 1, 0)
    ScaleDisp.BackgroundTransparency = 1
    ScaleDisp.Text = math.floor(CurrentScale * 100 + 0.5) .. "%"
    ScaleDisp.Font = Enum.Font.GothamBold
    ScaleDisp.TextColor3 = Theme.White
    ScaleDisp.TextSize = 12
    
    local MinusBtn = Instance.new("TextButton", ScaleControl)
    MinusBtn.Size = UDim2.new(0, 30, 1, 0)
    MinusBtn.Position = UDim2.new(0, 0, 0, 0)
    MinusBtn.Text = "-"
    MinusBtn.Font = Enum.Font.GothamBlack
    MinusBtn.TextColor3 = Theme.TextDim
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.TextSize = 14
    
    local PlusBtn = Instance.new("TextButton", ScaleControl)
    PlusBtn.Size = UDim2.new(0, 30, 1, 0)
    PlusBtn.Position = UDim2.new(1, -30, 0, 0)
    PlusBtn.Text = "+"
    PlusBtn.Font = Enum.Font.GothamBlack
    PlusBtn.TextColor3 = Theme.TextDim
    PlusBtn.BackgroundTransparency = 1
    PlusBtn.TextSize = 14

    MinusBtn.MouseButton1Click:Connect(function()
        if CurrentScale > 0.6 then
            CurrentScale = CurrentScale - 0.1
            MainScale.Scale = CurrentScale
            ScaleDisp.Text = math.floor(CurrentScale * 100 + 0.5) .. "%"
            SaveSettings()
        end
    end)
    
    PlusBtn.MouseButton1Click:Connect(function()
        if CurrentScale < 1.6 then
            CurrentScale = CurrentScale + 0.1
            MainScale.Scale = CurrentScale
            ScaleDisp.Text = math.floor(CurrentScale * 100 + 0.5) .. "%"
            SaveSettings()
        end
    end)

    local BindSection = Instance.new("Frame", SettingsFrame)
    BindSection.Size = UDim2.new(1, 0, 0, 40)
    BindSection.Position = UDim2.new(0, 0, 0, 55)
    BindSection.BackgroundTransparency = 1
    BindSection.ZIndex = 6

    local BindLabel = Instance.new("TextLabel", BindSection)
    BindLabel.Text = "Menu Keybind"
    BindLabel.Size = UDim2.new(1, 0, 0, 20)
    BindLabel.Font = Enum.Font.GothamBold
    BindLabel.TextColor3 = Theme.Text
    BindLabel.TextSize = 14
    BindLabel.BackgroundTransparency = 1

    local KeybindBtn = Instance.new("TextButton", BindSection)
    KeybindBtn.Size = UDim2.new(0, 100, 0, 24)
    KeybindBtn.Position = UDim2.new(0.5, -50, 0, 22)
    KeybindBtn.BackgroundColor3 = Theme.Element
    KeybindBtn.Text = MenuBind
    KeybindBtn.Font = Enum.Font.GothamBold
    KeybindBtn.TextColor3 = Theme.TextDim
    KeybindBtn.TextSize = 12
    Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 6)
    
    local KeybindStroke = Instance.new("UIStroke", KeybindBtn)
    KeybindStroke.Color = Theme.Accent
    KeybindStroke.Thickness = 1
    KeybindStroke.Transparency = 0.8
    RegisterObject(KeybindStroke, "Color", "Accent")

    local isBindingUI = false
    KeybindBtn.MouseButton1Click:Connect(function()
        isBindingUI = true
        KeybindBtn.Text = "..."
        KeybindBtn.TextColor3 = Theme.Accent
        KeybindStroke.Transparency = 0
    end)

    local ColorsTitle = Instance.new("TextLabel", SettingsFrame)
    ColorsTitle.Text = "Theme Colors"
    ColorsTitle.Size = UDim2.new(1, 0, 0, 20)
    ColorsTitle.Position = UDim2.new(0, 0, 0, 110)
    ColorsTitle.Font = Enum.Font.GothamBold
    ColorsTitle.TextColor3 = Theme.Text
    ColorsTitle.TextSize = 14
    ColorsTitle.BackgroundTransparency = 1
    ColorsTitle.ZIndex = 6

    local ColorsGrid = Instance.new("Frame", SettingsFrame)
    ColorsGrid.Size = UDim2.new(1, 0, 1, -140)
    ColorsGrid.Position = UDim2.new(0, 0, 0, 140)
    ColorsGrid.BackgroundTransparency = 1
    ColorsGrid.ZIndex = 6
    
    local GridL = Instance.new("UIGridLayout", ColorsGrid)
    GridL.CellSize = UDim2.new(0, 60, 0, 60)
    GridL.CellPadding = UDim2.new(0, 8, 0, 8)
    GridL.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Presets = {
        {Name = "Red", Main = Color3.fromRGB(255, 60, 60), Sec = Color3.fromRGB(180, 0, 0)},
        {Name = "Aqua", Main = Color3.fromRGB(0, 255, 230), Sec = Color3.fromRGB(160, 100, 255)},
        {Name = "Green", Main = Color3.fromRGB(60, 255, 100), Sec = Color3.fromRGB(180, 255, 60)},
        {Name = "Purple", Main = Color3.fromRGB(170, 0, 255), Sec = Color3.fromRGB(255, 0, 150)},
        {Name = "Orange", Main = Color3.fromRGB(255, 140, 0), Sec = Color3.fromRGB(255, 220, 0)},
        {Name = "Blue", Main = Color3.fromRGB(0, 120, 255), Sec = Color3.fromRGB(0, 200, 255)},
        
        {Name = "Blood", Main = Color3.fromRGB(255, 0, 0), Sec = Color3.fromRGB(255, 255, 255)},
        {Name = "Mono", Main = Color3.fromRGB(255, 255, 255), Sec = Color3.fromRGB(0, 0, 0)},
        {Name = "Lakers", Main = Color3.fromRGB(255, 215, 0), Sec = Color3.fromRGB(85, 37, 130)},
        {Name = "Vapor", Main = Color3.fromRGB(255, 113, 206), Sec = Color3.fromRGB(1, 205, 254)},
    }

    for _, p in ipairs(Presets) do
        local CBtn = Instance.new("TextButton", ColorsGrid)
        CBtn.Text = ""
        CBtn.BackgroundColor3 = Theme.Element
        Instance.new("UICorner", CBtn).CornerRadius = UDim.new(0, 8)
        
        local CPreview = Instance.new("Frame", CBtn)
        CPreview.Size = UDim2.new(0, 30, 0, 30)
        CPreview.Position = UDim2.new(0.5, -15, 0.5, -15)
        CPreview.BorderSizePixel = 0
        Instance.new("UICorner", CPreview).CornerRadius = UDim.new(1, 0)
        
        local CGrad = Instance.new("UIGradient", CPreview)
        CGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, p.Main),
            ColorSequenceKeypoint.new(1, p.Sec)
        }
        CGrad.Rotation = 45
        
        local CName = Instance.new("TextLabel", CBtn)
        CName.Text = p.Name
        CName.Size = UDim2.new(1, 0, 0, 15)
        CName.Position = UDim2.new(0, 0, 1, -12)
        CName.BackgroundTransparency = 1
        CName.TextColor3 = Theme.TextDim
        CName.Font = Enum.Font.GothamBold
        CName.TextSize = 9

        CBtn.MouseButton1Click:Connect(function()
            Theme.Accent = p.Main
            Theme.SecondaryAccent = p.Sec
            UpdateTheme()
            TweenService:Create(CPreview, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 38, 0, 38)}):Play()
            task.wait(0.2)
            TweenService:Create(CPreview, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 30, 0, 30)}):Play()
        end)
    end

    local settingsOpen = false
    SettingsBtn.MouseButton1Click:Connect(function()
        settingsOpen = not settingsOpen
        SettingsFrame.Visible = settingsOpen
        Content.Visible = not settingsOpen
        VLine.Visible = not settingsOpen
        Line.Visible = not settingsOpen
        
        if settingsOpen then
            TweenService:Create(SettingsBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
            TweenService:Create(SettingsStroke, TweenInfo.new(0.3), {Color = Theme.Accent, Transparency = 0}):Play()
        else
            TweenService:Create(SettingsBtn, TweenInfo.new(0.3), {TextColor3 = Theme.TextDim}):Play()
            TweenService:Create(SettingsStroke, TweenInfo.new(0.3), {Color = Theme.TextDim, Transparency = 0.8}):Play()
        end
    end)
    
    table.insert(Registry, {Object = SettingsBtn, CustomUpdate = function()
        if settingsOpen then 
            SettingsBtn.TextColor3 = Theme.Accent 
            SettingsStroke.Color = Theme.Accent
        else
            SettingsBtn.TextColor3 = Theme.TextDim
            SettingsStroke.Color = Theme.TextDim
        end
    end})

    UserInputService.InputBegan:Connect(function(input, gp)
        if isBindingUI and input.UserInputType == Enum.UserInputType.Keyboard then
            isBindingUI = false
            MenuBind = input.KeyCode.Name
            KeybindBtn.Text = MenuBind
            KeybindBtn.TextColor3 = Theme.TextDim
            KeybindStroke.Transparency = 0.8
            SaveSettings()
            return
        end

        if input.KeyCode.Name == MenuBind and not gp and not isBindingUI then
            Main.Visible = not Main.Visible
            if Main.Visible then
                Main.Size = UDim2.new(0,0,0,0)
                TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 320)}):Play()
            end
        end
    end)

    local Window = {}
    local Tabs = {}
    local CurrentTab = nil
    local FirstTabCreated = false

    function Window:CreateTab(name)
        local TabFrame = Instance.new("ScrollingFrame", Content)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.ScrollBarThickness = 2
        TabFrame.ScrollBarImageColor3 = Theme.Accent
        TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        RegisterObject(TabFrame, "ScrollBarImageColor3", "Accent")
        
        TabFrame.Visible = false
        TabFrame.CanvasSize = UDim2.new(0,0,0,0)
        
        local ContentPad = Instance.new("UIPadding", TabFrame); ContentPad.PaddingTop = UDim.new(0, 5); ContentPad.PaddingBottom = UDim.new(0, 5); ContentPad.PaddingLeft = UDim.new(0, 2); ContentPad.PaddingRight = UDim.new(0, 4)
        local Layout = Instance.new("UIListLayout", TabFrame); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
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
        RegisterObject(BtnGrad, "Color", "Gradient")
        
        BtnGrad.Rotation = 45; BtnGrad.Enabled = false
        RunService.RenderStepped:Connect(function() if BtnGrad.Enabled then BtnGrad.Rotation = (tick() * 90) % 360 end end)

        local function Activate()
            if CurrentTab then
                local old = CurrentTab
                TweenService:Create(old.Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.8}):Play()
                TweenService:Create(old.Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                TweenService:Create(old.Label, TweenInfo.new(0.3), {TextColor3 = Theme.TextDim}):Play()
                old.Grad.Enabled = false
                old.Frame.Visible = false
            end
            CurrentTab = {Btn = Btn, Frame = TabFrame, Stroke = BtnStroke, Label = BtnLabel, Grad = BtnGrad}
            TabFrame.Visible = true; TabFrame.GroupTransparency = 1
            TweenService:Create(TabFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
            TweenService:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.TabActive, BackgroundTransparency = 0}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
            TweenService:Create(BtnLabel, TweenInfo.new(0.3), {TextColor3 = Theme.White}):Play()
            BtnGrad.Enabled = true
        end

        Btn.MouseButton1Click:Connect(Activate)
        
        if not FirstTabCreated then
            FirstTabCreated = true
            Activate()
        end

        Btn.MouseEnter:Connect(function()
            if CurrentTab and CurrentTab.Btn ~= Btn then
                TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Theme.TabHover, BackgroundTransparency = 0.5}):Play()
                TweenService:Create(BtnLabel, TweenInfo.new(0.2), {TextColor3 = Theme.White}):Play()
            end
        end)
        Btn.MouseLeave:Connect(function()
            if CurrentTab and CurrentTab.Btn ~= Btn then
                TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.8}):Play()
                TweenService:Create(BtnLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
            end
        end)

        local TabElements = {}
        function TabElements:CreateToggle(text, bindKey, defaultState, callback, bindCallback)
            local savedBind = TogglesToSave[text]
            if savedBind then bindKey = savedBind end

            local Frame = Instance.new("Frame", TabFrame)
            Frame.Size = UDim2.new(1, -2, 0, 40)
            Frame.BackgroundColor3 = Theme.Element
            Frame.BackgroundTransparency = 0.2
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
            local Stroke = Instance.new("UIStroke", Frame); Stroke.Color = Theme.Accent; Stroke.Thickness = 1; Stroke.Transparency = 0.85
            RegisterObject(Stroke, "Color", "Accent")

            local BindBtn = Instance.new("TextButton", Frame)
            BindBtn.Size = UDim2.new(0, 40, 0, 22)
            BindBtn.Position = UDim2.new(0, 8, 0.5, -11)
            BindBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
            BindBtn.Text = bindKey or ""
            BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextColor3 = Theme.TextDim; BindBtn.TextSize = 10
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
            local BindStroke = Instance.new("UIStroke", BindBtn); BindStroke.Color = Theme.Accent; BindStroke.Thickness = 1; BindStroke.Transparency = 0.7
            RegisterObject(BindStroke, "Color", "Accent")

            local BindIcon = Instance.new("ImageLabel", BindBtn)
            BindIcon.Size = UDim2.new(0,12,0,12); BindIcon.Position = UDim2.new(0.5,-6,0.5,-6)
            BindIcon.Image = "rbxassetid://6031094678"; BindIcon.ImageColor3 = Theme.TextDim; BindIcon.BackgroundTransparency = 1
            BindIcon.Visible = (bindKey == nil or bindKey == "")

            local Label = Instance.new("TextLabel", Frame)
            Label.Size = UDim2.new(1, -110, 1, 0); Label.Position = UDim2.new(0, 60, 0, 0)
            Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Theme.Text; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left

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
                TweenService:Create(Knob, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = tPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = tCol}):Play()
                TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = toggled and 0.5 or 0.85, Color = toggled and Theme.Accent or Color3.fromRGB(60,60,60)}):Play()
                if callback then callback(toggled) end
            end
            
            table.insert(Registry, {Object = Switch, CustomUpdate = function()
                if toggled then Switch.BackgroundColor3 = Theme.Accent; Stroke.Color = Theme.Accent end
            end})

            Switch.MouseButton1Click:Connect(function() toggled = not toggled; UpdateToggle() end)

            local binding = false
            BindBtn.MouseButton1Click:Connect(function()
                binding = true; BindBtn.Text = "..."; BindIcon.Visible = false; BindBtn.TextColor3 = Theme.Accent
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false; local k = input.KeyCode.Name
                    BindBtn.Text = k; BindBtn.TextColor3 = Theme.TextDim
                    TogglesToSave[text] = k
                    SaveSettings()
                    if bindCallback then bindCallback(k) end
                end
                if not binding and input.KeyCode.Name == BindBtn.Text and not UserInputService:GetFocusedTextBox() then
                    toggled = not toggled; UpdateToggle()
                end
            end)
            
            TogglesToSave[text] = BindBtn.Text
            
            return { Set = function(self, bool) toggled = bool; UpdateToggle() end }
        end
        return TabElements
    end
    return Window
end

return Library
