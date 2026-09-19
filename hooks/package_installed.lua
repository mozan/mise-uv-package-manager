local cmd = require("cmd")

local function normalize_name(name)
  -- PEP 503 / packaging name normalization:
  -- runs of -, _, and . are equivalent and canonicalized to -
  return name:lower():gsub("[-_.]+", "-")
end

function PLUGIN:PackageInstalled(ctx)
  local wanted = {}

  for _, package in ipairs(ctx.packages) do
    wanted[normalize_name(package.name)] = package.name
  end

  local installed = {}

  local output = cmd.exec("uv tool list")

  for line in output:gmatch("[^\r\n]+") do
    if not line:match("^%s") then
      local name, version = line:match("^([^%s]+)%s+v(.+)$")

      if name and version then
        local normalized = normalize_name(name)

        if wanted[normalized] then
          installed[normalized] = version
        end
      end
    end
  end

  local results = {}

  for _, package in ipairs(ctx.packages) do
    local version = installed[normalize_name(package.name)]

    table.insert(results, {
      name = package.name,
      state = version and "installed" or "missing",
      version = version,
    })
  end

  return {
    packages = results,
  }
end
