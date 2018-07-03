--[[	
	The you use it was inspired by SinisterRectus' discordia library for Lua Discord bots.
	Link: https://github.com/SinisterRectus/Discordia/wiki
	
	My Lazy Module
	Made by Oxegonal(Oxe#9904)
	Invite Code to NS Releases: 2vJRq4e
	
	--[[
		Available Events:
			Died: Args (Player, Character)
			Respawned: Args(Player, (NEW)Character)
			Said: Args(Player, Message)
			TeamJoin: Args(Player, Team)
			TeamLeave: Args(Player, Team)
			ReceivedTool: Args(Player, Tool)
			Equipped: Args(Player, Tool)
			
		More events will be available as time progresses.
		Example setup:
		-------------------------------------------
		local Module = require(ModulePath)
		local Client = Module.Client()
		Client:On("EVENTNAME", function(Arg1, Arg2)
			print(Arg1.Name, Arg2.Name)
		end)
		-------------------------------------------
		
		Current Functions Available:
			Client:GetPlayer("PlayerNameHere") - Can be partial or full name. (Great for commands)
			Client:RespawnBring("PlayerName") - Will respawn the player and teleport them to their original position.			
	--]]
--]]

local Module = {}

local SelfClient = {
	Listening = {},
	Events = {
		Said = {},
		Died = {},
		Respawned = {},
		TeamJoin = {},
		TeamLeave = {},
		ReceivedTool = {},
		Equipped = {},
	}
}

function SelfClient:DisconnectEvents(Event)
	if self.Events[Event] then
		for i,v in pairs(self.Events[Event]) do
			pcall(function()
				v:Disconnect()
			end)
		end
	end
end

function SelfClient:On(EventName, Callback)
	self.Listening[#self.Listening] = {Event=EventName, Run=Callback}
end

function SelfClient:Fire(EventName, ...)
	for i,v in pairs(self.Listening) do
		if type(v) == "table" then
			if v.Event and v.Run then
				if v.Event == EventName then
					v.Run(...)
				end
			end
		end
	end
end

function SelfClient:UpdateDied()
	self:DisconnectEvents("Died")
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v.Character then
			local Humanoid = v.Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				self.Events.Died[#self.Events.Died+1] = Humanoid.Died:Connect(function()
					self:Fire("Died", v, v.Character)
				end)
			end
		end
	end
end

function SelfClient:UpdateRespawned()
	self:DisconnectEvents("Respawned")
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		self.Events.Respawned[#self.Events.Respawned] = v.CharacterAdded:Connect(function(NewCharacter)
			self:Fire("Respawned", v, NewCharacter)
		end)
	end
end

function SelfClient:UpdateSaid()
	self:DisconnectEvents("Said")
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		self.Events.Said[#self.Events.Said] = v.Chatted:Connect(function(Message)
			self:Fire("Said", v, Message)
		end)
	end
end

function SelfClient:UpdateTeamJoin()
	self:DisconnectEvents("TeamJoin")
	for i,v in pairs(game:GetService("Teams"):GetChildren()) do
		if v:IsA("Team") then
			self.Events.TeamJoin[#self.Events.TeamJoin+1] = v.PlayerAdded:Connect(function(Player)
				self:Fire("TeamJoin", Player, v)
			end)
		end
	end
end

function SelfClient:UpdateTeamLeave()
	self:DisconnectEvents("TeamLeave")
	for i,v in pairs(game:GetService("Teams"):GetChildren()) do
		if v:IsA("Team") then
			self.Events.TeamLeave[#self.Events.TeamLeave+1] = v.PlayerRemoved:Connect(function(Player)
				self:Fire("TeamLeave", Player, v)
			end)
		end
	end
end

function SelfClient:UpdateReceivedTool()
	self:DisconnectEvents("ReceivedTool")
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v:FindFirstChild("Backpack") then
			self.Events.ReceivedTool[#self.Events.ReceivedTool] = v.Backpack.ChildAdded:Connect(function(Tool)
				if Tool:IsA("Tool") then
					self:Fire("ToolReceived", v, Tool)
				end
			end)
		end
	end
end

function SelfClient:UpdateEquipped()
	self:DisconnectEvents("Equipped")
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		if v.Character then
			self.Events.Equipped[#self.Events.Equipped+1] = v.Character.ChildAdded:Connect(function(Obj)
				if Obj:IsA("Tool") then
					self:Fire("Equipped", v, Obj)
				end
			end)
		end
	end
end

function SelfClient:Update()
	-- More coming soon
end

function SelfClient:GetPlayer(Who)
	if Who and Who ~= "" then
		local Service = game:GetService("Players")
		local Players = {}
		for i,v in pairs(Service:GetPlayers()) do
			if v.Name:lower():sub(1,#Who) == Who:lower() or Who:lower() == "all" then
				table.insert(Players, v)
			end
		end
		return Players
	end
end

function SelfClient:RespawnBring(Who)
	local Get = self:GetPlayer(Who)
	if Get and #Get > 0 then
		for i,v in pairs(Get) do
			if v.Character then
				coroutine.wrap(function()
					local PrevPos = v.Character:FindFirstChild("HumanoidRootPart").CFrame
					v:LoadCharacter()
					repeat wait() until v.Character and v.Character:FindFirstChild("HumanoidRootPart")
					v.Character.HumanoidRootPart.CFrame = PrevPos
				end)()
			end
		end
	end
end

function Module.Client()
	coroutine.wrap(function()
		while game:GetService("RunService").Stepped:Wait() do
			SelfClient:UpdateDied()
			SelfClient:UpdateEquipped()
			SelfClient:UpdateTeamJoin()
			SelfClient:UpdateTeamLeave()
			SelfClient:UpdateRespawned()
			SelfClient:UpdateReceivedTool()
			SelfClient:UpdateSaid()
		end
	end)()
	return SelfClient
end

return Module