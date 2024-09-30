# 📚 Colorscheme Database

> [!TIP]
> You can add a colorscheme to the database by [opening an issue](https://github.com/LmanTW/themify.nvim/issues/new/choose).

## Format

You can find the main database file at `database/themes.json`, which contains a list of themes along with their respective properties.

```lua
--- @class Theme
--- @field name string
--- @field repository string
--- @field brightness 'dark'|'light'
--- @field temperature 'cold'|'wram'
--- @field highlights table<string, any>

--- @alias Snippet [string, nil|string, nil|string][][]
--- Lines -> Fragments -> Fragment = [content, highlight, real_highlight]
```

> [!NOTE]
> The `highlights` table includes the highlight groups used for previewing, check out `database/snippets` for all the preview snippets.

> [!NOTE]
> `real_highlight` is used when the text is highlighted by the LSP, not Treesitter.
