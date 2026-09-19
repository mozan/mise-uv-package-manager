local cmd = require("cmd")

local function shq(value)
  return "'" .. tostring(value):gsub("'", "'\"'\"'") .. "'"
end

function PLUGIN:PackageUninstall(ctx)
  for _, package in ipairs(ctx.packages) do
    cmd.exec("uv tool uninstall " .. shq(package.name))
  end
  return {}
end
