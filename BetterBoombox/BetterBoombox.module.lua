-- Madonox
-- 2022

local BetterBoombox = {}
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local Configuration = require(script.Parent.Configuration)

local allowedUsers = {}
local authorizedSoundIds = {}

local isRunning = false

function BetterBoombox.init()
	if isRunning == false then
		isRunning = true
		if RunService:IsServer() then
			for _,player in ipairs(game.Players:GetPlayers()) do
				if Configuration.BoomboxIsFree == true then
					table.insert(allowedUsers,player)
					local clone = script.Parent.Resources.Boombox:Clone()
					clone.Parent = player:WaitForChild("Backpack")
					player.CharacterAdded:Connect(function()
						local clone = script.Parent.Resources.Boombox:Clone()
						clone.Parent = player:WaitForChild("Backpack")
					end)
				else
					for _,gamepassId in ipairs(Configuration.GamepassIDs) do
						if MarketplaceService:UserOwnsGamePassAsync(player.UserId,gamepassId) == true then
							table.insert(allowedUsers,player)
							local clone = script.Parent.Resources.Boombox:Clone()
							clone.Parent = player:WaitForChild("Backpack")
							player.CharacterAdded:Connect(function()
								local clone = script.Parent.Resources.Boombox:Clone()
								clone.Parent = player:WaitForChild("Backpack")
							end)
							break
						end
					end
				end
			end
			game.Players.PlayerAdded:Connect(function(player)
				if Configuration.BoomboxIsFree == true then
					table.insert(allowedUsers,player)
					local clone = script.Parent.Resources.Boombox:Clone()
					clone.Parent = player:WaitForChild("Backpack")
					player.CharacterAdded:Connect(function()
						local clone = script.Parent.Resources.Boombox:Clone()
						clone.Parent = player:WaitForChild("Backpack")
					end)
				else
					for _,gamepassId in ipairs(Configuration.GamepassIDs) do
						if MarketplaceService:UserOwnsGamePassAsync(player.UserId,gamepassId) == true then
							table.insert(allowedUsers,player)
							local clone = script.Parent.Resources.Boombox:Clone()
							clone.Parent = player:WaitForChild("Backpack")
							player.CharacterAdded:Connect(function()
								local clone = script.Parent.Resources.Boombox:Clone()
								clone.Parent = player:WaitForChild("Backpack")
							end)
							break
						end
					end
				end
			end)
			game.Players.PlayerRemoving:Connect(function(player)
				local point = table.find(allowedUsers,player)
				if point then
					table.remove(allowedUsers,point)
				end
			end)
			
			for _,id in ipairs(Configuration.ApprovedAudios) do
				table.insert(authorizedSoundIds,id)
			end
			
			script.Parent.Resources.PlaySound.OnServerEvent:Connect(function(player,id)
				if table.find(allowedUsers,player) and table.find(authorizedSoundIds,id) then
					local char = player.Character
					if char then
						if char:FindFirstChild("Boombox") then
							local sound = char.Boombox.Handle:FindFirstChildOfClass("Sound")
							sound.SoundId = id
							sound:Play(0)
						end
					end
				end
			end)
			script.Parent.Resources.StopSound.OnServerEvent:Connect(function(player)
				if table.find(allowedUsers,player) then
					if player.Backpack then
						if player.Backpack:FindFirstChild("Boombox") then
							local sound = player.Backpack.Boombox.Handle:FindFirstChildOfClass("Sound")
							sound:Stop()
						end
					end
				end
			end)
			
			if require(9040261328).getData("BetterBoombox",script.Parent.Resources.CurrentBuild.Value) == false then
				warn("BetterBoombox is outdated!  Please check the devforum for the latest model and install it, as it can include important security updates!")
			end
		elseif RunService:IsClient() then
			local player = game.Players.LocalPlayer
			local canUseBoombox = false
			if Configuration.BoomboxIsFree == true then
				canUseBoombox = true
			else
				for _,gamepassId in ipairs(Configuration.GamepassIDs) do
					if MarketplaceService:UserOwnsGamePassAsync(player.UserId,gamepassId) then
						canUseBoombox = true
						break
					end
				end
			end
			if canUseBoombox == true then
				local guiClone = script.Parent.Resources.BoomboxGui:Clone()
				script.Parent.Resources.OpenGui.Event:Connect(function(toggle)
					if toggle == true then
						guiClone.Frame:TweenPosition(UDim2.new(0.325,0,0.695,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.5)
					else
						guiClone.Frame:TweenPosition(UDim2.new(0.325,0,1.5,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.5)
					end
				end)
				
				for _,audio in ipairs(Configuration.ApprovedAudios) do
					local audioData = MarketplaceService:GetProductInfo(audio)
					local button = script.Parent.Resources.SongDemoButton:Clone()
					button.Text = audioData.Name
					button.MouseButton1Click:Connect(function()
						script.Parent.Resources.PlaySound:FireServer(audio)
					end)
					button.Parent = guiClone.Frame.SongSelection
				end
				
				guiClone.Parent = player.PlayerGui
			end
		end
	end
end

return BetterBoombox
