local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local curl = require 'plenary.curl'

-- our picker function
local pr_list = function(opts)
  opts = opts or {}
  local repo = vim.fn.system 'git rev-parse --show-toplevel'
  repo = 'prod-vxs'
  local result = curl.request {
    url = 'https://gitea.daedalean.ai/api/v1/repos/daedalean/' .. repo .. '/pulls?state=open',
    method = 'get',
    accept = 'application/json',
    raw = { '-H', 'Authorization: token 07f80f3f2219309a5cdfc1887637e08fee32039b' },
  }
  pickers
    .new(opts, {
      prompt_title = 'Gitea PRs',
      finder = finders.new_oneshot_job({ 'pr-list', 'prod-vxs', '-' }, opts),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          print(vim.inspect(selection))
          vim.api.nvim_put({ selection[1] }, '', false, true)
        end)
        return true
      end,
    })
    :find()
end

pr_list()
