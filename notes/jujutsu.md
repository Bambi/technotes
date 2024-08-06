# Jujutsu
SCM Compatible with Git. Can work in parallel with Git.

## Configuration
```
jj config set --user user.name "Antoine Sgambato"
jj config set --user user.email "176003+Bambi@users.noreply.github.com"
```

## Revisions & Revsets
Revisions are equivalent to git commits.
Revsets are a set of revisions (git commit ranges). They are build with a functional language.
[Details here](https://github.com/martinvonz/jj/blob/f3d6616057fb3db3f9227de3da930e319d29fcc7/docs/revsets.md).

## Changes
With jj the current work (git status) is the current revision (commit with Git).
To add a description use `jj describe`.
To start a new revision use `jj new`: this will record the current changes (git commit)
and start a new revision that you should later describe.
The `describe` and `new` command can be combined with `jj new -m <description>`.

> [!Warning] the working copy IS the current revision (there is no index).
> This means that if you create an other revison off some other revision (some other branch)
> the working copy is not 'taken with you' to the new revision: you will get a new revision
> with a clean working copy.

By default the describe command modify the current revision. But it can be used
on any revision with the `-r` parameter.

Any revision can be modified: `jj edit -r <rev>` allows that.

The `new` command creates a new revision with the current one the parent by default.
A revision can have as many parents as necessary with `jj new <rev1> <rev2> ...`.
This is how a merge is done with jujutsu.

## Log
`jj log` shows commit history.
Each commit has 2 ids (hashes):
- the first one is the `change id`: this id will never change even if the commit is
  moved around the history.
- the second id is the `commit id`: this id is the same as the git commit hash and
  will be modified if the commit is re-written.

## Anonymous Branches
With jujtsu branches are mainly anonymous (they do not have name). You can always
refer to any revision (and branches) with their change-id.
To list all branches in the repo: `jj log -r 'heads(all())'`.

## Named Branches
Named branches are mostly used as an interoperability feature with git.

To create a branch: `jj branch create <branch name>`. The current revision will
be the tip of the branch.

> [!Warning] jj branches do not move automatically (they behave more like a git tag).
> Revision created on top of a branch will not be part of the branch!

To update a branch: `jj branch set <branch name>`. Move the branch to the current revision.

## Working With Git
```sh
  git clone <git repo>
  jj git init <git repo> #or
  jj init --git-repo . # for older versions
```
A `.jj` directory is created in the repo root directory (besides `.git`).
From now you can use either jj or git commands on the repo.

Commits are shared between jj and git but branches are not automatically.
To share a branch (master in this example): `jj branch track master@origin`.

You can `jj git push` to push changes to a remote or `jj git fetch` to get changes.
There is not `jj git pull` command.

### Recaps
Creating new commits on a git repository:
- clone the repo: `git clone <repo>`
- init a jj git repo: `jj init --git-repo <repo>`
- track the branch from jj `jj branch track <branch>@origin`
  (allows you to issue `jj fetch` commands)
- create one or more revisions with `jj new / jj describe`
- update your branch: `jj branch set <branch>`
- push you changes: `jj git push --branch <branch>`

## References
- [jj init](https://v5.chriskrycho.com/essays/jj-init/)
- [jujutsu tutorial/](https://steveklabnik.github.io/jujutsu-tutorial/)
- [jujutsu official tutorial](https://martinvonz.github.io/jj/v0.13.0/tutorial/)
