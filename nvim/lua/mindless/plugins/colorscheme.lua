return{
        "aktersnurra/no-clown-fiesta.nvim",
        lazy = false,
        priority = 1000,
        config = function()
                require("no-clown-fiesta").setup({
                  transparent = true, -- Enable this to disable the bg color
                  styles = {
                    -- You can set any of the style values specified for `:h nvim_set_hl`
                    comments = {},
                    functions = {},
                    keywords = {},
                    lsp = { underline = true },
                    match_paren = {},
                    type = { bold = true },
                    variables = {},
                        },
                })
                vim.cmd[[colorscheme no-clown-fiesta]]
        end,
}
