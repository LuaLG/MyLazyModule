local Module = require(script.Parent.ModuleScript)
local Client = Module.Client()

--[[
	Here are some event examples
--]]

Client:On("Died", function(Player, Character)
	print("Player died, his name was "..Player.Name.." he had "..Character.Humanoid.MaxHealth.." max health :*(")
end)

Client:On("ToolReceived", function(Player, Tool)
	print(Player.Name.." just received "..Tool.Name)
end)

Client:On("Spawned", function(Player, NewCharacter)
	print(Player.Name.." just spawned, the current health of the new character is: "..NewCharacter.Humanoid.Health)
end)

Client:On("TeamJoin", function(Player, Team)
	print(Player.Name.." has joined the "..Team.Name.." team!")
end)

Client:On("TeamLeave", function(Player, Team)
	print(Player.Name.." has left the "..Team.Name.." team!")
end)

Client:On("Equipped", function(Player, Tool)
	print(Player.Name.." just showed his "..Tool.Name)
end)

--[[
	Here are some function examples
--]]

local Try = Client:GetPlayer("YourName")
for i,v in pairs(Try) do
	print(v.Name)
end

Client:RespawnBring("YourName")
