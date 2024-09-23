local Pages = require('themify.interface.pages')

Pages.create_page({
  id = 'explore',
  name = 'Explore',

  update = function()
    return {}
  end,

  enter = function()
    return 1
  end,
  leave = function()
  end,

  hover = function()
    
  end,
  select = function()
    return {}
  end
})
