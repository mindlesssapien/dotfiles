-- =============================================================================
-- Options
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- Editor
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.updatetime = 100
opt.confirm = true
opt.autoread = true
opt.timeoutlen = 300

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes:1"
opt.cursorline = false
opt.wrap = false
opt.showmode = false
opt.pumheight = 10
opt.fillchars = { eob = " " }
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Files
opt.fileencoding = "utf-8"
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- =============================================================================
-- Statusline (no plugin)
-- =============================================================================
local function statusline()
  local mode_map = {
    n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE",
    ["\22"] = "V-BLOCK", c = "COMMAND", R = "REPLACE", t = "TERMINAL",
  }
  local mode = mode_map[vim.fn.mode()] or vim.fn.mode()
  local file = vim.fn.expand("%:t")
  if file == "" then file = "[No Name]" end
  local modified = vim.bo.modified and " ●" or ""
  local ro = vim.bo.readonly and " [RO]" or ""
  local ft = vim.bo.filetype ~= "" and ("  " .. vim.bo.filetype) or ""
  local branch = ""
  -- git branch via vim.system (non-blocking on Neovim 0.10+)
  local ok, result = pcall(vim.fn.system, "git rev-parse --abbrev-ref HEAD 2>/dev/null")
  if ok and result and result ~= "" then
    branch = "  " .. result:gsub("\n", "")
  end
  local pos = " %l:%c"
  local pct = " %p%%"
  return table.concat({
    " ", mode, "  ", file, modified, ro, branch, "%=", ft, pos, pct, " ",
  })
end

opt.statusline = "%!v:lua.require'_statusline'.get()"

-- Store it in a module accessible to statusline option
_G._statusline_fn = statusline
vim.api.nvim_create_autocmd(
  { "ModeChanged", "BufEnter", "BufWritePost", "CursorMoved" },
  { callback = function() vim.opt.statusline = statusline() end }
)
-- Initial set
opt.statusline = statusline()

-- =============================================================================
-- Colorscheme — habamax (built-in, no plugin needed)
-- =============================================================================
vim.cmd.colorscheme("habamax")

-- Tweak a few highlights to taste
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- softer line numbers
    vim.api.nvim_set_hl(0, "LineNr",    { fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#5c6370" })
    vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#5c6370" })
    -- clean sign column
    vim.api.nvim_set_hl(0, "SignColumn", { link = "Normal" })
  end,
})

