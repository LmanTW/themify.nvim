local Text = require('themify.interface.components.text')
local Colors = require('themify.interface.colors')

local M = {
  line_blank = { content = Text:new(''), tags = {} },

  text_padding_1 = Text:new(' '),
  text_padding_2 = Text:new('  '),
  text_padding_4 = Text:new('    '),
  text_padding_6 = Text:new('      '),

  text_update = Text:new('(U) Update', Colors.description),
  text_check = Text:new('(C) Check', Colors.description)
}

return M
