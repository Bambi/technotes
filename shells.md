# Shells Startup
An interactive shell reads commands from standard input. Non interactive shell
read commands from a file.

## Fish
### Init Sequence
Read by every fish shell in order (use `status --is-interactive` or `status --is-login` to distinguish):
- `~/.config/fish/conf.d/*.fish`
- `/etc/fish/conf.d/*.fish`
- `/etc/fish/config.fish`
- `~/.config/fish/fish.conf`

### Variables
Fish variables can be:
- universal: variables shared by all instances of fish shell even after reboot
  (they are stored in the `~/.config/fish/fish_variables` file). `set -U`
- global: specific to the current fish process (and not local to a block of fish code).
  `set -g`
- environment variables are stored in the environment (exported to child processes).
  Universal variable can also be exported variable. `set -x`

## Bash
### Init Sequence
For interactive login shells in order (launched with `--login`):
- `/etc/profile`
- `~/.bash_profile` (usualy have the line `if [ -f ~/.bashrc ]; then . ~/.bashrc; fi`)
- `~/.bash_login`
- `~/.profile`

For interactive non-login shells in order:
- `~/.bashrc`

For non-interactive shells:
- look for `$BASH_ENV` variable and do something like `if [ -n "$BASH_ENV" ]; then . "$BASH_ENV"; fi`

## Zsh
### Init Sequence
In order:
- `~/.zshenv` unless `-f` is used
- `~/.zprofile` for login shells (better use `~/.zlogin`)
- `~/.zshrc` for interactive shells
- `~/.zlogin` for login shells

## Sharing Environment Between Shells
Purpose: be able to use either shell as will.
Use a `~/.env` file to set environment variables with a simple (`dash`) syntax.
Make this file read by Bash.
For Fish use `replay` to load environment.
This file should be read only once, at login shell or before (`~/.xsessionrc`, `~/.pam_environment`).
See also [xsessions](https://unix.stackexchange.com/questions/281858/difference-between-xinitrc-xsession-and-xsessionrc)
and [Environment Variables](https://wiki.debian.org/EnvironmentVariables).

