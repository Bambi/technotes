# Fish Shell
See also [other shells](shells.md) for differences between shells.

# Variables
## Basic Usage Examples
Creating: `set PATH path $PATH`

Removing a path: `set PATH (string -v path $PATH)`

Deleting a variable: `set -e VAR`

## Environment Variables
Exported variable in fish: `set -x VAR value`

Unexporting a variable: `set -u VAR`

## Variable Scope
Different than exported variables: exported variables can be local/global/universal (but usualy global).

- local scope: specific to the current block and automatically erased when block goes out of scope.
  `set -l (--local)
- function scope: variables specific to the current function.
  `set -f (--function)`
- global scope: variables specific to the current fish session (process).
  `set -g (--global)`
- universal scope: variables shared with all fish session on the computer.
  `set -U (--universal)`
  stored in `.config/fish/fish_variables`

If no scope is given a new variable is created in the function scope if created in a function,
else in the global scope.

Environment variables will usualy be created with `set -gx`.

For fish customization variables, use universal variables: `set -U`.

When fish starts, inherited environment variables will be created as global/exported variables. You should
not make theses variables universal!

# References
