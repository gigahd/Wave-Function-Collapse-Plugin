local Studio = settings():GetService("Studio")
local Selection = game:GetService("Selection")

local toolbar = plugin:CreateToolbar("WFC")
local mouse = plugin:GetMouse()

local MainFrame = script.Parent:WaitForChild("MainFrame")
local OptionsBar = MainFrame:WaitForChild("Options")
local TileAdderButton = OptionsBar:WaitForChild("Title"):WaitForChild("AddTile")

local TileAdderFrame = MainFrame:WaitForChild("AddTiles")
local AddTileButton = TileAdderFrame:WaitForChild("GenerateFrame"):WaitForChild("Generate")
local TileNameBox = TileAdderFrame:WaitForChild("TileName")
local TileModelFrame = TileAdderFrame:WaitForChild("ModelFrame")
local TileConectionsFrame = TileAdderFrame:WaitForChild("Connections")

local TileModelButton = TileModelFrame:WaitForChild("Button")

local pluginButton = toolbar:CreateButton("WFC", "Generate Grids using WFC", "rbxassetid://6811954238")

local Theme = Studio.Theme

local pointCursor = "rbxasset://SystemCursors/PointingHand"
local normalCursor = "rbxasset://SystemCursors/Arrow"

local info = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right, --From what side gui appears
	false, --Widget will be initially enabled
	false, --Don't overdrive previouse enabled state
	200, --default weight
	300, --default height
	150, --minimum weight (optional)
	150 --minimum height (optional)
)

local tileAdderIsOpen = false
local modelSelectionMode = false

local widget = plugin:CreateDockWidgetPluginGui(
"TestPlugin", --A unique and consistent identifier used to storing the widget’s dock state and other internal details
info --dock widget info
)

local function changeTextColor(value: GuiBase)
	value.TextColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
end

local function changeBackGroundColor(value: GuiBase)
	value.BackgroundColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
end

local function changeDarkerBackGroundColor(value: GuiBase)
	local color = Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	value.BackgroundColor3 = Color3.new(color.r/1.2,color.g/1.2,color.b/1.2)
end

local function changeButtonColor(value: GuiBase)
	value.BackgroundColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainButton)
end

local function changeColor()
	changeBackGroundColor(MainFrame)
	
	for _, value in MainFrame:GetDescendants() do
		if not value:IsA("GuiBase") then continue end
		if value:IsA("TextLabel") or value:IsA("TextBox") then
			changeTextColor(value)
			changeDarkerBackGroundColor(value)
		elseif value:IsA("TextButton") then
			changeTextColor(value)
			changeButtonColor(value)
			value.MouseEnter:Connect(function()
				mouse.Icon = pointCursor
			end)
			value.MouseLeave:Connect(function()
				mouse.Icon = normalCursor
			end)
		elseif value:IsA("Frame") then
			if (value:GetAttribute("Dark")) then
				changeDarkerBackGroundColor(value)
			else
				changeBackGroundColor(value)
			end
		end
	end
end



local function addTile()
	
end

local function openTileAdder()
	--TileModelFrame = Instance.new("Frame")
	TileAdderFrame:TweenPosition(UDim2.fromScale(.5,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.5,false)
end

local function closeTileAdder()
	TileAdderFrame:TweenPosition(UDim2.fromScale(.5,-1),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.5,false)
end


TileAdderButton.MouseButton1Click:Connect(function()
	if (not tileAdderIsOpen) then
		tileAdderIsOpen = true
		openTileAdder() 
	end
end)

AddTileButton.MouseButton1Click:Connect(function()
	if tileAdderIsOpen then 
		tileAdderIsOpen = false
		closeTileAdder() 
	end
end)

function selectModel(selected)
	if selected and selected[1] and selected[1]:IsA("Model") then
		modelSelectionMode = false
		local model = selected[1]:Clone()
		model.Name = "Model"
		model.Parent = TileModelFrame
		TileModelButton.Text = ""
	end
end

TileModelButton.MouseButton1Click:Connect(function()
	local Selected = Selection:Get()
	if not selectModel(Selection:Get()) then end
	if modelSelectionMode then
		modelSelectionMode = false
		if TileModelFrame:FindFirstChild("Model") then
			TileModelButton.Text = ""
		else
			TileModelButton.Text = "Model Preview"
		end
	else
		TileModelButton.Text = "Select Model"
		modelSelectionMode = true
	end

end)

Selection.SelectionChanged:Connect(function()
	if not modelSelectionMode then return end

	selectModel(Selection:Get())
	
end)

widget.Title = "WFC Plugin"

changeColor()
MainFrame.Parent = widget


Studio.Changed:Connect(function()
	changeColor()
end)

pluginButton.Click:Connect(function()
	local isOn = not widget.Enabled
    widget.Enabled = isOn
	pluginButton:SetActive(isOn)
end)