-- =============================================================================
-- Lazy.nvim bootstrap
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Plugins (only what builtins cannot do)
-- =============================================================================
require("lazy").setup({

  -- LSP config wrapper (thin, no alternative)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")

      -- Add your LSPs here. Install them yourself (pip install pyright, etc.)
      -- and just call setup. No Mason needed.
      local servers = { "pyright", "ts_ls", "lua_ls", "clangd" }

      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        map("n", "K",          vim.lsp.buf.hover,           "Hover")
        map("n", "<C-k>",      vim.lsp.buf.signature_help,  "Signature")
        map("n", "gd",         vim.lsp.buf.definition,      "Definition")
        map("n", "gi",         vim.lsp.buf.implementation,  "Implementation")
        map("n", "gr",         vim.lsp.buf.references,      "References")
        map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action,     "Code Action")
        map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format")
        map("n", "[d",         vim.diagnostic.goto_prev,    "Prev Diagnostic")
        map("n", "]d",         vim.diagnostic.goto_next,    "Next Diagnostic")
        map("n", "<leader>e",  vim.diagnostic.open_float,   "Diagnostic Float")
      end

      for _, server in ipairs(servers) do
        lspconfig[server].setup({ on_attach = on_attach })
      end

      vim.diagnostic.config({
        virtual_text = true,
        underline = true,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN]  = "W",
            [vim.diagnostic.severity.HINT]  = "H",
            [vim.diagnostic.severity.INFO]  = "I",
          },
        },
      })
    end,
  },

  -- Completion (no good builtin on stable Neovim yet)
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "*",
    config = function()
      require("blink.cmp").setup({
        keymap = {
          preset = "default",
          ["<CR>"]  = { "accept", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
        snippets = { preset = "default" },   -- uses vim.snippet, no LuaSnip
        completion = {
          documentation = { auto_show = true, auto_show_delay_ms = 200 },
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
      })
    end,
  },

  -- Treesitter (no builtin alternative)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash", "c", "html", "javascript", "json", "lua",
          "markdown", "python", "typescript", "vim", "yaml",
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },

  -- Surround + text objects (no practical builtin equivalent)
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
    end,
  },

}, {
  install  = { missing = true },
  checker  = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- =============================================================================
-- Fuzzy find — built-in (Neovim 0.10+ :find + quickfix, no fzf-lua)
-- =============================================================================

-- Lightweight file picker using vim.ui.select + vim.fn.globpath
local function pick_files()
  local cwd = vim.fn.getcwd()
  local files = vim.fn.systemlist(
    "find " .. cwd .. " -type f -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/__pycache__/*' 2>/dev/null"
  )
  -- strip cwd prefix for display
  local display = vim.tbl_map(function(f)
    return f:sub(#cwd + 2)
  end, files)
  vim.ui.select(display, { prompt = "Files> " }, function(choice)
    if choice then vim.cmd("edit " .. vim.fn.fnameescape(cwd .. "/" .. choice)) end
  end)
end

-- Grep across project using built-in :grep + quickfix
local function live_grep()
  local pattern = vim.fn.input("Grep> ")
  if pattern == "" then return end
  vim.cmd("silent grep! " .. vim.fn.shellescape(pattern) .. " -r --include='*.lua' --include='*.py' --include='*.js' --include='*.ts' .")
  vim.cmd("copen")
end

-- Buffer picker
local function pick_buffers()
  local bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  local names = vim.tbl_map(function(b)
    local name = vim.api.nvim_buf_get_name(b)
    return name ~= "" and vim.fn.fnamemodify(name, ":~:.") or ("[buf " .. b .. "]")
  end, bufs)
  vim.ui.select(names, { prompt = "Buffers> " }, function(choice, idx)
    if choice then vim.api.nvim_set_current_buf(bufs[idx]) end
  end)
end

-- Use ripgrep if available, else grep
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

vim.keymap.set("n", "<leader>ff", pick_files,    { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", live_grep,     { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", pick_buffers,  { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>help<cr>", { desc = "Help" })

-- =============================================================================
-- Auto pairs (no plugin — just 10 lines of imap)
-- =============================================================================
local pairs_map = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
for open, close in pairs(pairs_map) do
  vim.keymap.set("i", open, open .. close .. "<Left>", { silent = true })
end
-- Backspace should delete both chars
vim.keymap.set("i", "<BS>", function()
  local col = vim.fn.col(".") - 1
  local line = vim.api.nvim_get_current_line()
  local before = line:sub(col, col)
  local after  = line:sub(col + 1, col + 1)
  local pair_close = pairs_map[before]
  if pair_close and after == pair_close then
    return "<Del><BS>"
  end
  return "<BS>"
end, { expr = true, silent = true })

-- =============================================================================
-- Keymaps
-- =============================================================================
local map = vim.keymap.set

-- Movement (respect wrapped lines)
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Windows
map("n", "<leader>w", "<C-w>",    { remap = true, desc = "Window prefix" })
map("n", "<leader>d", "<C-w>c",   { desc = "Close window" })
map("n", "<leader>s", "<C-w>s",   { desc = "Split horizontal" })
map("n", "<leader>v", "<C-w>v",   { desc = "Split vertical" })

-- Buffers
map("n", "<Tab>",   ":bnext<CR>", { silent = true })
map("n", "<S-Tab>", ":bprev<CR>", { silent = true })

-- Search
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- Edit
map("v", "J",  ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K",  ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("i", "jj", "<Esc>")

-- Quickfix (for grep results)
map("n", "<leader>qo", ":copen<CR>",  { silent = true, desc = "Open quickfix" })
map("n", "<leader>qc", ":cclose<CR>", { silent = true, desc = "Close quickfix" })
map("n", "]q", ":cnext<CR>",          { silent = true, desc = "Next quickfix" })
map("n", "[q", ":cprev<CR>",          { silent = true, desc = "Prev quickfix" })

-- =============================================================================
-- Autocmds
-- =============================================================================
local api = vim.api

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

-- Return to last position
api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= api.nvim_buf_line_count(0) then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- No auto-comment continuation
api.nvim_create_autocmd("BufEnter", {
  command = "set formatoptions-=cro",
})

-- Close utility windows with q
api.nvim_create_autocmd("FileType", {
  pattern = { "help", "lspinfo", "man", "qf", "checkhealth" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Trim trailing whitespace on save
api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local pos = api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    pcall(api.nvim_win_set_cursor, 0, pos)
  end,
})

-- Filetype extras
vim.filetype.add({
  extension = { env = "dotenv" },
  filename  = { [".env"] = "dotenv", [".envrc"] = "sh" },
})
