-- Put ~/.local/bin on the session PATH.
--
-- Hyprland's session PATH does not include it, so a keybind that runs `qsw`
-- (or anything else installed there) fails silently: the bind fires and the
-- command is "not found". Prepending it here fixes every exec_cmd in the config,
-- not just qsw's.
--
-- Written for impasto's config layout: hyprland.lua loads these after its own
-- modules, and that folder is never overwritten by `setup update`. For another
-- layout, put the same two lines wherever your config sets the environment.

local home = os.getenv("HOME") or ""
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"

if not path:find(home .. "/.local/bin", 1, true) then
    hl.env("PATH", home .. "/.local/bin:" .. path)
end
