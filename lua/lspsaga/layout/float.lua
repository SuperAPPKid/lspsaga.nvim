local api, fn = vim.api, vim.fn
local win = require('lspsaga.window')
local ui = require('lspsaga').config.ui
local is_ten = require('lspsaga.util').is_ten
local M = {}

function M.left(height, width, bufnr, title)
  local curwin = api.nvim_get_current_win()
  local pos = api.nvim_win_get_cursor(curwin)
  local float_opt = {
    width = width,
    height = height,
    bufnr = bufnr,
    offset_x = -pos[2],
    focusable = true,
    title = title or nil,
  }
  if title then
    float_opt.title_pos = 'center'
  end

  return win
    :new_float(float_opt, true)
    :bufopt({
      ['buftype'] = 'nofile',
      ['bufhidden'] = 'wipe',
    })
    :winopt({
      ['winhl'] = 'NormalFloat:SagaNormal,FloatBorder:SagaBorder',
    })
    :wininfo()
end

local function border_map()
  return {
    ['single'] = { '┴', '┬' },
    ['rounded'] = { '┴', '┬' },
    ['double'] = { '╩', '╦' },
    ['solid'] = { ' ', ' ' },
    ['shadow'] = { ' ', ' ' },
  }
end

function M.right(left_winid, opt)
  opt = opt or {}

  local win_conf = api.nvim_win_get_config(left_winid)
  local win_col = is_ten and win_conf.col or win_conf.col[false]

  local origin_conf = vim.deepcopy(win_conf)
  local origin_col = math.max(0, is_ten and origin_conf.col or origin_conf.col[false])

  local col = fn.win_screenpos(win_conf.win)[2]

  local right_spaces = vim.o.columns - col - origin_conf.width - origin_col
  local left_spaces = col + origin_col

  local target = opt.width
  if right_spaces > 45 or left_spaces <= 45 then
    win_conf.col = win_col + origin_conf.width + 2
    win_conf.width = target
  else
    win_conf.col = origin_col - target - 2
    win_conf.width = target
  end

  api.nvim_win_set_config(left_winid, origin_conf)

  win_conf.row = is_ten and win_conf.row or win_conf.row[false]
  win_conf.title = nil
  win_conf.title_pos = nil

  if opt.title then
    win_conf.title = #opt.title > win_conf.width
        and opt.title:sub(#opt.title - win_conf.width - 5, #opt.title)
      or opt.title
    win_conf.title_pos = 'center'
  end
  return win
    :new_float(win_conf, false, true)
    :winopt({
      ['winhl'] = 'NormalFloat:SagaNormal,FloatBorder:SagaBorder',
      ['signcolumn'] = 'no',
    })
    :wininfo()
end

return M
