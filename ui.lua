local cloneref = cloneref or function(ref)
	return ref;
end
local GetService = game.GetService
local Services = setmetatable({}, {
    __index = function(self, Property)
        local Good, Service = pcall(GetService, game, Property);
        if (Good) then
            self[Property] = cloneref(Service);
            return Service
        end
    end
});

local GetPlayers = Services.Players.GetPlayers
local JSONEncode, JSONDecode, GenerateGUID = 
    Services.HttpService.JSONEncode, 
    Services.HttpService.JSONDecode,
    Services.HttpService.GenerateGUID

local GetPropertyChangedSignal, Changed = 
    game.GetPropertyChangedSignal,
    game.Changed

local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local IsA = game.IsA
local FindFirstChild, FindFirstChildWhichIsA, WaitForChild = 
    game.FindFirstChild,
    game.FindFirstChildWhichIsA,
    game.WaitForChild

local Tfind, sort, concat, pack, unpack;
do
    local table = table
    Tfind, sort, concat, pack, unpack = 
        table.find, 
        table.sort,
        table.concat,
        table.pack,
        table.unpack
end

local lower, Sfind, split, sub, format, len, match, gmatch, gsub, byte;
do
    local string = string
    lower, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
        string.lower,
        string.find,
        string.split, 
        string.sub,
        string.format,
        string.len,
        string.match,
        string.gmatch,
        string.gsub,
        string.byte
end

local random, floor, round, abs, atan, cos, sin, rad;
do
    local math = math
    random, floor, round, abs, atan, cos, sin, rad, clamp = 
        math.random,
        math.floor,
        math.round,
        math.abs,
        math.atan,
        math.cos,
        math.sin,
        math.rad,
        math.clamp
end

local Instancenew = Instance.new
local Vector3new = Vector3.new
local Vector2new = Vector2.new
local UDim2new = UDim2.new
local UDimnew = UDim.new
local CFramenew = CFrame.new
local BrickColornew = BrickColor.new
local Drawingnew = Drawing.new
local Color3new = Color3.new
local Color3fromRGB = Color3.fromRGB
local Color3fromHSV = Color3.fromHSV
local ToHSV = Color3new().ToHSV

local Camera = Services.Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget

local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer.GetMouse(LocalPlayer);

local Destroy, Clone = game.Destroy, game.Clone

local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect

local Disconnect;
do
    local CalledConnection = CConnect(Connection, function() end);
    Disconnect = CalledConnection.Disconnect
end

