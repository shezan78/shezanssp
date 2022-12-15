local Drawing = {}

local game = game
local GetService, FindFirstChild = game.GetService, game.FindFirstChild
local IsA = game.IsA
local Vector2new, Instancenew, UDim2new = Vector2.new, Instance.new, UDim2.new

local Workspace = GetService(game, "Workspace");
local Camera = FindFirstChild(Workspace, "Camera");
local CoreGui = GetService(game, "CoreGui");

local BaseDrawingProperties = setmetatable({
    Visible = false,
    Color = Color3.new(),
    Transparency = 0,
    Remove = function()
    end
}, {
    __add = function(tbl1, tbl2)
        local new = {}
        for i, v in next, tbl1 do
            new[i] = v
        end
        for i, v in next, tbl2 do
            new[i] = v
        end
        return new
    end
})

Drawing.new = function(Type, UI)
    UI = UI and IsA(UI, "ScreenGui") and UI or Instancenew("ScreenGui", CoreGui) or Instancenew("ScreenGui", CoreGui);

    if (Type == "Line") then
        local LineProperties = ({
            To = Vector2new(),
            From = Vector2new(),
            Thickness = 1,
        } + BaseDrawingProperties)

        local LineFrame = Instancenew("Frame");
        LineFrame.AnchorPoint = Vector2new(0.5, 0.5);
        LineFrame.BorderSizePixel = 0

        LineFrame.BackgroundColor3 = LineProperties.Color
        LineFrame.Visible = LineProperties.Visible
        LineFrame.BackgroundTransparency = LineProperties.Transparency


        LineFrame.Parent = UI

        return setmetatable({}, {
            __newindex = (function(self, Property, Value)
                if (Property == "To") then
                    local To = Value
                    local Direction = (To - LineProperties.From);
                    local Center = (To + LineProperties.From) / 2
                    local Distance = Direction.Magnitude
                    local Theta = math.atan2(Direction.Y, Direction.X);

                    LineFrame.Position = UDim2.fromOffset(Center.X, Center.Y);
                    LineFrame.Rotation = math.deg(Theta);
                    LineFrame.Size = UDim2.fromOffset(Distance, LineProperties.Thickness);

                    LineProperties.To = To
                end
                if (Property == "From") then
                    local From = Value
                    local Direction = (LineProperties.To - From);
                    local Center = (LineProperties.To + From) / 2
                    local Distance = Direction.Magnitude
                    local Theta = math.atan2(Direction.Y, Direction.X);

                    LineFrame.Position = UDim2.fromOffset(Center.X, Center.Y);
                    LineFrame.Rotation = math.deg(Theta);
                    LineFrame.Size = UDim2.fromOffset(Distance, LineProperties.Thickness);


                    LineProperties.From = From
                end
                if (Property == "Visible") then
                    LineFrame.Visible = Value
                    LineProperties.Visible = Value
                end
                if (Property == "Thickness") then
                    Value = Value < 1 and 1 or Value

                    local Direction = (LineProperties.To - LineProperties.From);
                    local Distance = Direction.Magnitude

                    LineFrame.Size = UDim2.fromOffset(Distance, Value);

                    LineProperties.Thickness = Value
                end
                if (Property == "Transparency") then
                    LineFrame.BackgroundTransparency = 1 - Value
                    LineProperties.Transparency = Value
                end
                if (Property == "Color") then
                    LineFrame.BackgroundColor3 = Value
                    LineProperties.Color = Value 
                end
            end),
            __index = (function(self, Property)
                if (Property == "Remove") then
                    return (function()
                        LineFrame:Destroy();
                    end)
                end
                return LineProperties[Property]
            end)
        })
    end

    if (Type == "Circle") then
        local CircleProperties = ({
            Radius = 150,
            Filled = false,
            Position = Vector2new()
        } + BaseDrawingProperties)

        local CircleFrame = Instancenew("Frame");

        CircleFrame.AnchorPoint = Vector2new(0.5, 0.5);
        CircleFrame.BorderSizePixel = 0

        CircleFrame.BackgroundColor3 = CircleProperties.Color
        CircleFrame.Visible = CircleProperties.Visible
        CircleFrame.BackgroundTransparency = CircleProperties.Transparency

        local Corner = Instancenew("UICorner", CircleFrame);
        Corner.CornerRadius = UDim.new(1, 0);
        CircleFrame.Size = UDim2new(0, CircleProperties.Radius, 0, CircleProperties.Radius);

        CircleFrame.Parent = UI

        return setmetatable({}, {
            __newindex = (function(self, Property, Value)
                if (Property == "Radius") then
                    CircleFrame.Size = UDim2new(0, Value, 0, Value);
                    CircleProperties.Radius = Value
                end
                if (Property == "Position") then
                    CircleFrame.Position = UDim2new(0, Value.X, 0, Value.Y);
                    CircleProperties.Position = Value
                end
                if (Property == "Filled") then
                    CircleFrame.BackgroundTransparency = Value == true and 0 or 0.8
                    CircleProperties.Filled = Value
                end
                if (Property == "Color") then
                    CircleFrame.BackgroundColor3 = Value
                    CircleProperties.Color = Value
                end
                if (Property == "Visible") then
                    CircleFrame.Visible = Value
                    CircleProperties.Visible = Value
                end
                if (Property == "Transparency") then

                end
            end),
            __index = (function(self, Property)
                if (Property == "Remove") then
                    return (function()
                        CircleFrame:Destroy();
                    end)
                end
                
                return CircleProperties[Property]
            end)
        })
    end

    if (Type == "Text") then
        local TextProperties = ({
            Text = "",
            Size = 0,
            Center = false,
            Outline = false,
            OutlineColor = Color3.new(),
            Position = Vector2new(),
        } + BaseDrawingProperties)

        local TextLabel = Instancenew("TextLabel");

        TextLabel.AnchorPoint = Vector2new(0.5, 0.5);
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2new(0, 200, 0, 50);
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.TextSize = 14

        TextLabel.TextColor3 = TextProperties.Color
        TextLabel.Visible = TextProperties.Visible
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextTransparency = 1 - TextProperties.Transparency
        
        TextLabel.Parent = UI

        return setmetatable({}, {
            __newindex = (function(self, Property, Value)
                if (Property == "Text") then
                    TextLabel.Text = Value
                    TextProperties.Text = Value
                end
                if (Property == "Position") then
                    TextLabel.Position = UDim2new(0, Value.X, 0, Value.Y);
                    TextProperties.Position = Value
                end
                if (Property == "Size") then
                    TextLabel.TextSize = Value
                    TextProperties.Size = Value
                end
                if (Property == "Color") then
                    TextLabel.TextColor3 = Value
                    TextProperties.Color = Value
                end
                if (Property == "Transparency") then
                    TextLabel.TextTransparency = 1 - Value
                    TextProperties.Transparency = Value
                end
                if (Property == "Visible") then
                    TextLabel.Visible = Value
                    TextProperties.Visible = Value
                end
                if (Property == "Center") then
                    TextLabel.Position = Value == true and UDim2new(0, Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2, 0)
                    TextProperties.Center = Value
                end
            end),
            __index = (function(self, Property)
                if (Property == "Remove") then
                    return (function()
                        TextLabel:Destroy();
                    end)
                end
                
                return TextProperties[Property]
            end)
        })
    end

    if (Type == "Square") then
        local SquareProperties = ({
            Thickness = 1,
            Size = Vector2new(),
            Position = Vector2new(),
            Filled = false,
        } + BaseDrawingProperties);

        local SquareFrame = Instancenew("Frame");
        
        SquareFrame.AnchorPoint = Vector2new(0.5, 0.5);
        SquareFrame.BorderSizePixel = 0

        SquareFrame.Visible = false
        SquareFrame.Parent = UI

        return setmetatable({}, {
            __newindex = (function(self, Property, Value)
                if (Property == "Size") then
                    SquareFrame.Size = UDim2new(0, Value.X, 0, Value.Y);
                    SquareProperties.Text = Value
                end
                if (Property == "Position") then
                    SquareFrame.Position = UDim2new(0, Value.X, 0, Value.Y);
                    SquareProperties.Position = Value
                end
                if (Property == "Size") then
                    SquareFrame.Size = UDim2new(0, Value.X, 0, Value.Y);
                    SquareProperties.Size = Value
                end
                if (Property == "Color") then
                    SquareFrame.BackgroundColor3 = Value
                    SquareProperties.Color = Value
                end
                if (Property == "Transparency") then
                    SquareFrame.BackgroundTransparency = 1 - Value
                    SquareProperties.Transparency = Value
                end
                if (Property == "Visible") then
                    SquareFrame.Visible = Value
                    SquareProperties.Visible = Value
                end
                if (Property == "Filed") then -- requires beta

                end
            end),
            __index = (function(self, Property)
                if (Property == "Remove") then
                    return (function()
                        SquareFrame:Destroy();
                    end)
                end
                
                return SquareProperties[Property]
            end)
        })
    end

    if (Type == "Image") then
        local ImageProperties = ({
            Data = "rbxassetid://848623155", -- roblox assets only rn
            Size = Vector2new(),
            Position = Vector2new(),
            Rounding = 0,
        });

        local ImageLabel = Instancenew("ImageLabel");

        ImageLabel.AnchorPoint = Vector2new(0.5, 0.5);
        ImageLabel.BorderSizePixel = 0
        ImageLabel.ScaleType = Enum.ScaleType.Stretch
        ImageLabel.Transparency = 1
        
        ImageLabel.Visible = false
        ImageLabel.Parent = UI

        return setmetatable({}, {
            __newindex = (function(self, Property, Value)
                if (Property == "Size") then
                    ImageLabel.Size = UDim2new(0, Value.X, 0, Value.Y);
                    ImageProperties.Text = Value
                end
                if (Property == "Position") then
                    ImageLabel.Position = UDim2new(0, Value.X, 0, Value.Y);
                    ImageProperties.Position = Value
                end
                if (Property == "Size") then
                    ImageLabel.Size = UDim2new(0, Value.X, 0, Value.Y);
                    ImageProperties.Size = Value
                end
                if (Property == "Transparency") then
                    ImageLabel.ImageTransparency = 1 - Value
                    ImageProperties.Transparency = Value
                end
                if (Property == "Visible") then
                    ImageLabel.Visible = Value
                    ImageProperties.Visible = Value
                end
                if (Property == "Color") then
                    ImageLabel.ImageColor3 = Value
                    ImageLabel.Color = Value
                end
                if (Property == "Data") then
                    ImageLabel.Image = Value
                    ImageProperties.Data = Value
                end
            end),
            __index = (function(self, Property)
                if (Property == "Remove") then
                    return (function()
                        ImageLabel:Destroy();
                    end)
                end
                
                return ImageLabel[Property]
            end)
        })
    end


    if (Type == "Quad") then -- will add later
        return setmetatable({}, {
            
        });
    end
end

return Drawing
