require('plugins')

-- <Space> is <Leader>
vim.g.mapleader = ' '

-- Main config
vim.opt.clipboard = 'unnamed' -- yank goes to clipboard
vim.opt.number = true -- display line numbers
vim.opt.autoindent = true -- copy indent from prev line
vim.opt.tabstop = 2 -- set tab to 2 spaces
vim.opt.shiftwidth = 2 -- set '>>' and '<<' spacing indent
vim.opt.ignorecase = true -- ignore case in search
vim.opt.hlsearch = true -- highlight all search matches
vim.opt.smartcase = true -- pay attention to case when caps are used
vim.opt.incsearch = true -- show search results as I type
vim.opt.ttimeoutlen = 100 -- decrease timeout for faster insert with 'O'
vim.opt.ruler = true -- show row and column in footer
vim.opt.scrolloff = 2 -- minimum lines above/below cursor
vim.opt.laststatus = 2 -- always show status bar
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.listchars = 'tab:»·,nbsp:·,trail:·,extends:>,precedes:<'
vim.opt.list = true -- display unprintable characters

-- Auto-removal of trailing whitespaces on save
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*' },
  command = [[%s/\s\+$//e]],
})

-- Auto-fix imports and format Golang files
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*.go' },
  callback = function()
    vim.lsp.buf.format()
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
  end
})

function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function nmap(shortcut, command)
  map('n', shortcut, command)
end

function imap(shortcut, command)
  map('i', shortcut, command)
end

function vmap(shortcut, command)
  map('v', shortcut, command)
end

function cmap(shortcut, command)
  map('c', shortcut, command)
end

function tmap(shortcut, command)
  map('t', shortcut, command)
end

-- Mappings
-- <Space> + <Space> = NvimTree
nmap('<Leader><Leader>', ':NvimTreeToggle<CR>')
-- <Space> + <p>     = Toggle paste mode
nmap('<Leader>p', ':set invpaste<CR>')
-- <Space> + <T>     = New tab
nmap('<Leader>t', ':tabnew<CR>')
-- <Space> + <w>     = Move panes(default ctrl+w,w)
nmap('<Leader>w', '<C-w>w')
-- <Space> + <f>     = Telescope search
nmap('<Leader>f', '<CMD>Telescope find_files<CR>')
-- <Ctrl> + <\>      = Open console
require('toggleterm').setup{ direction = 'horizontal', size = 15, open_mapping = [[<C-\>]] }
-- <Space> + <e>     = Show LSP error diagnostics
nmap('<Leader>e', ":lua vim.diagnostic.open_float(0, {scope='line'})<CR>")
-- <Ctrl> + <key>    = Navigate LSP items
-- <Tab>             = Confirm LSP suggestion
local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    -- Navigate between completion item
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    -- toggle completion
    ['<C-u>'] = cmp.mapping(function()
      if cmp.visible() then cmp.close() else cmp.complete() end
    end),
    -- navigate between snippet placeholder
    ['<C-a>'] = cmp.mapping(function() luasnip.jump(-1) end, { 'i', 's' }),
    ['<C-d>'] = cmp.mapping(function() luasnip.jump(1) end, { 'i', 's' }),
    -- Confirm item
    ['<Tab>'] = cmp.mapping.confirm({select = true}),
  }
})
-- <g> <d>  = Go to definition(<Ctrl> + <o> back)
nmap('gd', '<CMD>lua vim.lsp.buf.definition()<CR>')

-- Reminder
-- <K> = See docs
-- <Ctrl> + <i> = go forward
-- <Ctrl> + <o> = go back

-- Language
vim.cmd('language en_US')

-- Colorscheme
vim.cmd('colorscheme tokyonight-storm')

-- Turn off LSP logger which grows indefinitely
-- Switch to "debug" or comment if you need to debug LSP
vim.lsp.set_log_level("off")

-- LSP
-- Servers list: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- Type :Mason to update/install LSPs
local servers = {
  'gopls',      -- Go
  'solargraph', -- Ruby
  'terraformls',-- Terraform
  'vtsls',      -- JS/TS
}

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = servers,
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    capabilities = lsp_capabilities,
  })
end
vim.lsp.enable(servers)

-- LSP keymaps (K, grn, gra, grr are built-in in nvim 0.11+)

-- Don't use terraformls on .tfvars as it's full of errors
vim.cmd([[
  augroup FileTypeTerraform
    autocmd!
    autocmd BufRead,BufNewFile *.tfvars setlocal filetype=plaintext
  augroup END
]])
