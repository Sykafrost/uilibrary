local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "Velonix_Library"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(127, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

local function dragify(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

dragify(mainFrame)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 0, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5

local tabFrame = Instance.new("ScrollingFrame", mainFrame)
tabFrame.Size = UDim2.new(0, 100, 1, -50)
tabFrame.Position = UDim2.new(0, 5, 0, 50)
tabFrame.ScrollBarThickness = 6
tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabFrame.BackgroundColor3 = Color3.fromRGB(127, 0, 0)
tabFrame.BackgroundTransparency = 0.5
tabFrame.ClipsDescendants = true
tabFrame.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", tabFrame)
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local settingsFrame = Instance.new("ScrollingFrame", mainFrame)
settingsFrame.Size = UDim2.new(0, 100, 1, -50)
settingsFrame.Position = UDim2.new(1, -105, 0, 50)
settingsFrame.ScrollBarThickness = 6
settingsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsFrame.BackgroundTransparency = 1
settingsFrame.ClipsDescendants = true
settingsFrame.BorderSizePixel = 0

local settingsLayout = Instance.new("UIListLayout", settingsFrame)
settingsLayout.Padding = UDim.new(0, 5)
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0.5, -20)
openBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
openBtn.Text = "Open"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.ZIndex = 1000
openBtn.Active = true

Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

local tabContainers = {}
local currentTab = nil
local activeDropdown = nil

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
end

function createLogo(imageId)
	local logo = Instance.new("ImageLabel", mainFrame)
	logo.Size = UDim2.new(0, 40, 0, 40)
	logo.Position = UDim2.new(0, 5, 0, 5)
	logo.Image = "rbxassetid://" .. tostring(imageId)
	logo.BackgroundTransparency = 1
	TweenService:Create(logo, TweenInfo.new(1), {ImageTransparency = 0}):Play()
end

function createWindow(titleText, textSize)
	local title = Instance.new("TextLabel", mainFrame)
	title.Size = UDim2.new(0, 200, 0, 40)
	title.Position = UDim2.new(0, 50, 0, 5)
	title.Text = titleText
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = textSize or 24
	title.TextColor3 = Color3.fromRGB(0, 0, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
end

function createTab(name, tabIndex)
	local tab = Instance.new("TextButton")
	tab.Name = name
	tab.Size = UDim2.new(1, -10, 0, 40)
	tab.Text = name
	tab.Font = Enum.Font.SourceSansBold
	tab.TextSize = 20
	tab.TextColor3 = Color3.fromRGB(0, 0, 255)
	tab.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	tab.BackgroundTransparency = 0.3
	tab.BorderSizePixel = 0
	tab.Parent = tabFrame
	addCorner(tab, 8)

	local content = Instance.new("ScrollingFrame")
	content.Name = tostring(tabIndex)
	content.Size = UDim2.new(0, 280, 1, -60)
	content.Position = UDim2.new(0, 110, 0, 50)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 6
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Visible = false
	content.Parent = mainFrame
	addCorner(content, 8)

	local layout = Instance.new("UIListLayout", content)
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	tab.MouseButton1Click:Connect(function()
        if activeDropdown then
            activeDropdown:Destroy()
            activeDropdown = nil
        end
		if currentTab then currentTab.Visible = false end
		currentTab = content
		currentTab.Visible = true
	end)

	tabContainers[tabIndex] = {frame = content}
end

function createButton(name, tabIndex, callback)
	local container = tabContainers[tabIndex]
	if not container then return end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Text = name
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	btn.TextColor3 = Color3.fromRGB(0, 0, 255)
	btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Parent = container.frame
	btn.MouseButton1Click:Connect(callback)
	addCorner(btn, 8)
end

function createLabel(text, tabIndex)
	local container = tabContainers[tabIndex]
	if not container then return end
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 30)
	label.Text = text
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = container.frame
end

function createSection(name, tabIndex)
	local container = tabContainers[tabIndex]
	if not container then return end
	local section = Instance.new("TextLabel")
	section.Size = UDim2.new(1, -10, 0, 30)
	section.Text = "-- " .. name
	section.Font = Enum.Font.SourceSansBold
	section.TextSize = 18
	section.TextColor3 = Color3.fromRGB(0, 200, 255)
	section.BackgroundTransparency = 1
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.Parent = container.frame
end

function createNotify(title, desc)
	game.StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = desc,
		Duration = 5
	})
end

function createNotify2(title, desc, duration)
	game.StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = desc,
		Duration = duration or 10
	})
end

function createSettingButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Text = name
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(0, 0, 255)
	btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.MouseButton1Click:Connect(callback)
	btn.Parent = settingsFrame
	addCorner(btn, 8)
end

