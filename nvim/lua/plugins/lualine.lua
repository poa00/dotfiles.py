-- Eviline config for lualine

-- Author: shadmansaleh
-- Credit: glepnir

local lualine = require "lualine"

-- Color table for highlights
local colors = {
    bg = "#2E3440",
    fg = "#E5E9F0",
    yellow = "#EBCB8B",
    cyan = "#88C0D0",
    darkblue = "#5E81AC",
    green = "#A3BE8C",
    orange = "#D08770",
    violet = "#a9a1e1",
    magenta = "#B48EAD",
    blue = "#81A1C1",
    red = "#BF616A"
}

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end
}

-- Config
local config = {
    options = {
        -- Disable sections and component separators
        component_separators = "",
        section_separators = "",
        theme = {
            -- We are going to use lualine_c an lualine_x as left and
            -- right section. Both are highlighted by c theme .  So we
            -- are just setting default looks o statusline
            normal = {c = {fg = colors.fg, bg = colors.bg}},
            inactive = {c = {fg = colors.fg, bg = colors.bg}}
        }
    },
    sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {}
    },
    inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_v = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {}
    }
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
end

local function ins_inactive_left(component)
    table.insert(config.inactive_sections.lualine_a, component)
end

ins_inactive_left {
    "filename"
}

ins_left {
    function()
        return "▊"
    end,
    color = {fg = colors.blue}, -- Sets highlighting of component
    left_padding = 0 -- We don't need space before this
}

ins_left {
    -- mode component
    function()
        -- auto change color according to neovims mode
        local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            [""] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.red,
            t = colors.red
        }
        vim.api.nvim_command("hi! LualineMode guifg=" .. mode_color[vim.fn.mode()] .. " guibg=" .. colors.bg)
        return ""
    end,
    color = "LualineMode",
    left_padding = 0
}

ins_left {
    "branch",
    icon = "",
    condition = conditions.check_git_workspace,
    color = {fg = colors.violet, gui = "bold"}
}

ins_left {
    "filename",
    condition = conditions.buffer_not_empty,
    color = {fg = colors.magenta, gui = "bold"}
}

ins_left {
    "diff",
    -- Is it me or the symbol for modified us really weird
    symbols = {added = " ", modified = " ", removed = " "},
    color_added = colors.green,
    color_modified = colors.orange,
    color_removed = colors.red,
    condition = conditions.hide_in_width
}

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left {
    function()
        return "%="
    end
}

ins_left {
    -- Lsp server name .
    function()
        local msg = "No Active Lsp"
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    icon = "  LSP:",
    color = {fg = colors.cyan, gui = "bold"}
}

ins_right {
    "filetype",
    condition = conditions.buffer_not_empty
}

ins_right {
    "diagnostics",
    sources = {"nvim_lsp"},
    symbols = {error = " ", warn = " ", info = " "},
    color_error = colors.red,
    color_warn = colors.yellow,
    color_info = colors.cyan
}

ins_right {
    function()
        return "▊"
    end,
    color = {fg = colors.blue},
    right_padding = 0
}

-- Now don't forget to initialize lualine
lualine.setup(config)
