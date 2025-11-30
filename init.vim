call plug#begin()
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'sindrets/diffview.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'stevearc/conform.nvim'

Plug 'davidgranstrom/scnvim'

Plug 'ellisonleao/gruvbox.nvim'
Plug 'lervag/vimtex'
call plug#end()

set background=dark

nnoremap <leader>f <cmd>GFiles<cr>
nnoremap <leader>pf <cmd>Files<cr>
nnoremap <leader>b <cmd>Buffers<cr>
nnoremap <leader>ss <cmd>RG<cr>
nnoremap <leader>gs <cmd>GFiles!?<cr>


nnoremap <leader>do <cmd>:DiffviewOpen<cr>
nnoremap <leader>dp <cmd>:DiffviewClose<cr>

nnoremap <leader>cn <cmd>:cn<cr>
nnoremap <leader>cp <cmd>:cp<cr>
nnoremap <leader>cl <cmd>:ccl<cr>


set number
set nohlsearch

lua <<EOF
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  inverse = false, -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")

EOF


" CMP 
lua <<EOF


  -- Show line diagnostics automatically in hover window
  vim.o.updatetime = 250
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
  vim.diagnostic.config { virtual_text = false }

  -- remove semantic highlight
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end

  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    --window = {
    --  completion = cmp.config.window.bordered(),
    --  documentation = cmp.config.window.bordered(),
    --},
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<c-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]]-- 

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })


  vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "grr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "grn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })


  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  vim.lsp.config['rust_analyzer'] = {
    capabilities = capabilities,
  }
  vim.lsp.enable('rust_analyzer')

  vim.lsp.enable('hls')

  vim.lsp.config['pyright'] = {
    capabilities = capabilities,
  -- Command and arguments to start the server.
  -- cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  -- filetypes = { 'py' },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  -- root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  -- Specific settings to send to the server. The schema is server-defined.
  -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
    settings = {
      python = {
        analysis = {
	  ignore = { '*' },
        }
      }
    }
  }

  vim.lsp.enable('pyright')
  vim.lsp.enable('ruff')


  vim.lsp.config['ts_ls'] = {
    capabilities = capabilities
  }
  vim.lsp.enable('ts_ls')

  vim.lsp.config['angularls'] = {
    capabilities = capabilities
  }
  vim.lsp.enable('angularls')
EOF


" CMP 
lua <<EOF
local scnvim = require 'scnvim'
local map = scnvim.map
local map_expr = scnvim.map_expr

scnvim.setup({
  keymaps = {
    ['<leader>al'] = map('editor.send_line', {'i', 'n'}),
    ['<leader>ab'] = {
      map('editor.send_block', {'i', 'n'}),
      map('editor.send_selection', 'x'),
    },
    ['<CR>'] = map('postwin.toggle'),
    ['<M-CR>'] = map('postwin.toggle', 'i'),
    ['<M-L>'] = map('postwin.clear', {'n', 'i'}),
    ['<C-k>'] = map('signature.show', {'n', 'i'}),
    ['<leader>ai'] = map('sclang.hard_stop', {'n', 'x', 'i'}),
    ['<leader>st'] = map('sclang.start'),
    ['<leader>sk'] = map('sclang.recompile'),
    ['<F1>'] = map_expr('s.boot'),
    ['<F2>'] = map_expr('s.meter'),
  },
  editor = {
    highlight = {
      color = 'IncSearch',
    },
  },
  postwin = {
    float = {
      enabled = true,
    },
  },
})

EOF


" conform
lua <<EOF
require("conform").setup({
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = "fallback",
  }
})
EOF


lua <<EOF
require 'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true, -- enable syntax highlighting
    }
}
EOF
