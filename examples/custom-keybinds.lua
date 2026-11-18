-- SUPER + SHIFT + Y opens the qsw picker in fuzzel.
--
-- Written for impasto's config layout: hyprland.lua loads these after its own
-- modules, and that folder is never overwritten by `setup update`.

hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd("qsw menu"), {
    description = "Shell · Switch the quickshell shell",
})
