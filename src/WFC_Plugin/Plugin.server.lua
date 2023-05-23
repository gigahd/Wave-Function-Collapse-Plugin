local ServerStorage = game:GetService("ServerStorage")
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
local TileAdderCloseButton = TileAdderFrame:WaitForChild("CloseButton")

local TileModelButton = TileModelFrame:WaitForChild("Button")

local TilesListFrame = MainFrame:WaitForChild("TilesList")

local TilesList = TilesListFrame:WaitForChild("List")
local TemplateTile = TilesListFrame:WaitForChild("TileTemplate")

local TileConnectionsFrame: Frame = MainFrame:WaitForChild("ConnectionsFrame")

local TileConnectionsList: Frame = TileConnectionsFrame:WaitForChild("List")
local TileConnectionsCloseButton: TextButton = TileConnectionsFrame:WaitForChild("CloseButton")

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

local tileConnectionsIsOpen = false
local tileConnected = nil


TileModelFrame.CurrentCamera = TileModelFrame.Camera

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

local function changeToPointIconOnHover(value: GuiBase)
	value.MouseEnter:Connect(function()
		mouse.Icon = pointCursor
	end)
	value.MouseLeave:Connect(function()
		mouse.Icon = normalCursor
	end)
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
			changeToPointIconOnHover(value)
		elseif value:IsA("Frame") then
			if (value:GetAttribute("Dark")) then
				changeDarkerBackGroundColor(value)
			else
				changeBackGroundColor(value)
			end
		end
	end
end

local function selectedIsValid(selected: {Instance}): boolean
	return selected and selected[1] and selected[1]:IsA("Model")
end

local function addModelToFrame(frame: ViewportFrame, model: Model)
	if frame:FindFirstChild("Model") then
		frame.Model:Destroy()
	end
	
	local modelSize = model:GetExtentsSize()
	local rootPart = model:FindFirstChild("TileRootPart")
	if rootPart == nil then
		rootPart = Instance.new("Part")
		rootPart.CanCollide = false
		rootPart.Transparency = 1
		rootPart.Name = "TileRootPart"
	end

	rootPart.Position = model:GetBoundingBox().Position - Vector3.new(0,modelSize.Y/2,0)
	rootPart.Size = Vector3.one
	rootPart.Parent = model

	model.PrimaryPart = rootPart
	model:PivotTo(CFrame.new())
	
	frame.CurrentCamera.CFrame = CFrame.new(Vector3.new(0,modelSize.X,0)) * frame.CurrentCamera.CFrame.Rotation
	model.Parent = frame
end

local function validTileConfig()
	if TileNameBox.Text == "" then
		return false
	end
	if TileModelFrame:FindFirstChild("Model") == nil then
		return false
	end
	for _, connection in pairs(TileConectionsFrame:GetChildren()) do
		if not connection:IsA("Frame") then continue end
		if connection.ConnectionType.Text == "" then
			return false
		end
	end
	return true

end

local function openConnectionsFrame(tileFrame: Frame, tile: Folder)
	if tileAdderIsOpen then return end

	tileConnectionsIsOpen = true
	tileConnected = tile

	local connections = tile:GetAttributes()
	for connectionType, connectionValue in pairs(connections) do
		TileConnectionsList[connectionType].ConnectionType.Text = connectionValue	
	end
	TileConnectionsFrame:TweenSize(UDim2.fromScale(.5,.5),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,.2,true)

	TileConnectionsFrame.Visible = true
end

local function closeConnectionsFrame()
	tileConnectionsIsOpen = false
	tileConnected = nil
	
	TileConnectionsFrame:TweenSize(UDim2.new(),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,.2,true, function()
		TileConnectionsFrame.Visible = false
	end)
	
end

local function addTileToList(Tile: Folder) 
	local TileFrame = TemplateTile:Clone()
	TileFrame.ModelFrame.CurrentCamera = TileFrame.ModelFrame.Camera

	addModelToFrame(TileFrame.ModelFrame, Tile.Model:Clone())

	TileFrame.Title.Text = Tile.Name
	local TileConnection = Instance.new("ObjectValue")
	TileConnection.Value = Tile
	TileConnection.Parent = TileFrame

	changeToPointIconOnHover(TileFrame.Connections)
	changeToPointIconOnHover(TileFrame.RemoveButton)

	TileFrame.Connections.MouseButton1Click:Connect(function()
		if tileConnectionsIsOpen then return end
		openConnectionsFrame(TileFrame, Tile)
	end)
	TileFrame.RemoveButton.MouseButton1Click:Connect(function()
		if tileConnectionsIsOpen and tileConnected == Tile then
			closeConnectionsFrame()
		end
		Tile:Destroy()
		TileFrame:Destroy()
	end)
	TileFrame.Parent = TilesList
	TileFrame.Visible = true
