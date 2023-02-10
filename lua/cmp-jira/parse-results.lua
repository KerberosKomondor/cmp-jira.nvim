local M = {}

-- result has the following shape
-- {
--    label = what shows,
--    documentation = {
--      kind = "markdown",
--      value = helper text
--    }
-- }
local key = 1
local status = 2
local summary = 3

local function parseResult(line)
  local words = {}
  for word in line:gmatch("([^\t]+)") do table.insert(words, word) end

  local result = {
    label = "#" .. words[key],
    documentation = {
      kind = "markdown",
      value = "Summary: " .. words[summary] .. "\n\nStatus: " .. words[status]
    }
  }
  return result
end

function M.parseResults(data)
  local results = {}
  for _, line in ipairs(data) do table.insert(results, parseResult(line)) end
  return results
end

return M
