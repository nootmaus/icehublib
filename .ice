local MacLib = {
    Options = {},
    Folder = "AquaPurpleLib",
    Connections = {},
    Flags = {}
}

--// Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Theme Configuration
local Theme = {
    Main        = Color3.fromRGB(10, 10, 15),       -- Основной фон
    Sidebar     = Color3.fromRGB(14, 14, 20),       -- Фон сайдбара
    Element     = Color3.fromRGB(20, 20, 28),       -- Фон элементов
    Text        = Color3.fromRGB(240, 240, 255),    -- Белый текст
    TextDark    = Color3.fromRGB(140, 140, 160),    -- Серый текст
    Outline     = Color3.fromRGB(35, 35, 45),       -- Обводка
    
    -- Градиент (Aqua -> Purple)
    Gradient1   = Color3.fromRGB(0, 210, 255),      -- Aqua
    Gradient2   = Color3.fromRGB(160, 60, 255),     -- Purple
}

--// Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(object, TweenInfo.new(0.05), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

local function CreateRipple(btn)
    spawn(function()
        local ripple = Create("Frame", {
            Name = "Ripple",
            Parent = btn,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, Mouse.X - btn.AbsolutePosition.X, 0, Mouse.Y - btn.AbsolutePosition.Y),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 5
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
        
        local targetSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
        
        TweenService:Create(ripple, TweenInfo.new(0.5), {
            Size = UDim2.new(0, targetSize, 0, targetSize), 
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.5)
        ripple:Destroy()
    end)
end

local function ApplyGradient(instance)
    local grad = Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Gradient1),
            ColorSequenceKeypoint.new(1, Theme.Gradient2)
        },
        Rotation = 45,
        Parent = instance
    })
    return grad
end