function createToggle(name, tabIndex, default, callback)
    local container = tabContainers[tabIndex]
    if not container then return end
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, -10, 0, 40)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 18
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    toggle.BackgroundTransparency = 0.2
    toggle.BorderSizePixel = 0

    local state = default
    toggle.Text = name .. ": " .. (state and "ON" or "OFF")
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
    
    toggle.Parent = container.frame
    addCorner(toggle, 8)
end

function createTextBox(tabIndex, placeholderText, callback)
    local container = tabContainers[tabIndex]
    if not container then return end
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 35)
    box.PlaceholderText = placeholderText
    box.Font = Enum.Font.SourceSans
    box.TextSize = 16
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.BackgroundTransparency = 0.1
    box.ClearTextOnFocus = false
    box.Text = ""
    box.BorderSizePixel = 0

    box.FocusLost:Connect(function(enter)
        if enter then
            callback(box.Text)
        end
    end)

    box.Parent = container.frame
    addCorner(box, 8)
end

function createDivider(tabIndex)
    local container = tabContainers[tabIndex]
    if not container then return end
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -10, 0, 2)
    divider.BackgroundColor3 = Color3.new(1, 1, 1)
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    divider.Parent = container.frame
end

function createSlider(tabIndex, title, min, max, default, callback)
	local container = tabContainers[tabIndex]
	if not container then return end

	local sliderContainer = Instance.new("Frame")
	sliderContainer.Size = UDim2.new(1, -10, 0, 40)
	sliderContainer.BackgroundTransparency = 1
	sliderContainer.Parent = container.frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Text = title .. ": " .. tostring(default)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BorderSizePixel = 0
	label.Parent = sliderContainer

	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, 0, 0, 20)
	slider.Position = UDim2.new(0, 0, 0, 20)
	slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	slider.BorderSizePixel = 0
	slider.Parent = sliderContainer
	addCorner(slider, 100)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = slider
	addCorner(fill, 100)

	local function updateSlider(inputPos)
		local relativeX = inputPos.X - slider.AbsolutePosition.X
		local percent = math.clamp(relativeX / slider.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * percent + 0.5)

		fill.Size = UDim2.new(percent, 0, 1, 0)
		label.Text = title .. ": " .. tostring(value)

		if callback then
			pcall(callback, value)
		end
	end

	local connection = nil
	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			updateSlider(input.Position)
			connection = UserInputService.InputChanged:Connect(function(changedInput)
				if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
					updateSlider(changedInput.Position)
				end
			end)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end)
end

function createDropdown(tabIndex, name, options, callback)
	local container = tabContainers[tabIndex]
	if not container then return end

	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Size = UDim2.new(1, -10, 0, 40)
	dropdownButton.Font = Enum.Font.SourceSansBold
	dropdownButton.TextSize = 16
	dropdownButton.TextColor3 = Color3.new(1, 1, 1)
	dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	dropdownButton.Text = name .. ": " .. (options[1] or "")
	dropdownButton.Parent = container.frame
	addCorner(dropdownButton, 8)

	local function closeDropdown()
		if activeDropdown then
			activeDropdown:Destroy()
			activeDropdown = nil
		end
	end

	dropdownButton.MouseButton1Click:Connect(function()
		if activeDropdown then
			closeDropdown()
			return
		end
        
		local optionsFrame = Instance.new("ScrollingFrame")
		optionsFrame.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 120)
		optionsFrame.Position = UDim2.fromOffset(dropdownButton.AbsolutePosition.X, dropdownButton.AbsolutePosition.Y + dropdownButton.AbsoluteSize.Y)
		optionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		optionsFrame.BorderSizePixel = 0
		optionsFrame.ScrollBarThickness = 4
		optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		optionsFrame.ZIndex = 10
		optionsFrame.Parent = gui
		addCorner(optionsFrame, 6)

		activeDropdown = optionsFrame

		local listLayout = Instance.new("UIListLayout", optionsFrame)
		listLayout.Padding = UDim.new(0, 2)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder

		for _, optionName in ipairs(options) do
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(1, 0, 0, 30)
			optionButton.Text = optionName
			optionButton.Font = Enum.Font.SourceSans
			optionButton.TextSize = 14
			optionButton.TextColor3 = Color3.new(1, 1, 1)
			optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			optionButton.BackgroundTransparency = 1
			optionButton.Parent = optionsFrame

			optionButton.MouseEnter:Connect(function()
				optionButton.BackgroundTransparency = 0.8
			end)
			optionButton.MouseLeave:Connect(function()
				optionButton.BackgroundTransparency = 1
			end)

			optionButton.MouseButton1Click:Connect(function()
				dropdownButton.Text = name .. ": " .. optionName
				if callback then
					pcall(callback, optionName)
				end
				closeDropdown()
			end)
		end
	end)
end
