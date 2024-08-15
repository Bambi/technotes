# NB
Note-taking CLI app.

A _notebook_ is a direcory of notes.

A _note_ is a markdown file.

## Notebooks
They can be either:
- global: stored under the `~/.nb` directory (can be modified)
- local: a folder anywhere in the filesystem. The folder must:
  - be a git repository
  - contains a `.index` file

A local notebook will always be refered as `local` and are created with
`nb notebooks init`.

A global NB can be exported as a local NB with `nb notebooks export <name> <path>`.

A local NB can be imported as a global NB with `nb notebooks import <path>`.

