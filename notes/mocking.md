# C Mocking Techniques
## Link Wrappers
Allow a symbol to be redefined with the linker option: `-Wl,--wrap=foo`.

- any *undefined* reference to `foo` will be resolved to `__wrap_foo`.
- any undefined reference to `__real_foo` will be resolved to `foo`.

## Weak linking
With the `weak` attribute on a symbol.

A weak symbol can be replaced by an identical non weak symbol.

### How to make a weak symbol without modifying sources
Several things to take in account:

- it is possible to declare a symbol multiple times provided that the
  definition stays the same.
- attributes on multiple symbol definitions are cumulative: if you have
  symbol `x` defined with attribute `a` and an other definition of `x` with
  attribute `b` then you end up with the definition of `x` with attributes
  `a+b`.

If you want to make symbol `x` a weak symbol without modifying the file that
declare `x` you can:

- create a new include file with the definition of `x` with the attribute
  `weak`.
- compile your project with the added CFLAG `-include=<new include>` which
  will include the new include file at the beggining of each compilation unit
  thus making `x` a weak symbol.

  ## References
  - [Exploring Robot Framework For Automated Testing](https://packetpushers.net/exploring-robot-framework-for-automated-testing/)
