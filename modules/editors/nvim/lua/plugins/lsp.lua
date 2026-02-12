-- LSP configuration (pure Nix, no plugin manager)

local lspconfig = require("lspconfig")

-- Nix
lspconfig.nil_ls.setup({})

-- JavaScript / TypeScript
lspconfig.tsserver.setup({})

