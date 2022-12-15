local game = game
local Loaded = game.Loaded
local CWait = game.Loaded.Wait
local CConnect = game.Loaded.Connect
if (not game.IsLoaded(game)) then
    CWait(game.Loaded);
end

local Drawing = Drawing or loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/shezan78/shezanssp/main/esplibignore.lua"))();

local GetService = game.GetService
local RunService = GetService(game, "RunService");
local Players = GetService(game, "Players");
local GetPlayers = Players.GetPlayers
local Workspace = GetService(game, "Workspace");
local HttpService = GetService(game, "HttpService");

local gsub = string.gsub
local format = string.format
local lower = string.lower
local floor = math.floor

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
local NewVec3 = Vector3new();
local NewVec2 = Vector2new();

local FindFirstChild = game.FindFirstChild
local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
local IsA = game.IsA
local GetChildren = game.GetChildren

local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer.GetMouse(LocalPlayer);

local CThread = function(f, ...)
    return coroutine.wrap(f)(...);
end

local GetPlayerFromCharacter = function(Character)
    local Plrs = GetPlayers(Players);
    for i = 1, #Plrs do
        if (Plrs[i].Character == Character) then
            return Character
        end
    end
    return nil
end
local GetCharacter = function(Player)
    if (GetPlayerFromCharacter(Player)) then
        return Player
    end
    if (Player) then
        return Player.Character
    end

    return LocalPlayer.Character
end
local GetTargetRoot = function(Model, Options)
    local Root = Options.Root or "HumanoidRootPart"
    if (Model) then
        return FindFirstChild(Model, Root) or FindFirstChild(Model, "Torso") or FindFirstChildWhichIsA(Model, "BasePart");
    end
    return nil
end
local GetTargetHumanoid = function(Model)
    if (Model) then
        return FindFirstChildWhichIsA(Model, "Humanoid");
    end
    return nil
end

local GetTargetMagnitude = function(Model, Options)
    local IsPart = Options.Part
    local TRoot = IsPart and Model or GetTargetRoot(Model, Options);
    if (TRoot) then
        local LChar = GetCharacter();
        local LRoot = GetTargetRoot(LChar, {});
        if (LRoot) then
            return (TRoot.Position - LRoot.Position).Magnitude
        end
    end
    return nil
end

local Drawings = {}

local GetVector2 = function(Model, Options)
    local IsPart = Options.Part 
    local To = IsPart and Model or FindFirstChild(Model, Options.To or "HumanoidRootPart") or FindFirstChild(Model, "Torso") or FindFirstChildWhichIsA(Model, "BasePart");
    if (Model and To) then
        return WorldToViewportPoint(Camera, To.Position);
    end
    return nil
end

local DefaultTOptions = {
    Enabled = true,
    To = "Head",
    From = "Bottom",
    Thickness = 1.6,
    Transparency = .7,
    Color = Color3fromRGB(20, 226, 207),
}

local DefaultEOptions = {
    Enabled = true,
    TeamColors = true,
    Names = true,
    Health = true,
    Distance = false,
    Thickness = 1.5,
    To = "Head",
    Transparency = .9,
    Size = 16,
    Color = Color3fromRGB(20, 226, 207),
    OutlineColor = Color3new(),
    Team = "All",
    BoxEsp = false,
    SkeletonEsp = true,
    RenderDistance = 7000
}

local AddTracer = function(Target, Options)
    local Tracer = Drawingnew("Line");

    Options = setmetatable(Options, {
        __index = function(self, Property)
            local Option = DefaultTOptions[Property]
            if (Option) then
                self[Property] = Option
            end
            return Option
        end
    });

    Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y);
    Tracer.Color = Options.Color
    Tracer.Thickness = Options.Thickness
    Tracer.Transparency = Options.Transparency
    Tracer.Visible = Options.Enabled

    local From, ViewportSize = Options.From, Camera.ViewportSize
    Tracer.From = From == "Top" and Vector2new(ViewportSize.X / 2, ViewportSize.Y - ViewportSize.Y) or From == "Bottom" and Vector2new(ViewportSize.X / 2, ViewportSize.Y) or From == "Left" and Vector2new(ViewportSize.X - ViewportSize.X, ViewportSize.Y / 2) or From == "Right" and Vector2new(ViewportSize.X, ViewportSize.Y / 2);

    local NewDrawing = Drawings[Target]
    if (NewDrawing) then
        Drawings[Target].Tracer = Tracer
    else
        Drawings[Target] = {
            Tracer = Tracer,
            Options = Options
        }
    end
    return Drawings[Target].Options
end

local AddText = function(Target, Options)
    local Text = Drawingnew("Text");
    Options = setmetatable(Options, {
        __index = function(self, Property)
            local Option = DefaultEOptions[Property]
            if (Option) then
                self[Property] = Option
            end
            return Option
        end
    });

    Text.Color = Options.Color
    Text.OutlineColor = Options.OutlineColor
    Text.Size = Options.Size
    Text.Transparency = Options.Transparency
    Text.Center = true
    Text.Outline = true
    Text.Visible = Options.Enabled
    Text.Text = Options.Text

    local NewDrawing = Drawings[Target]
    if (NewDrawing) then
        Drawings[Target].Text = Text
    else
        Drawings[Target] = {
            Text = Text,
            Options = Options
        }
    end
    return Drawings[Target].Options
end

