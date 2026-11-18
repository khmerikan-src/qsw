# qsw — switch which quickshell shell is running

A small Bash tool for keeping several [quickshell](https://quickshell.org) desktop
shells installed at once and choosing which one runs. It handles the two things
that make that awkward: most shells insist on living at `~/.config/quickshell`,
and they start in different ways (a bare `qs -d`, a `quickshell -p <dir>` path,
or a systemd user unit).

Switching stops the running shell, **moves** the chosen shell's config directory
into place, and starts it. Nothing is copied and nothing is symlinked, so the
inactive shell sits parked in a store directory, intact and ready to come back.

```
$ qsw list
SHELL            STATE     WHERE                          LAUNCH
*impasto         in place  /home/you/.config/quickshell   config
 serpantinum     stopped   systemd:serpantinum-shell.service serpantinum-shell.service
```

## Install

```sh
install -Dm755 qsw ~/.local/bin/qsw
qsw discover      # pick up the shells installed on this machine
qsw list
```

`~/.local/bin` needs to be on your `PATH`, and `qsw menu` needs `fuzzel`
(anything else is optional: `systemctl --user` only if you register unit-based
shells, `hyprctl` only for the layer report after a switch).

## Commands

| command | what it does |
| --- | --- |
| `qsw list` | every shell known here: state, location, launch method (`*` = selected) |
| `qsw use <shell>` | switch to it |
| `qsw menu` | pick one in fuzzel |
| `qsw stop` | stop the selected shell, keep the selection |
| `qsw start [shell]` | start it again |
| `qsw restore` | put the selected shell back — for a login hook (see below) |
| `qsw discover` | re-register the shells found on this machine |
| `qsw add <name> <path> [--slot] [--unit UNIT] [--desc TEXT]` | register another shell |

`qsw use` is idempotent, and it adopts a shell that is already running instead of
stacking a second copy on the screen.

## Describing a shell

One file per shell, `~/.config/qsw/profiles/<name>.conf`:

```ini
DESC=Impasto — island bar, dock, desktop widgets
SLOT=config
```

```ini
DESC=Serpantinum — the fork's own shell
SLOT=none
PATH=/home/you/.local/share/serpantinum/src/quickshell
UNIT=serpantinum-shell.service
```

- **`SLOT=config`** — the shell reads `~/.config/quickshell` and runs as `qs -d`.
  Only one profile can own the slot; switching parks the occupant in
  `~/.local/share/qsw/store/<name>` and moves the new one in.
- **`SLOT=none`** — the shell lives anywhere and runs as `quickshell -p PATH`.
- **`UNIT=`** — optional. A `systemd --user` unit that starts the shell itself;
  `qsw` starts and stops the unit and reads its `MainPID` to know what is running.

`qsw discover` writes the two profiles above if it finds those shells. Use
`qsw add` for anything else.

## Keeping the choice across logins

Hyprland's session autostart belongs to whichever shell owns the slot, so it will
bring that one up at login regardless of what you last chose. Drop this into
`~/.config/hypr/custom/autostart.lua` (impasto loads `custom/<module>.lua` after
its own module and never overwrites that folder — adapt to your own config
layout, or just run `qsw restore` from your autostart file of choice):

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'sleep 4; qsw restore'")
end)
```

The delay lets the session's own shell come up first; `qsw restore` then clears
it if it is not the one you selected. `examples/` has this file and a matching
keybind.

## Keybind

```lua
hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd("qsw menu"), {
    description = "Shell · Switch the quickshell shell",
})
```

## Where things live

| path | contents |
| --- | --- |
| `~/.local/bin/qsw` | the tool |
| `~/.config/qsw/profiles/*.conf` | one file per registered shell |
| `~/.local/share/qsw/store/<name>/` | shells parked out of the slot |
| `~/.local/state/qsw/{current,pid}` | which shell is selected |

## Caveats

- A shell's own updater writes into `~/.config/quickshell` unconditionally. Run
  it while that shell is the selected one, or the update lands inside whichever
  shell currently owns the slot.
- `qsw` moves directories between filesystems on `mv` semantics — both the slot
  and the store live under `$HOME`, so the move is a rename and is instant.
- It only manages the shell process; wallpaper daemons, notification daemons and
  anything else your session starts are left alone.

## License

MIT — see [LICENSE](LICENSE).
