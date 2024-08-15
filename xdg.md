# XDG Base Directory Specification

Defines standard locations for user-specific application data.

| Env Variable     | Default Value  | Comments
|------------------|----------------|----------
| $XDG_DATA_HOME   | ~/.local/share |
| $XDG_CONFIG_HOME | ~/.config      |
| $XDG_STATE_HOME  | ~/.local/state | for logs or app state. Importants files should go to data home. Should be persistant.
| $XDG_CACHE_HOME  | ~/.cache       | for non essential files.
| $XDG_RUNTIME_DIR |                | for runtime files (sockets, pipes). Mode must be 0700.
| $XDG_BIN_HOME    | ~/.local/bin   | for user binaries
| $XDG_LIB_HOME    | ~/.local/lib   | for user libraries

`$XDG_CONFIG_DIRS` defines a set of directories where configuration files should be searched.
`$XDG_DATA_DIRS` defines a set of directories where data files should be searched.

## Runtime dir
Must be owned by the user and Unix access mode must be 0700. It must be
created on user login and deleted on user logout and must not survive
reboot. It must not be on a shared file system.

# Application Directories

| Prefix    | /          | /usr       | /usr/local       | other (~/.local)
|-----------|------------|------------|------------------|-----------------
| bin dir   | /bin       | /usr/bin   | p/bin            | p/bin
| lib dir   | ../lib     | ../lib     | ../lib           | ../lib
| conf dir  | /etc       | /etc       | /etc             | ~/.config
| state dir | /var       | /var       | /var             | ~/.local/state
| cache dir | /var/cache | /var/cache | /var/cache       | ~/.cache
| data dir  |            | /usr/share | /usr/local/share | ~/.local/share
| runtime d | /run       | /run       | /run             |
