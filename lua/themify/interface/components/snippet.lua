--- @class Snippet
--- @field content Text[]

local Text = require('themify.interface.components.text')
local Utilities = require('themify.utilities')

local Snippet = {
  supported = {}
}

local snippets = {
  lua = [[
  function main()
    print('Hello World!')
  end
  ]],
  python = [[
    def main():
      print('Hello World!')
  ]],
  javascript = [[
    function main() {
      console.log('Hello World!')
    }
  ]]
}

--- Check Supported Snippet
--- @return nil
function Snippet.check_supported()
  Snippet.supported = {}

  for language in pairs(snippets) do
    local ok = pcall(function()
      vim.treesitter.language.inspect(language)
    end)
  
    if ok then
      Snippet.supported[#Snippet.supported + 1] = language
    end
  end
end

--- Render The Snippet
--- @param buffer integer
--- @return nil
function Snippet.render(buffer, language)
  vim.api.nvim_buf_set_lines(buffer, 1, -1, true, vim.split(snippets[language], '\n'))
end

return Snippet
