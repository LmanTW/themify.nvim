local Text = require('themify.interface.components.text')

local M = {
  line_blank = { content = Text:new(''), tags = {} },

  text_padding_1 = Text:new(' '),
  text_padding_2 = Text:new('  '),
  text_padding_4 = Text:new('    '),
  text_padding_6 = Text:new('      ')
}

return M
