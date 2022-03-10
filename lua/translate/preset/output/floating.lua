local api = vim.api

local utf8 = require("translate.util.utf8")

local M = {}

function M.cmd(text, _)
    M.window.close()

    local options = require("translate.config").get("preset").output.floating

    local lines, width = M.window.shape(text, options.width)

    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local _width = options.width
    options.width = width
    options.height = #lines

    local win = api.nvim_open_win(buf, false, options)
    options.width = _width

    M.window._current = { win = win, buf = buf }

    vim.cmd('au CursorMoved * ++once lua require("translate.preset.output.floating").window.close()')
end

M.window = {}

function M.window.close()
    if M.window._current then
        api.nvim_win_close(M.window._current.win, false)
        api.nvim_buf_delete(M.window._current.buf, {})
        M.window._current = nil
    end
end

function M.window.shape(text, width)
    if width <= 1 then
        width = math.floor(api.nvim_win_get_width(0) * width)
    end

    local lines = { {} }
    local row, col = 1, 0
    for _, char in utf8.codes(text) do
        local length = api.nvim_strwidth(char)
        if col + length > width then
            lines[row] = table.concat(lines[row], "")
            row = row + 1
            lines[row] = {}
            col = 0
        end
        table.insert(lines[row], char)
        col = col + length
    end

    lines[row] = table.concat(lines[row], "")

    if #lines == 1 then
        width = api.nvim_strwidth(lines[1])
    end

    return lines, width
end

return M