local Connections = {}
local AddConnection = function(...)
    local ConnectionsToAdd = {...}
    for i = 1, #ConnectionsToAdd do
        Connections[#Connections + 1] = ConnectionsToAdd[i]
    end
    return ...
end

local UIElements = Services.InsertService:LoadLocalAsset("rbxassetid://6945229203");
local GuiObjects = UIElements.GuiObjects

local Colors = {
	PageTextPressed = Color3fromRGB(200, 200, 200);
	PageBackgroundPressed = Color3fromRGB(15, 15, 15);
	PageBorderPressed = Color3fromRGB(20, 20, 20);
	PageTextHover = Color3fromRGB(175, 175, 175);
	PageBackgroundHover = Color3fromRGB(16, 16, 16);
	PageTextIdle = Color3fromRGB(150, 150, 150);
	PageBackgroundIdle = Color3fromRGB(18, 18, 18);
	PageBorderIdle = Color3fromRGB(18, 18, 18);
	ElementBackground = Color3fromRGB(25, 25, 25);
}

local Debounce = function(Func)
	local Debounce_ = false
	return function(...)
		if (not Debounce_) then
			Debounce_ = true
			Func(...);
			Debounce_ = false
		end
	end
end


local Utils = {}

Utils.SmoothScroll = function(content, SmoothingFactor)
	content.ScrollingEnabled = false

	local input = Clone(content);

	input.ClearAllChildren(input);
	input.BackgroundTransparency = 1
	input.ScrollBarImageTransparency = 1
	input.ZIndex = content.ZIndex + 1
	input.Name = "_smoothinputframe"
	input.ScrollingEnabled = true
	input.Parent = content.Parent

	local function syncProperty(prop)
        AddConnection(CConnect(GetPropertyChangedSignal(content, prop), function()
			if prop == "ZIndex" then
				input[prop] = content[prop] + 1
			else
				input[prop] = content[prop]
			end
		end));
	end

	syncProperty "CanvasSize"
	syncProperty "Position"
	syncProperty "Rotation"
	syncProperty "ScrollingDirection"
	syncProperty "ScrollBarThickness"
	syncProperty "BorderSizePixel"
	syncProperty "ElasticBehavior"
	syncProperty "SizeConstraint"
	syncProperty "ZIndex"
	syncProperty "BorderColor3"
	syncProperty "Size"
	syncProperty "AnchorPoint"
	syncProperty "Visible"

	local smoothConnection = AddConnection(CConnect(Services.RunService.RenderStepped, function()
		local a = content.CanvasPosition
		local b = input.CanvasPosition
		local c = SmoothingFactor
		local d = (b - a) * c + a

		content.CanvasPosition = d
	end));

	AddConnection(CConnect(content.AncestryChanged, function()
		if content.Parent == nil then
			Destroy(input);
			Disconnect(smoothConnection);
		end
	end));
end

do
    local TweenService = Services.TweenService
    Utils.Tween = function(Object, Style, Direction, Time, Goal)
        local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
        local Tween = TweenService.Create(TweenService, Object, TInfo, Goal)
        Tween.Play(Tween);
        return Tween
    end
end

Utils.MultColor3 = function(Color, Delta)
	return Color3new(clamp(Color.R * Delta, 0, 1), clamp(Color.G * Delta, 0, 1), clamp(Color.B * Delta, 0, 1))
end

Utils.Draggable = function(UI, DragUi)
	local DragSpeed = 0
	local StartPos
	local DragToggle, DragInput, DragStart

	if not DragUi then
		DragUi = UI
	end

	local function UpdateInput(Input)
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y);

		Utils.Tween(UI, "Linear", "Out", .25, {
			Position = Position
		});
	end
    local CoreGui = Services.CoreGui
    local UserInputService = Services.UserInputService

	AddConnection(CConnect(UI.InputBegan, function(Input)
		if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not UserInputService.GetFocusedTextBox(UserInputService)) then
			DragToggle = true
			DragStart = Input.Position
			StartPos = UI.Position

			local Objects = CoreGui.GetGuiObjectsAtPosition(CoreGui, DragStart.X, DragStart.Y);

			AddConnection(CConnect(Input.Changed, function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					DragToggle = false
				end
			end));
		end
	end));

	AddConnection(CConnect(UI.InputChanged, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			DragInput = Input
		end
	end));

	AddConnection(CConnect(UserInputService.InputChanged, function(Input)
		if (Input == DragInput and DragToggle) then
			UpdateInput(Input);
		end
	end));
end

Utils.Click = function(Object, Goal)
	local Hover = {
		[Goal] = Utils.MultColor3(Object[Goal], 0.9);
	}

	local Press = {
		[Goal] = Utils.MultColor3(Object[Goal], 1.2);
	}

	local Origin = {
		[Goal] = Object[Goal]
	}

	AddConnection(CConnect(Object.MouseEnter, function()
		Utils.Tween(Object, "Quad", "Out", .25, Hover);
	end))

	AddConnection(CConnect(Object.MouseLeave, function()
		Utils.Tween(Object, "Quad", "Out", .25, Origin);
	end));

	AddConnection(CConnect(Object.MouseButton1Down, function()
		Utils.Tween(Object, "Quad", "Out", .3, Press);
	end));

    AddConnection(CConnect(Object.MouseButton1Up, function()
		Utils.Tween(Object, "Quad", "Out", .4, Hover);
	end));
end

Utils.Hover = function(Object, Goal)
	local Hover = {
		[Goal] = Utils.MultColor3(Object[Goal], 0.9);
	}

	local Origin = {
		[Goal] = Object[Goal]
	}

	AddConnection(CConnect(Object.MouseEnter, function()
		Utils.Tween(Object, "Sine", "Out", .5, Hover);
	end));

	AddConnection(CConnect(Object.MouseLeave, function()
		Utils.Tween(Object, "Sine", "Out", .5, Origin);
	end));
end

