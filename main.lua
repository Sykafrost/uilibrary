local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Velonix = {}
Velonix.__index = Velonix

function Velonix:CreateWindow(options)
    local window = {}
    setmetatable(window, Velonix)

    window.Title = options.Title or "Velonix UI"
    window.Size = options.Size or UDim2.new(0, 500, 0, 300)
    window.Position = options.Position or UDim2.new(0.5, -window.Size.X.Offset / 2, 0.5, -window.Size.Y.Offset / 2)

    window.Tabs = {}
    window.TabButtons = {}
    window.CurrentTab = nil
    window.ActiveDropdown = nil

    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "Velonix_Library"
    window.ScreenGui.ResetOnSpawn = false
    window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    window.MainFrame = Instance.new("Frame")
    window.MainFrame.Name = "MainFrame"
    window.MainFrame.Size = window.Size
    window.MainFrame.Position = window.Position
    window.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    window.MainFrame.BorderSizePixel = 0
    window.MainFrame.Active = true
    window.MainFrame.Visible = true
    window.MainFrame.ClipsDescendants = true
    window.MainFrame.Parent = window.ScreenGui

    local corner = Instance.new("UICorner", window.MainFrame)
    corner.CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", window.MainFrame)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1

    local topBar = Instance.new("Frame", window.MainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    topBar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.fromOffset(10, 0)
    titleLabel.Text = window.Title
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    window.TabFrame = Instance.new("ScrollingFrame")
    window.TabFrame.Size = UDim2.new(0, 120, 1, -50)
    window.TabFrame.Position = UDim2.new(0, 5, 0, 45)
    window.TabFrame.ScrollBarThickness = 3
    window.TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    window.TabFrame.BackgroundTransparency = 1
    window.TabFrame.BorderSizePixel = 0
    window.TabFrame.Parent = window.MainFrame

    local tabLayout = Instance.new("UIListLayout", window.TabFrame)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function dragify(frame)
        local dragging, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, window.MainFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                local delta = input.Position - dragStart
                window.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    dragify(topBar)

    window.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return window
end

function Velonix:Toggle(bind)
    bind = bind or Enum.KeyCode.RightControl
    local visible = true
    self.MainFrame.Visible = visible
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == bind then
            visible = not visible
            self.MainFrame.Visible = visible
        end
    end)
end

function Velonix:CreateTab(tabName)
    local tabObject = {}
    tabObject.Window = self

    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName
    tabButton.Size = UDim2.new(1, 0, 0, 35)
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 15
    tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabFrame

    local content = Instance.new("ScrollingFrame")
    content.Name = tabName .. "_Content"
    content.Size = UDim2.new(1, -135, 1, -50)
    content.Position = UDim2.new(0, 130, 0, 45)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.BorderSizePixel = 0
    content.Visible = false
    content.Parent = self.MainFrame
    tabObject.Container = content

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    table.insert(self.Tabs, content)
    table.insert(self.TabButtons, tabButton)

    if not self.CurrentTab then
        self.CurrentTab = content
        content.Visible = true
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 0
    end

    tabButton.MouseButton1Click:Connect(function()
        if self.ActiveDropdown then
            self.ActiveDropdown:Destroy()
            self.ActiveDropdown = nil
        end
        for i, v in ipairs(self.Tabs) do
            v.Visible = false
            self.TabButtons[i].TextColor3 = Color3.fromRGB(150, 150, 150)
            self.TabButtons[i].BackgroundTransparency = 1
        end
        self.CurrentTab = content
        content.Visible = true
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 0
    end)

    local methods = {
        "Button", "Label", "Section", "Toggle", "TextBox", "Divider", "Slider", "Dropdown"
    }
    for _, method in ipairs(methods) do
        tabObject[method] = function(self, args)
            return Velonix[method](self, args)
        end
    end

    return tabObject
end

function Velonix:Button(tab, args)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = args.Title or "Button"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.BorderSizePixel = 0
    btn.Parent = tab.Container
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        pcall(args.Callback)
    end)
    return btn
end

function Velonix:Toggle(tab, args)
    local state = args.Value or false

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 0, 25)
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.TextSize = 14
    toggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleButton.BackgroundTransparency = 1
    toggleButton.TextXAlignment = Enum.TextXAlignment.Left
    toggleButton.Parent = tab.Container

    local function updateText()
        toggleButton.Text = (args.Title or "Toggle") .. " [" .. (state and "On" or "Off") .. "]"
    end
    updateText()

    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateText()
        pcall(args.Callback, state)
    end)
    return toggleButton
end

