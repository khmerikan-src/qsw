-- Bring back the shell you last selected, at login.
--
-- Written for impasto's config layout: hyprland.lua loads these after its own
-- modules, and that folder is never overwritten by `setup update`. For another
-- layout, run `qsw restore` from whatever your session starts.
--
-- The delay lets the session's own shell come up first; qsw restore then clears
-- it if it is not the one that was selected.

hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'sleep 4; qsw restore'")
end)