Utils.Blink = function(Object, Goal, Color1, Color2, Time)
	local Normal = {
		[Goal] = Color1
	}

	local Blink = {
		[Goal] = Color2
	}

	CThread(function()
		local T1 = Utils.Tween(Object, "Quad", "Out", Time, Blink).Completed
        T1.Wait(T1);
        local T2 = Utils.Tween(Object, "Quad", "Out", Time, Normal);
	end)()
end

Utils.TweenTrans = function(Object, Transparency)
	local Properties = {
		TextBox = "TextTransparency",
		TextLabel = "TextTransparency",
		TextButton = "TextTransparency",
		ImageButton = "ImageTransparency",
		ImageLabel = "ImageTransparency"
	}

    local Descendants = GetDescendants(Object);
	for i = 1, #Descendants do
        local Instance_ = Descendants[i]
		if (IsA(Instance_, "GuiObject")) then
			for Class, Property in next, Properties do
				if (IsA(Instance_, Class) and Instance_[Property] ~= 1) then
					Utils.Tween(Instance_, "Quad", "Out", .5, {
						[Property] = Transparency
					});
					break
				end
			end
			if Instance_.Name == "Overlay" and Transparency == 0 then -- check for overlay
				Utils.Tween(Object, "Quad", "Out", .5, {
					BackgroundTransparency = .5
				});
			elseif (Instance_.BackgroundTransparency ~= 1) then
				Utils.Tween(Instance_, "Quad", "Out", .5, {
					BackgroundTransparency = Transparency
				});
			end
		end
	end

	return Utils.Tween(Object, "Quad", "Out", .5, {
		BackgroundTransparency = Transparency
	});
end

Utils.Intro = function(Object)
	local Frame = Instancenew("Frame")
	local UICorner = Instancenew("UICorner")
	local CornerRadius = Object:FindFirstChild("UICorner") and Object.UICorner.CornerRadius or UDim.new(0, 0)

	Frame.Name = "IntroFrame"
	Frame.ZIndex = 1000
	Frame.Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.Position = UDim2.new(Object.Position.X.Scale, Object.Position.X.Offset + (Object.AbsoluteSize.X / 2), Object.Position.Y.Scale, Object.Position.Y.Offset + (Object.AbsoluteSize.Y / 2))
	Frame.BackgroundColor3 = Object.BackgroundColor3
	Frame.BorderSizePixel = 0

	UICorner.CornerRadius = CornerRadius
	UICorner.Parent = Frame

	Frame.Parent = Object.Parent

	if (Object.Visible) then
		Frame.BackgroundTransparency = 1

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 0
		});

        CWait(Tween.Completed);
		Object.Visible = false

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2.fromOffset(0, 0);
		});

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = UDimnew(1, 0);
		});

		CWait(Tween.Completed);
		Destroy(Frame);
	else
		Frame.Visible = true
		Frame.Size = UDim2.fromOffset(0, 0)
		UICorner.CornerRadius = UDimnew(1, 0)

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y);
		});

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = CornerRadius
		});

		CWait(Tween.Completed);
		Object.Visible = true

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 1
		});

		CWait(Tween.Completed);
		Destroy(Frame);
	end
end