end

local function onTilesUpdate()
	local Tiles: Folder = ServerStorage.Tiles
	Tiles.ChildAdded:Connect(function(child)
		addTileToList(child)
	end)
	Tiles.ChildRemoved:Connect(function(child)
		for _, TileFrame in pairs(TilesList:GetChildren()) do
			if not TileFrame:IsA("Frame") then continue end
			
			if TileFrame.Value.Value == child then
				if tileConnectionsIsOpen and tileConnected == child then
					closeConnectionsFrame()
				end
				child:Destroy()
				TileFrame:Destroy()
			end
		end
	end)
end

local function addTile()
	local Tiles = ServerStorage:FindFirstChild("Tiles")
	if Tiles == nil then 
		Tiles = Instance.new("Folder")
		Tiles.Name = "Tiles"
		Tiles.Parent = ServerStorage
		onTilesUpdate()
	end
	
	local Tile = Instance.new("Folder")
	Tile.Name = TileNameBox.Text
	for _, connection in pairs(TileConectionsFrame:GetChildren()) do
		if not connection:IsA("Frame") then continue end
		Tile:SetAttribute(connection.Name,connection.ConnectionType.Text)
	end
	TileModelFrame.Model.Parent = Tile
	Tile.Parent = Tiles
	addTileToList(Tile)
end

local function resetTileAdderFrame()
	if TileModelFrame:FindFirstChild("Model") then
		TileModelFrame.Model:Destroy()
	end
	TileModelButton.Text = "Model Preview"
	modelSelectionMode = false
	TileNameBox.Text = "Tile"
	for _, connection in pairs(TileConectionsFrame:GetChildren()) do
		if not connection:IsA("Frame") then continue end
		connection.ConnectionType.Text = "0"
	end
end

local function openTileAdder()
	if tileConnectionsIsOpen then return end
	
	TileAdderFrame:TweenPosition(UDim2.fromScale(.5,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.5,false)
end

local function closeTileAdder()
	resetTileAdderFrame()
	TileAdderFrame:TweenPosition(UDim2.fromScale(.5,-1),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.5,false)
end


TileAdderButton.MouseButton1Click:Connect(function()
	if (not tileAdderIsOpen) then
		tileAdderIsOpen = true
		openTileAdder() 
	end
end)

TileAdderCloseButton.MouseButton1Click:Connect(function()
	if tileAdderIsOpen then 
		tileAdderIsOpen = false
		closeTileAdder() 
	end
end)

AddTileButton.MouseButton1Click:Connect(function()
	if tileAdderIsOpen then
		if validTileConfig() then
			addTile()
			tileAdderIsOpen = false
			closeTileAdder() 
		else
			AddTileButton.BackgroundColor3 = Color3.fromRGB(164, 0, 0)
			task.wait(.5)
			changeButtonColor(AddTileButton)
		end
	end
end)

function selectModel(selected)
	if selectedIsValid(selected) then
		modelSelectionMode = false
		

		local model: Model = selected[1]:Clone()
		
		addModelToFrame(TileModelFrame, model)

		model.Name = "Model"
		TileModelButton.Text = ""
		return true
	end
	return false
end

TileModelButton.MouseButton1Click:Connect(function()
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

	selectModel(Selection:Get())
end)

Selection.SelectionChanged:Connect(function()
	if not modelSelectionMode then return end

	selectModel(Selection:Get())
	
end)

TileConnectionsCloseButton.MouseButton1Click:Connect(function()
	closeConnectionsFrame()
end)

for _, connection in pairs(TileConnectionsList:GetChildren()) do
	if not connection:IsA("Frame") then continue end

	connection.ConnectionType.Changed:Connect(function()
		if tileConnected ~= nil and connection.ConnectionType.Text ~= "" then
			tileConnected:SetAttribute(connection.Name, connection.ConnectionType.Text)
		end
	end)
end

widget.Title = "WFC Plugin"

changeColor()
MainFrame.Parent = widget

if ServerStorage:FindFirstChild("Tiles") then
	for _, tile in pairs(ServerStorage.Tiles:GetChildren()) do
		addTileToList(tile)
	end
	onTilesUpdate()
end

Studio.Changed:Connect(function()
	changeColor()
end)

pluginButton.Click:Connect(function()
	local isOn = not widget.Enabled
    widget.Enabled = isOn
	pluginButton:SetActive(isOn)
end)


