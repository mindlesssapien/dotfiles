return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function ()
            local quarto = require('quarto')
            quarto.setup()
            vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true })
    end
  },
}

