# Quantum Mechanical Keyboard
# Setup
1. clone qmk repo
2. in the qmk repo: `make git-submodules`

# Usage
Make a new keymap for a keyboard: `qmk new-keymap <keyboard>`.
`keyboard` can be:
- annepro2/c18
- kprepublic/bm40hsrgb
- kprepublic/jj50

Compile a keyboard: `qmk compile -kb <keyboard> -km <keymap>`

Flash a keyboard: `qmk flash -kb <my_keyboard> -km <my_keymap>`
Keyboard needs to be in DFU mode (bootloader mode):
- jj50: turn on while pressing last key (right-end) of the 2nd row (usualy the enter key)

# QMK
CLI tool to ease qmk compilation. The configuration file is stored in
`~/.config/qmk/qmk.ini` in init format.

Annpro: [User conf](https://github.com/troelslenda/anne-pro-firmware)
https://github.com/kism/keyboard-keymaps

