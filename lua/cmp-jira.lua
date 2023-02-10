local Job = require 'plenary.job'

local source = {}
local me = nil
-- TODO: FIX CALLING TO GET ME ALL THE TIME

local parseResults = require 'cmp-jira.parse-results'.parseResults

source.new = function()
  local self = setmetatable({ cache = {} }, { __index = source })
  if not me then
    Job
        :new({
          'jira',
          'me',
          on_exit = function(job)
            local result = job:result()
            me = result[1] or ''
          end
        })
        :start()
  end
  return self
end

source.complete = function(self, _, callback)
  local bufnr = vim.api.nvim_get_current_buf()

  if not self.cache[bufnr] then
    Job
        :new({
          'jira',
          'issue',
          'list',
          '--plain',
          '-a',
          me,
          '--no-headers',
          '-s~done',
          '--columns',
          'key,status,summary',
          on_exit = function(job)
            local result = job:result()

            local ok, items = pcall(parseResults, result)
            if not ok then
              vim.notify('could not parse jira results')
            end

            callback { items = items, isIncomplete = false }
            self.cache[bufnr] = items
          end,
        })
        :start()
  else
    callback { items = self.cache[bufnr], isIncomplete = false }
  end
end

source.get_trigger_characters = function()
  return { "#" }
end

source.is_available = function()
  return vim.bo.filetype == "gitcommit"
end

require 'cmp'.register_source("jira", source.new())
