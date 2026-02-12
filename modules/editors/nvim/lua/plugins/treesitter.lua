-- Tree-sitter configuration (pure Nix, no plugin manager)

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "nix",
    "javascript",
    "lua",
  },
  highlight = {
    enable = true,
  },
})

