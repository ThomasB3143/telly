# teevee

**teevee** is a single-button cyclic launcher for Linux desktops.

You bind a key to a launcher, press it to open a menu, press it again to cycle through options, then leave it to timeout to activate the currently selected option — similar to classic TV menus.

teevee is written in Bash and integrates with **dunst** for notifications.

## Features

- Single-button UI (perfect for keyboard-only or minimal setups)
- Cyclic selection with configurable timeout
- Per-launcher configuration (no global config required)
- Persistent last-selected option
- dunst notifications with:
  - Replacement (no spam)
  - Per-option icons
  - Per-option text
- No daemon, no polling, no background services
- XDG-compliant state handling

## Setting up your first launcher

1. Initialise your teevee config directory with "teevee init"
2. Initialise your launcher directory with "teevee init <launcher_name>"
3. Insert a script per option in .config/teevee/<launcher_name>/options/ (note that scripts are read in alphabetical order)
4. Customise your launcher.conf
5. Bind a key to "teevee run <launcher-name>

Now you can repeat steps 2-6 for as many launchers as you'd like!

## Additional operations

- teevee -h/--help: Provides a comprehensive help guide
- teevee list: Lists all launcher directories found in .config/teevee
- teevee -V/--valid <launcher_name>: Checks validity of a launcher and lists errors

## Launcher ideas

- A power-mode menu to choose between performance modes (power-saving, balanced, etc.)
- A menu to shift between wallpapers or themes