--// Library Main
function MacLib:Window(Settings)
    local TitleName = Settings.Title or "MacLib Premium"
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "AquaPurpleUI",
        Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(650, 400),
        ClipsDescendants = false
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    
    -- Glow Shadow
    local Shadow = Create("ImageLabel", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = -1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.Gradient1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ImageTransparency = 0.4
    })

    -- Main Stroke
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame,
        Color = Theme.Outline,
        Thickness = 1,
        Transparency = 0
    })

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 160, 1, 0),
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})
    
    -- Fix Sidebar corner (flatten right side)
    local SidebarFix = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0)
    })

    -- Divider Line
    local Divider = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        ZIndex = 2
    })

    -- Title
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 20, 0, 10),
        Font = Enum.Font.GothamBold,
        Text = TitleName,
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    -- Apply gradient to text
    local TitleGrad = ApplyGradient(TitleLabel)
    TitleGrad.Rotation = 0

    -- Tab Container
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 70),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Gradient1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Pages Container
    local PagesContainer = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -170, 1, -20),
        Position = UDim2.new(0, 170, 0, 10),
        ClipsDescendants = true
    })

    -- Drag Logic
    MakeDraggable(Sidebar, MainFrame)

    --// Tab System
    local Tabs = {}
    local FirstTab = true
    
    local WindowFuncs = {}

    function WindowFuncs:TabGroup() -- Compatibility wrapper
        return WindowFuncs
    end

    function WindowFuncs:Tab(TabSettings)
        local TabName = TabSettings.Title or "Tab"
        local TabIcon = TabSettings.Image -- Optional

        -- Page Frame
        local Page = Create("ScrollingFrame", {
            Name = TabName .. "_Page",
            Parent = PagesContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Gradient1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        Create("UIPadding", {
            Parent = Page, 
            PaddingTop = UDim.new(0, 5), 
            PaddingBottom = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 5)
        })
        Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = TabName,
            Parent = TabContainer,
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 140, 0, 34),
            Text = "",
            AutoButtonColor = false
        })
        
        -- Active Indicator (Background)
        local TabActive = Create("Frame", {
            Parent = TabButton,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 1, -- Hidden by default
            ZIndex = 0
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabActive})
        local TabActiveGrad = ApplyGradient(TabActive)

        -- Title
        local TabLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            Font = Enum.Font.GothamMedium,
            Text = TabName,
            TextColor3 = Theme.TextDark,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })

        local function UpdateTab(active)
            if active then
                Page.Visible = true
                TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play()
                TweenService:Create(TabActive, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
                
                -- Small glow bar on left
                local Bar = Create("Frame", {
                    Parent = TabButton,
                    BackgroundColor3 = Theme.Gradient1,
                    Size = UDim2.new(0, 3, 0.6, 0),
                    Position = UDim2.new(0, 0, 0.2, 0),
                    BorderSizePixel = 0,
                    Name = "ActiveBar"
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bar})
                ApplyGradient(Bar)
            else
                Page.Visible = false
                TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play()
                TweenService:Create(TabActive, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                if TabButton:FindFirstChild("ActiveBar") then
                    TabButton.ActiveBar:Destroy()
                end
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Update(false)
            end
            UpdateTab(true)
        end)

        table.insert(Tabs, {Update = UpdateTab, Obj = TabButton})

        if FirstTab then
            UpdateTab(true)
            FirstTab = false
        end

        --// Sections
        local TabFuncs = {}
        
        function TabFuncs:Section(SecSettings)
            local SectionName = SecSettings.Title or "Section"
            
            local SectionFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0), -- Auto size
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local SecTitle = Create("TextLabel", {
                Parent = SectionFrame,
                Text = SectionName,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.TextDark,
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.2
            })
            
            local Container = Create("Frame", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 22),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            })
            Create("UIListLayout", {
                Parent = Container,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            Create("UIPadding", {Parent = SectionFrame, PaddingBottom = UDim.new(0, 10)})

            local SecFuncs = {}

            -- [BUTTON]
            function SecFuncs:Button(BSettings, Flag)
                local ButtonFrame = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -4, 0, 38),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ButtonFrame})
                Create("UIStroke", {Parent = ButtonFrame, Color = Theme.Outline, Thickness = 1})

                local BtnLabel = Create("TextLabel", {
                    Parent = ButtonFrame,
                    Text = BSettings.Title or BSettings.Name or "Button",
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1
                })

                -- Hover Effect
                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
                end)

                ButtonFrame.MouseButton1Click:Connect(function()
                    CreateRipple(ButtonFrame)
                    if BSettings.Callback then BSettings.Callback() end
                end)
            end

            -- [TOGGLE]
            function SecFuncs:Toggle(TSettings, Flag)
                local CurrentState = TSettings.Default or false
                local ToggleFrame = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -4, 0, 38),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleFrame})
                local Stroke = Create("UIStroke", {Parent = ToggleFrame, Color = Theme.Outline, Thickness = 1})

                local Title = Create("TextLabel", {
                    Parent = ToggleFrame,
                    Text = TSettings.Title or TSettings.Name,
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Switch = Create("Frame", {
                    Parent = ToggleFrame,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = Color3.fromRGB(30,30,35)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
                local SwitchGrad = ApplyGradient(Switch)
                SwitchGrad.Enabled = false

                local Knob = Create("Frame", {
                    Parent = Switch,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Theme.Text
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})

                local function UpdateToggle()
                    if CurrentState then
                        SwitchGrad.Enabled = true
                        TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                        TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Color3.new(1,1,1)}):Play()
                        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Theme.Gradient1, Transparency = 0.5}):Play()
                    else
                        SwitchGrad.Enabled = false
                        TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                        TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30,30,35)}):Play()
                        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Theme.Outline, Transparency = 0}):Play()
                    end
                end

                ToggleFrame.MouseButton1Click:Connect(function()
                    CurrentState = not CurrentState
                    UpdateToggle()
                    if TSettings.Callback then TSettings.Callback(CurrentState) end
                end)
                
                -- Init
                if CurrentState then UpdateToggle() end

                local Funcs = {}
                function Funcs:Set(val)
                    CurrentState = val
                    UpdateToggle()
                    if TSettings.Callback then TSettings.Callback(CurrentState) end
                end
                if Flag then MacLib.Flags[Flag] = Funcs end
                return Funcs
            end

            -- [SLIDER]
            function SecFuncs:Slider(SSettings, Flag)
                local Min, Max = SSettings.Minimum or 0, SSettings.Maximum or 100
                local Default = SSettings.Default or Min
                local Value = Default

                local SliderFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -4, 0, 50)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderFrame})
                Create("UIStroke", {Parent = SliderFrame, Color = Theme.Outline, Thickness = 1})

                local Title = Create("TextLabel", {
                    Parent = SliderFrame,
                    Text = SSettings.Title or SSettings.Name,
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Size = UDim2.new(1, -20, 0, 25),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    Text = tostring(Value),
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBg = Create("TextButton", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(30,30,35),
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 0, 32),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBg})

                local Fill = Create("Frame", {
                    Parent = SliderBg,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
                ApplyGradient(Fill)

                local Knob = Create("Frame", {
                    Parent = Fill,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -6, 0.5, -6),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})

                local function UpdateSlider(Input)
                    local SizeX = SliderBg.AbsoluteSize.X
                    local MouseX = math.clamp(Input.Position.X - SliderBg.AbsolutePosition.X, 0, SizeX)
                    local Percent = MouseX / SizeX
                    Value = math.floor(Min + ((Max - Min) * Percent))
                    
                    ValueLabel.Text = tostring(Value)
                    TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
                    
                    if SSettings.Callback then SSettings.Callback(Value) end
                end

                local function SetSlider(val)
                    Value = math.clamp(val, Min, Max)
                    local Percent = (Value - Min) / (Max - Min)
                    ValueLabel.Text = tostring(Value)
                    TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
                end

                -- Init
                SetSlider(Default)

                local Dragging = false
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                local Funcs = {}
                function Funcs:Set(v) SetSlider(v) end
                if Flag then MacLib.Flags[Flag] = Funcs end
                return Funcs
            end

            -- [DROPDOWN]
            function SecFuncs:Dropdown(DSettings, Flag)
                local Options = DSettings.Options or {}
                local Current = DSettings.Default or Options[1] or "..."
                local Expanded = false

                local DropdownFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -4, 0, 40),
                    ClipsDescendants = true
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownFrame})
                local Stroke = Create("UIStroke", {Parent = DropdownFrame, Color = Theme.Outline, Thickness = 1})

                local Title = Create("TextLabel", {
                    Parent = DropdownFrame,
                    Text = DSettings.Title or DSettings.Name,
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Size = UDim2.new(0, 150, 0, 40),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SelectedLabel = Create("TextLabel", {
                    Parent = DropdownFrame,
                    Text = Current .. " ▼",
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme.TextDark,
                    TextSize = 13,
                    Size = UDim2.new(1, -170, 0, 40),
                    Position = UDim2.new(0, 150, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local DropBtn = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    Text = ""
                })

                local OptionList = Create("Frame", {
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, -24, 0, 0),
                    Position = UDim2.new(0, 12, 0, 45),
                    BackgroundTransparency = 1
                })
                local ListLayout = Create("UIListLayout", {Parent = OptionList, Padding = UDim.new(0, 5)})

                local function RefreshOptions()
                    for _, v in pairs(OptionList:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end

                    for _, opt in pairs(Options) do
                        local OptBtn = Create("TextButton", {
                            Parent = OptionList,
                            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
                            Size = UDim2.new(1, 0, 0, 30),
                            Text = opt,
                            Font = Enum.Font.Gotham,
                            TextColor3 = Theme.TextDark,
                            TextSize = 13,
                            AutoButtonColor = false
                        })
                        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptBtn})

                        OptBtn.MouseEnter:Connect(function()
                            TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Gradient1, TextColor3 = Color3.new(1,1,1)}):Play()
                        end)
                        
                        OptBtn.MouseLeave:Connect(function()
                            TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38), TextColor3 = Theme.TextDark}):Play()
                        end)

                        OptBtn.MouseButton1Click:Connect(function()
                            Current = opt
                            SelectedLabel.Text = Current .. " ▼"
                            Expanded = false
                            TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -4, 0, 40)}):Play()
                            if DSettings.Callback then DSettings.Callback(Current) end
                        end)
                    end
                end
                
                RefreshOptions()

                DropBtn.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    if Expanded then
                        local Count = #Options
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -4, 0, 50 + (Count * 35))}):Play()
                    else
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -4, 0, 40)}):Play()
                    end
                end)

                local Funcs = {}
                function Funcs:Set(v)
                    Current = v
                    SelectedLabel.Text = Current .. " ▼"
                    if DSettings.Callback then DSettings.Callback(Current) end
                end
                function Funcs:Refresh(newOpts)
                    Options = newOpts
                    RefreshOptions()
                end
                if Flag then MacLib.Flags[Flag] = Funcs end
                return Funcs
            end
            
            -- [INPUT]
            function SecFuncs:Input(ISettings, Flag)
                local InputFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1, -4, 0, 40)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = InputFrame})
                Create("UIStroke", {Parent = InputFrame, Color = Theme.Outline, Thickness = 1})
                
                local Title = Create("TextLabel", {
                    Parent = InputFrame,
                    Text = ISettings.Title or "Input",
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Size = UDim2.new(0, 100, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local InputBoxBg = Create("Frame", {
                    Parent = InputFrame,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
                    Size = UDim2.new(0, 140, 0, 26),
                    Position = UDim2.new(1, -150, 0.5, -13)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = InputBoxBg})
                
                local Box = Create("TextBox", {
                    Parent = InputBoxBg,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    Font = Enum.Font.Gotham,
                    Text = ISettings.Default or "",
                    PlaceholderText = ISettings.Placeholder or "Type...",
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                Box.FocusLost:Connect(function(enter)
                    if ISettings.Callback then ISettings.Callback(Box.Text, enter) end
                end)
            end

            return SecFuncs
        end
        return TabFuncs
    end
    return WindowFuncs
end

return MacLib
