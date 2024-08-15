# Buildstream
Integration tool based on yaml build metadata description files.
Builds are done in sandboxed environment so no host tooling are used.
Buildstream have very few dependencies to run:
- `python3` (preferably installed with pip)
- `bubblewrap`
- `lzip`

## Usage
Build a pipeline of elements. An element is composed of actions that are processed
in a bubblewrap (chroot).
An element have a number of input which can be either or both:
- runtime dependency
- build dependency

Theses input can come from:
- local files, tarballs, git checkout...
- output of previous elements

and produce outputs:
- outputs in `install-root (/buildstream-install)` are the effective output of
  the element and are listed with the command `bst artifact list-contents`
- other outputs are discarded after execution of the element
- outputs can be sorted into `domain names` with `split rules`.
  (for example a part of the output artifact can be considered as `runtime`
  while the other can be considered as `devel` artifact).
  Split rules are defined in the project's configuration (`project.conf`),
  see [default configuration](https://docs.buildstream.build/2.1/format_project.html#project-builtin-defaults).
- outputs can also be further filtered with the `filter` element.

## Elements
Each element has a type specified with the `kind` standza.
- `stack`: symbolic element for dependency grouping. Has only depends standza
  and all dependencies are always both build and runtime dependencies.
- `import`: produce artifacts directly from its sources without any processing.
  Sources are specified with the `source` standza and output with the `target`
  standza.
- `compose`: creates a selective composition of its dependencies. Dependencies
  can only be `build` type.
- `script`: run some commands to mutate the inputs and create outputs.
- `link`: link 2 elements together.
- `filter`: extract a subsets of files from an other element.
- `junction`: integrate subprojects. With a junction element, local elements can
  depends on other project elements using `element paths`.
  It is not possible to depend from a junction nor a junction can have dependencies.

## References
- [Buildstream Bazel](https://gitlab.com/celduin/buildstream-bazel)
- [Buildstream Tutorial 101](https://docs.google.com/presentation/d/1OdZcVb_jfjYsvSOwCf5ydQCEK5m6E7kGbnFX9XZ8ocs/edit#slide=id.p)
- [Buildstream Tutorial 102](https://docs.google.com/presentation/d/1tNOqk5E0IhCKciGcaA8zqwpjPlgWGEQqnwQvR1tLaaQ/edit?pli=1#slide=id.p)
