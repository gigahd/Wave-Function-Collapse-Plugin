local Studio = settings():GetService("Studio")

local toolbar = plugin:CreateToolbar("WFC")

local MainFrame = script.Parent:WaitForChild("MainFrame")

local pluginButton = toolbar:CreateButton("WFC", "Generate Grids using WFC", "rbxassetid://6811954238")

local Theme = Studio.Theme

local info = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right, --From what side gui appears
	false, --Widget will be initially enabled
	false, --Don't overdrive previouse enabled state
	200, --default weight
	300, --default height
	150, --minimum weight (optional)
	150 --minimum height (optional)
)

local widget = plugin:CreateDockWidgetPluginGui(
"TestPlugin", --A unique and consistent identifier used to storing the widget’s dock state and other internal details
info --dock widget info
)

function changeTextColor(value: GuiBase)
	value.TextColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
end

function changeBackGroundColor(value: GuiBase)
	value.BackgroundColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
end

function changeButtonColor(value: GuiBase)
	value.BackgroundColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainButton)
end

local function changeColor()
	changeBackGroundColor(MainFrame)
	for index, value in MainFrame:GetDescendants() do
		
		if not value:IsA("GuiBase") then continue end

		if value:IsA("TextLabel") then
			changeTextColor(value)
			changeBackGroundColor()
		elseif value:IsA("TextButton") then
			changeTextColor(value)
			changeButtonColor(value)
		end
	end
end

widget.Title = "WFC Plugin"

changeColor()
MainFrame.Parent = widget


Studio.Changed:Connect(function()
	changeColor()
end)

pluginButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)