# systemd-boot utilities

Generic bash scripts and desktop utilities to manage and update boot order in multi-boot systems.
Parses and sets content of EFI variables and creates custom desktop shortcuts (adopting [XDG Desktop Entry specification](https://specifications.freedesktop.org/desktop-entry-spec/latest/)) to streamline targed reboots.

## Installation

A minimal interactive install script is provided, just run `./install.sh` with write access to `/usr/local/bin` (or custom target install directories) and `/usr/share/applications` (when installing desktop shortcuts).

## Usage

- `set_next_boot` lists available entries and allows interactively setting a 'one-shot' boot entry; `set_next_boot <entry>` bypasses selection.
- `reboot_to <entry>` sets `<entry>` as 'one-shot' priority boot entry and reboots the system.

## Notes

The scripts use `LoaderEntries`, `LoaderEntrySelected` and `LoaderEntryOneShot` EFI variables defined by [systemd-boot](https://systemd.io/BOOT_LOADER_INTERFACE/).

For convenience, one can set the `default` parameter to `@saved` so that boot selection is saved on each reboot.