function Velonix:Slider(tab, args)
    local title = args.Title or "Slider"
    local min = args.Min or 0
    local max = args.Max or 100
    local default = args.Default or min
    local callback = args.Callback or function() end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = tab.Container

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 8)
    slider.Position = UDim2.new(0, 0, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    slider.BorderSizePixel = 0
    slider.Parent = container
    Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", slider)
    fill.BackgroundColor3 = Color3.fromRGB(100, 125, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local handle = Instance.new("Frame", slider)
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(0, 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

    local function updateSlider(percent)
        percent = math.clamp(percent, 0, 1)
        local value = math.floor(min + (max - min) * percent + 0.5)
        label.Text = title .. ": " .. tostring(value)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        handle.Position = UDim2.new(percent, 0, 0.5, 0)
        return value
    end

    updateSlider((default - min) / (max - min))

    local connection
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            local value = updateSlider(percent)
            pcall(callback, value)

            connection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                    local newPercent = (changedInput.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                    local newValue = updateSlider(newPercent)
                    pcall(callback, newValue)
                end
            end)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and connection then
            connection:Disconnect()
        end
    end)
    return container
end

function Velonix:Dropdown(tab, args)
    local title = args.Title or "Dropdown"
    local values = args.Values or {}
    local selected = {}
    local isMulti = args.Multi or false
    local allowNone = args.AllowNone or false
    local callback = args.Callback or function() end

    if args.Value then
        for _, v in ipairs(type(args.Value) == "table" and args.Value or {args.Value}) do
            if table.find(values, v) then
                table.insert(selected, v)
            end
        end
    end

    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, 0, 0, 35)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = tab.Container

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 14
    dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropdownButton.Parent = dropdownContainer
    Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 4)

    local function updateButtonText()
        local numSelected = #selected
        if numSelected == 0 then
            dropdownButton.Text = title .. ": None"
        elseif numSelected == 1 and not isMulti then
            dropdownButton.Text = title .. ": " .. selected[1]
        else
            dropdownButton.Text = title .. ": " .. numSelected .. " Selected"
        end
    end
    updateButtonText()
    
    local function closeDropdown()
        if tab.Window.ActiveDropdown then
            tab.Window.ActiveDropdown:Destroy()
            tab.Window.ActiveDropdown = nil
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        if tab.Window.ActiveDropdown then
            closeDropdown()
            return
        end

        local optionsFrame = Instance.new("ScrollingFrame")
        optionsFrame.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 120)
        optionsFrame.Position = UDim2.fromOffset(dropdownButton.AbsolutePosition.X, dropdownButton.AbsolutePosition.Y + dropdownButton.AbsoluteSize.Y + 5)
        optionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        optionsFrame.BorderSizePixel = 0
        optionsFrame.ScrollBarThickness = 3
        optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionsFrame.ZIndex = 100
        optionsFrame.Parent = tab.Window.MainFrame
        Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, 4)
        Instance.new("UIListLayout", optionsFrame).Padding = UDim.new(0, 2)
        
        tab.Window.ActiveDropdown = optionsFrame

        for _, optionName in ipairs(values) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, -4, 0, 30)
            optionButton.Position = UDim2.fromOffset(2, 0)
            optionButton.Text = "  " .. optionName
            optionButton.Font = Enum.Font.Gotham
            optionButton.TextSize = 14
            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            optionButton.TextXAlignment = Enum.TextXAlignment.Left
            optionButton.BackgroundTransparency = 1
            optionButton.Parent = optionsFrame
            Instance.new("UICorner", optionButton).CornerRadius = UDim.new(0, 4)
            
            if table.find(selected, optionName) then
                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.BackgroundTransparency = 0
            end

            optionButton.MouseEnter:Connect(function() optionButton.BackgroundTransparency = table.find(selected, optionName) and 0 or 0.5 end)
            optionButton.MouseLeave:Connect(function() optionButton.BackgroundTransparency = table.find(selected, optionName) and 0 or 1 end)

            optionButton.MouseButton1Click:Connect(function()
                local index = table.find(selected, optionName)
                if isMulti then
                    if index then
                        if #selected > 1 or allowNone then
                            table.remove(selected, index)
                        end
                    else
                        table.insert(selected, optionName)
                    end
                else
                    if index then
                        if allowNone then selected = {} end
                    else
                        selected = {optionName}
                    end
                    closeDropdown()
                end
                updateButtonText()
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local isSelected = table.find(selected, child.Text:sub(3))
                        child.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                        child.BackgroundTransparency = isSelected and 0 or 1
                    end
                end
                pcall(callback, isMulti and selected or selected[1])
            end)
        end
    end)
    return dropdownContainer
end

function Velonix:Section(tab, args)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = args.Title or "Section"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Container
    return label
end

function Velonix:Label(tab, args)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = args.Text or "Label"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Container
    return label
end

function Velonix:Divider(tab, args)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 1)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = tab.Container
    return frame
end

function Velonix:TextBox(tab, args)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 35)
    box.PlaceholderText = args.Placeholder or "..."
    box.Text = args.Default or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextColor3 = Color3.fromRGB(200, 200, 200)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    box.ClearTextOnFocus = args.ClearOnFocus or false
    box.Parent = tab.Container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            pcall(args.Callback, box.Text)
        end
    end)
    return box
end

return Velonix
