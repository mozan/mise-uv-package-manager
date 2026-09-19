local cmd = require("cmd")

local function shq(value)
  return "'" .. tostring(value):gsub("'", "'\"'\"'") .. "'"
end

local function spec(package)
  if package.version and package.version ~= "" and package.version ~= "latest" then
    return package.name .. "==" .. package.version
  end
  return package.name
end

function PLUGIN:PackageUpgrade(ctx)
  for _, package in ipairs(ctx.packages) do
    local command

    if package.version and package.version ~= "" and package.version ~= "latest" then
      -- Reinstall to replace the previous constraint, so changing a mise pin
      -- supports both upgrades and downgrades.
      command = "uv tool install " .. shq(spec(package))
    else
      -- For `latest`, ask uv to resolve and upgrade this tool only.
      command = "uv tool upgrade " .. shq(package.name)
    end

    if ctx.dry_run then
      print(command)
    else
      cmd.exec(command)
    end
  end
  return {}
end