Utils.MakeGradient = function(ColorTable)
	local Table = {}
    local ColorSequenceKeypointNew = ColorSequenceKeypoint.new
	for Time, Color in next, ColorTable do
		Table[#Table + 1] = ColorSequenceKeypointNew(Time - 1, Color);
	end
	return ColorSequence.new(Table)
end

local UILibrary = {}
UILibrary.__index = UILibrary

UILibrary.new = function(ColorTheme)
	assert(typeof(ColorTheme) == "Color3", "[UI] ColorTheme must be a Color3.");
	local NewUI = {}
	local UI = Instancenew("ScreenGui");
	setmetatable(NewUI, UILibrary);
	NewUI.UI = UI
	NewUI.ColorTheme = ColorTheme
	
	return NewUI
end

function UILibrary:LoadWindow(Title, Size)
	local Window = Clone(GuiObjects.Load.Window);
	local Main = Window.Main
	local Overlay = Main.Overlay
	local OverlayMain = Overlay.Main
	local ColorPicker = OverlayMain.ColorPicker
	local Settings = OverlayMain.Settings
	local ClosePicker = OverlayMain.Close
	local ColorCanvas = ColorPicker.ColorCanvas
	local ColorSlider = ColorPicker.ColorSlider
	local ColorGradient = ColorCanvas.ColorGradient
	local DarkGradient = ColorGradient.DarkGradient
	local CanvasBar = ColorGradient.Bar
	local RainbowGradient = ColorSlider.RainbowGradient
	local SliderBar = RainbowGradient.Bar
	local CanvasHitbox = ColorCanvas.Hitbox
	local SliderHitbox = ColorSlider.Hitbox
	local ColorPreview = Settings.ColorPreview
	local ColorOptions = Settings.Options
	local RedTextBox = ColorOptions.Red.TextBox
	local BlueTextBox = ColorOptions.Blue.TextBox
	local GreenTextBox = ColorOptions.Green.TextBox
	local RainbowToggle = ColorOptions.Rainbow
	Utils.Click(OverlayMain.Close, "BackgroundColor3");

	Window.Size = Size
	Window.Position = UDim2new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2);
	Window.Main.Title.Text = Title
	Window.Parent = self.UI

	Utils.Draggable(Window);

	local Idle = false
	local LeftWindow = false
	local Timer = tick();
	AddConnection(CConnect(Window.MouseEnter, function()
		LeftWindow = false
		if Idle then
			Idle = false
			Utils.TweenTrans(Window, 0)
		end
	end));
	AddConnection(CConnect(Window.MouseLeave, function()
		LeftWindow = true
		Timer = tick();
	end))

	AddConnection(CConnect(Services.RunService.RenderStepped, function()
		if LeftWindow then
			local Time = tick() - Timer
			if Time >= 3 and not Idle then
				Utils.TweenTrans(Window, .75);
				Idle = true
			end
		end
	end));


	local WindowLibrary = {}
	local PageCount = 0
	local SelectedPage

	WindowLibrary.GetPosition = function()
		return Window.Position
	end
	WindowLibrary.SetPosition = function(NewPos)
		Window.Position = NewPos
	end

	function WindowLibrary.NewPage(Title)
		local Page = Clone(GuiObjects.New.Page);
		local TextButton = Clone(GuiObjects.New.TextButton);

		if (PageCount == 0) then
			TextButton.TextColor3 = Colors.PageTextPressed
			TextButton.BackgroundColor3 = Colors.PageBackgroundPressed
			TextButton.BorderColor3 = Colors.PageBorderPressed
			SelectedPage = Page
		end

		AddConnection(CConnect(TextButton.MouseEnter, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextHover;
					BackgroundColor3 = Colors.PageBackgroundHover;
					BorderColor3 = Colors.PageBorderHover;
				});
			end
		end));

		AddConnection(CConnect(TextButton.MouseLeave, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextIdle;
					BackgroundColor3 = Colors.PageBackgroundIdle;
					BorderColor3 = Colors.PageBackgroundIdle;
				});
			end
		end));

		AddConnection(CConnect(TextButton.MouseButton1Down, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextPressed;
				});
			end
		end));

		AddConnection(CConnect(TextButton.MouseButton1Click, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextPressed;
					BackgroundColor3 = Colors.PageBackgroundPressed;
					BorderColor3 = Colors.PageBorderPressed;
				});

				Utils.Tween(Window.Main.Selection[SelectedPage.Name], "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextIdle;
					BackgroundColor3 = Colors.PageBackgroundIdle;
					BorderColor3 = Colors.PageBackgroundIdle;
				});

				SelectedPage = Page
				Window.Main.Container.UIPageLayout:JumpTo(SelectedPage)
			end
		end));


		Page.Name = Title
		TextButton.Name = Title
		TextButton.Text = Title

		Page.Parent = Window.Main.Container
		TextButton.Parent = Window.Main.Selection

		PageCount = PageCount + 1

		local PageLibrary = {}

		function PageLibrary.NewSection(Title)
			local Section = GuiObjects.Section.Container:Clone()
			local SectionOptions = Section.Options
			local SectionUIListLayout = Section.Options.UIListLayout

			-- Utils.SmoothScroll(Section.Options, .14)
			Section.Title.Text = Title
			Section.Parent = Page.Selection

			AddConnection(CConnect(GetPropertyChangedSignal(SectionUIListLayout, "AbsoluteContentSize"), function()
				SectionOptions.CanvasSize = UDim2.fromOffset(0, SectionUIListLayout.AbsoluteContentSize.Y + 5)
			end))

			local ElementLibrary = {}


			local function ToggleFunction(Container, Enabled, Callback) -- fpr color picker
				local Switch = Container.Switch
				local Hitbox = Container.Hitbox
				Container.BackgroundColor3 = self.ColorTheme

				if (not Enabled) then
					Switch.Position = UDim2.fromOffset(2, 2);
					Container.BackgroundColor3 = Colors.ElementBackground
				end

				AddConnection(CConnect(Hitbox.MouseButton1Click, function()
					Enabled = not Enabled

					Utils.Tween(Switch, "Quad", "Out", .25, {
						Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
					});
					Utils.Tween(Container, "Quad", "Out", .25, {
						BackgroundColor3 = Enabled and self.ColorTheme or Colors.ElementBackground
					});

					Callback(Enabled);
				end));
			end


			function ElementLibrary.Toggle(Title, Enabled, Callback)
				local Toggle = Clone(GuiObjects.Elements.Toggle);
				local Container = Toggle.Container
				ToggleFunction(Container, Enabled, Callback);

				Toggle.Title.Text = Title
				Toggle.Parent = Section.Options
			end


			function ElementLibrary.Slider(Title, Args, Callback)
				local Slider = Clone(GuiObjects.Elements.Slider);
				local Container = Slider.Container
				local ContainerSliderBar = Container.SliderBar
				local BarFrame = ContainerSliderBar.BarFrame
				local Bar = BarFrame.Bar
				local Label = Bar.Label
				local Hitbox = Container.Hitbox

				Bar.BackgroundColor3 = self.ColorTheme
				Bar.Size = UDim2.fromScale(Args.Default / Args.Max, 1);
				Label.Text = tostring(Args.Default);
				Label.BackgroundTransparency = 1
				Label.TextTransparency = 1
				Container.Min.Text = tostring(Args.Min);
				Container.Max.Text = tostring(Args.Max);
				Slider.Title.Text = Title

				local Moving = false

				local function Update()
					local RightBound = BarFrame.AbsoluteSize.X
					local Position = clamp(Mouse.X - BarFrame.AbsolutePosition.X, 0, RightBound);
					local Value = Args.Min + (Args.Max - Args.Min) * (Position / RightBound) -- get difference then add min value, lol lerp

					Value = Value - (Value % Args.Step);
					Callback(Value);

					local Precent = Value / Args.Max
					local Size = UDim2.fromScale(Precent, 1);
					local Tween = Utils.Tween(Bar, "Linear", "Out", .05, {
						Size = Size
					});

					Label.Text = Value
					CWait(Tween.Completed);
				end

				AddConnection(CConnect(Hitbox.MouseButton1Down, function()
					Moving = true

					Utils.Tween(Label, "Quad", "Out", .25, {
						BackgroundTransparency = 0;
						TextTransparency = 0;
					});

					Update();
				end))

				AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input)
					if (Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving) then
						Moving = false

						Utils.Tween(Label, "Quad", "Out", .25, {
							BackgroundTransparency = 1;
							TextTransparency = 1;
						});
					end
				end));

				AddConnection(CConnect(Mouse.Move, Debounce(function()
					if Moving then
						Update()
					end
				end)))

				Slider.Parent = Section.Options
			end

			function ElementLibrary.ColorPicker(Title, DefaultColor, Callback)
				local SelectColor = Clone(GuiObjects.Elements.SelectColor);
				local CurrentColor = DefaultColor
				local Button = SelectColor.Button

				local H, S, V = DefaultColor.ToHSV(DefaultColor);
				local Opened = false
				local Rainbow = false

				local function UpdateText()
					RedTextBox.PlaceholderText = tostring(floor(CurrentColor.R * 255));
					GreenTextBox.PlaceholderText = tostring(floor(CurrentColor.G * 255));
					BlueTextBox.PlaceholderText = tostring(floor(CurrentColor.B * 255));
				end

				local function UpdateColor()
					H, S, V = CurrentColor.ToHSV(CurrentColor);

					SliderBar.Position = UDim2new(0, 0, H, 2);
					CanvasBar.Position = UDim2new(S, 2, 1 - V, 2);
					ColorGradient.UIGradient.Color = Utils.MakeGradient({
						[1] = Color3new(1, 1, 1);
						[2] = Color3fromHSV(H, 1, 1);
					});

					ColorPreview.BackgroundColor3 = CurrentColor
					UpdateText();
				end

				local function UpdateHue(Hue)
					SliderBar.Position = UDim2.new(0, 0, Hue, 2)
					ColorGradient.UIGradient.Color = Utils.MakeGradient({
						[1] = Color3.new(1, 1, 1);
						[2] = Color3.fromHSV(Hue, 1, 1);
					});

					ColorPreview.BackgroundColor3 = CurrentColor
					UpdateText();
				end

				local function ColorSliderInit()
					local Moving = false

					local function Update()
						if Opened and not Rainbow then
							local LowerBound = SliderHitbox.AbsoluteSize.Y
							local Position = math.clamp(Mouse.Y - SliderHitbox.AbsolutePosition.Y, 0, LowerBound);
							local Value = Position / LowerBound

							H = Value
							CurrentColor = Color3.fromHSV(H, S, V);
							ColorPreview.BackgroundColor3 = CurrentColor
							ColorGradient.UIGradient.Color = Utils.MakeGradient({
								[1] = Color3.new(1, 1, 1);
								[2] = Color3.fromHSV(H, 1, 1);
							});

							UpdateText();

							local Position = UDim2.new(0, 0, Value, 2)
							local Tween = Utils.Tween(SliderBar, "Linear", "Out", .05, {
								Position = Position
							});

							Callback(CurrentColor);
							CWait(Tween.Completed);
						end
					end

					AddConnection(CConnect(SliderHitbox.MouseButton1Down, function()
						Moving = true
						Update();
					end));

					AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input)
						if (Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving) then
							Moving = false
						end
					end));

					AddConnection(CConnect(Mouse.Move, Debounce(function()
						if Moving then
							Update();
						end
					end)));
				end
				local function ColorCanvasInit()
					local Moving = false

					local function Update()
						if Opened then
							local LowerBound = CanvasHitbox.AbsoluteSize.Y
							local YPosition = clamp(Mouse.Y - CanvasHitbox.AbsolutePosition.Y, 0, LowerBound)
							local YValue = YPosition / LowerBound
							local RightBound = CanvasHitbox.AbsoluteSize.X
							local XPosition = clamp(Mouse.X - CanvasHitbox.AbsolutePosition.X, 0, RightBound)
							local XValue = XPosition / RightBound

							S = XValue
							V = 1 - YValue

							CurrentColor = Color3.fromHSV(H, S, V);
							ColorPreview.BackgroundColor3 = CurrentColor
							UpdateText();

							local Position = UDim2.new(XValue, 2, YValue, 2);
							local Tween = Utils.Tween(CanvasBar, "Linear", "Out", .05, {
								Position = Position
							});
							Callback(CurrentColor);
							CWait(Tween.Completed);
						end
					end

					AddConnection(CConnect(CanvasHitbox.MouseButton1Down, function()
						Moving = true
						Update();
					end));

					AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
							Moving = false
						end
					end));

					AddConnection(CConnect(Mouse.Move, Debounce(function()
						if Moving then
							Update();
						end
					end)));
				end

				ColorSliderInit();
				ColorCanvasInit();

				AddConnection(CConnect(Button.MouseButton1Click, function()
					if not Opened then
						Opened = true
						UpdateColor();
						RainbowToggle.Container.Switch.Position = Rainbow and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2);
						RainbowToggle.Container.BackgroundColor3 = Rainbow and self.ColorTheme or Colors.ElementBackground
						Overlay.Visible = true
						OverlayMain.Visible = false
						Utils.Intro(OverlayMain);
					end
				end));

				AddConnection(CConnect(ClosePicker.MouseButton1Click, Debounce(function()
					Button.BackgroundColor3 = CurrentColor
					Utils.Intro(OverlayMain);
					Overlay.Visible = false
					Opened = false
				end)));

				AddConnection(CConnect(RedTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(RedTextBox.Text)
						if Number then
							Number = clamp(floor(Number), 0, 255);
							CurrentColor = Color3new(Number / 255, CurrentColor.G, CurrentColor.B);
							UpdateColor();
							RedTextBox.PlaceholderText = tostring(Number);
							Callback(CurrentColor);
						end
						RedTextBox.Text = ""
					end
				end));

				AddConnection(CConnect(GreenTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(GreenTextBox.Text)
						if Number then
							Number = clamp(floor(Number), 0, 255);
							CurrentColor = Color3new(CurrentColor.R, Number / 255, CurrentColor.B);
							UpdateColor();
							GreenTextBox.PlaceholderText = tostring(Number);
							Callback(CurrentColor);
						end
						GreenTextBox.Text = ""
					end
				end));

				AddConnection(CConnect(BlueTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(BlueTextBox.Text);
						if Number then
							Number = clamp(floor(Number), 0, 255);
							CurrentColor = Color3new(CurrentColor.R, CurrentColor.G, Number / 255);
							UpdateColor();
							BlueTextBox.PlaceholderText = tostring(Number);
							Callback(CurrentColor);
						end
						BlueTextBox.Text = ""
					end
				end));

				ToggleFunction(RainbowToggle.Container, false, function(Callback)
					if Opened then
						Rainbow = Callback
					end
				end);

				AddConnection(CConnect(Services.RunService.RenderStepped, function()
					if Rainbow then
						local Hue = (tick() / 5) % 1
						CurrentColor = Color3.fromHSV(Hue, S, V);

						if Opened then
							UpdateHue(Hue);
						end

						Button.BackgroundColor3 = CurrentColor
						Callback(CurrentColor);
					end
				end));

				Button.BackgroundColor3 = DefaultColor
				SelectColor.Title.Text = Title
				SelectColor.Parent = Section.Options
			end

			function ElementLibrary.Dropdown(Title, Options, Callback)
				local DropdownElement = GuiObjects.Elements.Dropdown.DropdownElement:Clone()
				local DropdownSelection = GuiObjects.Elements.Dropdown.DropdownSelection:Clone()
				local TextButton = GuiObjects.Elements.Dropdown.TextButton
				local Button = DropdownElement.Button
				local Opened = false
				local Size = (TextButton.Size.Y.Offset + 5) * #Options

				local function ToggleDropdown()
					Opened = not Opened

					if (Opened) then
						DropdownSelection.Frame.Visible = true
						DropdownSelection.Visible = true

						Utils.Tween(DropdownSelection, "Quad", "Out", .25, {
							Size = UDim2.new(1, -10, 0, Size)
						});
						Utils.Tween(DropdownElement.Button, "Quad", "Out", .25, {
							Rotation = 180
						});
					else
						Utils.Tween(DropdownElement.Button, "Quad", "Out", .25, {
							Rotation = 0
						});
						CWait(Utils.Tween(DropdownSelection, "Quad", "Out", .25, {
							Size = UDim2.new(1, -10, 0, 0)
						}).Completed);

						DropdownSelection.Frame.Visible = false
						DropdownSelection.Visible = false
					end
				end

				for _, v in next, Options do
					local Clone = Clone(TextButton);

					AddConnection(CConnect(Clone.MouseButton1Click, function()
						DropdownElement.Title.Text = Title .. ": " .. v
						Callback(v);
						ToggleDropdown();
					end));

					Utils.Click(Clone, "BackgroundColor3");
					Clone.Text = v
					Clone.Parent = DropdownSelection.Container
				end

				AddConnection(CConnect(Button.MouseButton1Click, ToggleDropdown));

				DropdownElement.Title.Text = Title
				DropdownSelection.Visible = false
				DropdownSelection.Frame.Visible = false
				DropdownSelection.Size = UDim2.new(1, -10, 0, 0)
				DropdownElement.Parent = Section.Options
				DropdownSelection.Parent = Section.Options
			end

			return ElementLibrary

		end

		return PageLibrary
	end

	return WindowLibrary
end

print("UI Loaded...");

return UILibrary
