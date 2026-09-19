local cmd = require("cmd")

local function shq(value)
  return "'" .. tostring(value):gsub("'", "'\"'\"'") .. "'"
end

local function spec(package)
  if package.version and package.version ~= "" and package.version ~= "latest" then
    -- uv/Python package requirement syntax uses == for an exact version.
    return package.name .. "==" .. package.version
  end
  return package.name
end

function PLUGIN:PackageInstall(ctx)
  for _, package in ipairs(ctx.packages) do
    local package_spec = spec(package)
    local command = "uv tool install " .. shq(package_spec)

    if ctx.dry_run then
      print(command)
    else
      -- Re-running `uv tool install` replaces an existing tool environment and,
      -- importantly, replaces old version constraints with the requested pin.
      cmd.exec(command)
    end
  end
  return {}
end