local AddBox = function(Target, Options)
    local Box = Drawingnew("Quad");

    Options = setmetatable(Options, {
        __index = function(self, Property)
            local Option = DefaultEOptions[Property]
            if (Option) then
                self[Property] = Option
            end
            return Option
        end
    });

    Box.PointA = NewVec2
    Box.PointB = NewVec2
    Box.PointC = NewVec2
    Box.PointD = NewVec2
    Box.Thickness = Options.Thickness
    Box.Transparency = Options.Transparency
    Box.Filled = false
    Box.Color = Options.Color
    Box.Visible = Options.Enabled
    
    local NewDrawing = Drawings[Target]
    if (NewDrawing) then
        Drawings[Target].Box = Box
    else
        Drawings[Target] = {
            Text = Box,
            Options = Options
        }
    end
    return Drawings[Target].Options
end

local RemoveDrawing = function(Target)
    local Drawing_ = Drawings[Target]
    if (Drawing_) then
        if (Drawing_.Text) then
            Drawing_.Text:Remove();
        end
        if (Drawing_.Tracer) then
            Drawing_.Tracer:Remove();
        end
        if (Drawing_.Box) then
            Drawing_.Box:Remove();
        end

        Drawings[Target] = nil
        return true
    end
    return false
end

local Render = RunService.RenderStepped.Connect(RunService.RenderStepped, function()
    for i, v in next, Drawings do
        local Options = v.Options
        if (not i) then
            if (Options.RemoveOnDestroy) then
                table.remove(Drawings, i);
            end
        end
        if (i == LocalPlayer) then
            continue;
        end
        local Enabled = Options.Enabled
        local Box, Tracer, Text = v.Box, v.Tracer, v.Text

        local Model = i
        if (Options.IsPlayer or Options.IsPlayerFromCharacter) then
            Model = i.Character
            if (Options.IsPlayerFromCharacter) then
                local Player = GetPlayerFromCharacter(i);
                if (Player) then
                    Model = Player.Character
                end
            end
        end

        if (Text or Box) then
            if (not Model) then
                if (Text) then
                    Text.Visible = false
                end
                if (Box) then
                    Box.Visible = false
                end
                continue
            end
            

            local TextTuple, TextVisible = GetVector2(Model, Options);
            if (Text and TextTuple and TextVisible) then
                local Magnitude, Humanoid = GetTargetMagnitude(Model, Options), GetTargetHumanoid(Model) or {Health=0,MaxHealth=0}
                if (Magnitude and Options.RenderDistance and Magnitude >= Options.RenderDistance or Magnitude >= math.huge) then
                    Text.Visible = false
                end

                Text.Visible = true
                Text.Position = Vector2new(TextTuple.X, TextTuple.Y - 40);
                Text.Text = format(("%s\n%s %s"), Options.Text, Options.ShowDistance and format("[%s]", (floor(Magnitude or math.huge))) or "", Options.ShowHealth and format("[%s/%s]", floor(Humanoid.Health), floor(Humanoid.MaxHealth)) or "");
            else
                if (Text) then
                    Text.Visible = false
                end
                if (Box) then
                    Box.Visible = false
                end
            end
            if (Box) then
                local Parts = {}
                for i2, Part in next, GetChildren(Model) do
                    if (IsA(Part, "BasePart")) then
                        local ViewportPos = WorldToViewportPoint(Camera, Part.Position);
                        Parts[Part] = Vector2new(ViewportPos.X, ViewportPos.Y);
                    end
                end
                local Top, Bottom, Left, Right
                local Distance = math.huge
                local Closest = nil
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(TextTuple.X, 0)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Top = Closest
                Closest = nil
                Distance = math.huge
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(TextTuple.X, Camera.ViewportSize.Y)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Bottom = Closest
                Closest = nil
                Distance = math.huge
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(0, TextTuple.Y)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Left = Closest
                Closest = nil
                Distance = math.huge
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(Camera.ViewportSize.X, TextTuple.Y)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Right = Closest
                Closest = nil
                Distance = math.huge
    
                Box.PointA = Vector2new(Right.X, Top.Y);
                Box.PointB = Vector2new(Left.X, Top.Y);
                Box.PointC = Vector2new(Left.X, Bottom.Y);
                Box.PointD = Vector2new(Right.X, Bottom.Y);
                Box.Visible = true
            end
        end
        if (Tracer) then
            if (not Model) then
                Tracer.Visible = false
            end
            
            local TracerTuple, TracerVisible = GetVector2(Model, Options);
            if (TracerTuple and TracerVisible) then
                Tracer.Visible = true
                Tracer.To = Vector2new(TracerTuple.X, TracerTuple.Y);
            else
                Tracer.Visible = false
            end
        end
    end
end)

CConnect(Workspace.DescendantRemoving, function(Removed)
    for i, v in next, Drawings do
        if (v.Options.OnRemoved) then
            if (i == Removed) then
                RemoveDrawing(i);
            end
        end
    end
end)

local Esp = {}

Esp.new = function(Type, Options)
    local Target = Options.Target
    local TargetType = typeof(Target);
    assert(TargetType == 'Instance', format("Instance expected got %s", TargetType));    
    assert(Type == "Tracer" or Type == "Text" or Type == "Box", "Invalid type");

    local IsPlayerCharacter = GetPlayerFromCharacter(Target) ~= nil
    local IsPlayer = IsA(Target, "Player");
    Options.IsPlayer = IsPlayer
    Options.IsPlayerCharacter = IsPlayerCharacter
    Options.Text = Options.Text or Target.Name

    local Added
    if (Type == "Tracer") then
        Added = AddTracer(Target, Options);
    end
    if (Type == "Text") then
        Added = AddText(Target, Options);
    end
    if (Type == "Box") then
        Added = AddBox(Target, Options);
    end

    return Added
end

Esp.Remove = function(Target)
    for i, v in next, Drawings do
        if (v.Options and i == Target or Target == 'All') then
            RemoveDrawing(i);
        end
    end
end

return Esp