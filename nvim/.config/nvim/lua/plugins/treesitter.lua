return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- embedded_template = parser de .html.erb (eruby); requiere tree-sitter-cli
    ensure_installed = { "embedded_template", "ruby", "html" },
  },
}
