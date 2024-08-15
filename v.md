# V Language
## Basics
### Functions
Like Zig:
```vlang
fn add(x int, y int) int {
    return x + y
}
```
Functions can be used before their declaration and can return multiple values.
Use `_` to ignore return value.

### Variables
```
name := 'Bob'
age := 20
large_number := i64(9999999999)
```
Variables are declared and initialized with `:=`. Use `=` for assigment.
Global variables are not allowed.
All variables and functions names must use the `snake_case` style.
Variable shadowing is not allowed.

### Primitive Types
```
bool
string
i8    i16  int  i64      i128 (soon)
u8    u16  u32  u64      u128 (soon)
rune // represents a Unicode code point
f32 f64
isize, usize // platform-dependent, the size is how many bytes it takes to reference any location in memory
voidptr // this one is mostly used for [C interoperability](#v-and-c)
any // similar to C's void* and Go's interface{}
```
`int` is always a 32 bit interger.
Literals like `123` or `4.56` default to `int` and `f64` respectively.

### Strings
In V, a string is a read-only array of bytes (they are immutable).
```
name := 'Bob'
assert name.len == 3       // will print 3
assert name[0] == u8(66) // indexing gives a byte, u8(66) == `B`
assert name[1..3] == 'ob'  // slicing gives a string 'ob'
// escape codes
windows_newline := '\r\n'      // escape special characters like in C
assert windows_newline.len == 2
// arbitrary bytes can be directly specified using `\x##` notation where `#` is
// a hex digit aardvark_str := '\x61ardvark' assert aardvark_str == 'aardvark'
assert '\xc0'[0] == u8(0xc0)
// or using octal escape `\###` notation where `#` is an octal digit
aardvark_str2 := '\141ardvark'
assert aardvark_str2 == 'aardvark'
// Unicode can be specified directly as `\u####` where # is a hex digit
// and will be converted internally to its UTF-8 representation
star_str := '\u2605' // ★
assert star_str == '★'
assert star_str == '\xe2\x98\x85' // UTF-8 can be specified this way too.

s := 'hello 🌎' // emoji takes 4 bytes
arr := s.bytes() // convert `string` to `[]u8`
assert arr.len == 10
s2 := arr.bytestr() // convert `[]u8` to `string`
assert s2 == s
```
Both single and double quotes can be used to denote strings.
For consistency, `vfmt` converts double quotes to single quotes unless the string
contains a single quote character.

For raw strings, prepend `r`. Escape handling is not done for raw strings.

### String Interpolation
```
name := 'Bob'
println('Hello, ${name}!') // Hello, Bob!
```
Format specifiers similar to those in C's printf() are also supported
and optionnal.

### Runes
A rune represents a single Unicode character and is an alias for `u32`.
To denote them, use ` (backticks)`:
```
rocket := `🚀`
assert rocket.str() == '🚀'
assert rocket.bytes() == [u8(0xf0), 0x9f, 0x9a, 0x80]
```

### Arrays
An array is a collection of data elements of the same type. An array literal
is a list of expressions surrounded by square brackets. An individual element
can be accessed using an index expression. Indexes start from `0`.
An element can be appended to the end of an array using the push operator
`<<`. It can also append an entire array.
`val in array` returns true if the array contains `val`.

There are two fields that control the "size" of an array:

- len: length - the number of pre-allocated and initialized elements in the array
- cap: capacity - the amount of memory space which has been reserved for
  elements, but not initialized or counted as elements. The array can grow up
  to this size without being reallocated.

There is also an `init` field which is used to initialze all elements of an
array.

There are also a bunch of methods available for [arrays](https://modules.vlang.io/index.html#array).

### Array Slices
A slice is a part of a parent array. Initially it refers to the elements
between two indices separated by a `..` operator. The right-side index must
be greater than or equal to the left side index.

If a right-side index is absent, it is assumed to be the array length. If
a left-side index is absent, it is assumed to be `0`.

V supports array and string slices with negative indexes. Negative indexing
starts from the end of the array towards the start.

### Fixed Size Arrays
V also supports arrays with fixed size. Unlike ordinary arrays, their length
is constant. Unlike ordinary arrays, their data is on the stack.

You can convert a fixed size array to an ordinary array with slicing:
```
mut fnums := [3]int{} // fnums is a fixed size array with 3 elements.
fnums[0] = 1
fnums[1] = 10
fnums[2] = 100
println(fnums) // => [1, 10, 100]
println(typeof(fnums).name) // => [3]int

fnums2 := [1, 10, 100]! // short init syntax that does the same (the syntax will probably change)

anums := fnums[..] // same as `anums := fnums[0..fnums.len]`
println(anums) // => [1, 10, 100]
println(typeof(anums).name) // => []int (array)
```

### Maps
Maps can have keys of type `string`, `rune`, `integer`, `float` or `voidptr`.
If a key is not found, a zero value is returned by default.
```
mut m := map[string]int{} // a map with `string` keys and `int` values
m['one'] = 1
m['two'] = 2
println(m['one']) // "1"
println(m['bad_key']) // "0"
println('bad_key' in m) // Use `in` to detect whether such key exists
println(m.keys()) // ['one', 'two']
m.delete('two')

numbers := {
    'one': 1
    'two': 2
}
```
It's also possible to use an or {} block to handle missing keys or check if
a key is present, and get its value, if it was present, in one go:
```
val := numbers['bad_key'] or { panic('key not found') }
if v := numbers['one'] {
    println('the map value for that key is: ${v}')
}
```

### Modules
Modules can be imported using the `import` keyword. After that the program
can use any public definitions from the imported module but they must be
prefixed with the module name.
It is also possible to import specific functions and types:
```
import os { input, user_os }
```
In this case `input` and `user_os` can be used directly without beeing prefixed
with `os`.

Module name is the name of a directory, either in the `V` distribution or in
the current working directory.

## Structs
Structs are allocated on the stack. To allocate a struct on the heap and
get a reference to it, use the `&` prefix:
```
struct Point {
    x int
    y int
}

mut p := Point{
    x: 10
    y: 20
}
println(p.x) // Struct fields are accessed using a dot
// Alternative literal syntax
p = Point{10, 20}
assert p.x == 10

p := &Point{10, 10}
// References have the same syntax for accessing fields
println(p.x)
```
All struct fields are zeroed by default during the creation of the struct:
```
struct Foo {
    n   int    // n is 0 by default
    s   string // s is '' by default
    a   []int  // a is `[]int{}` by default
    pos int = -1 // custom default value
}
```
Struct fields are private and immutable by default (making structs immutable as well).
Their access modifiers can be changed with pub and mut. In total,
there are 5 possible options:
```
struct Foo {
    a int // private immutable (default)
mut:
    b int // private mutable
    c int // (you can list multiple fields with the same access modifier)
pub:
    d int // public immutable (readonly)
pub mut:
    e int // public, but mutable only in parent module
__global:
    // (not recommended to use, that's why the 'global' keyword starts with __)
    f int // public and mutable both inside and outside parent module
}
```
V doesn't have classes, but you can define methods on types. A method is a
function with a special receiver argument. The receiver appears in its own
argument list between the fn keyword and the method name. Methods must be
in the same module as the receiver type.
```
struct User {
    age int
}
fn (u User) can_register() bool {
    return u.age > 16
}
println(user.can_register())
```
V support embedded structs (like [mixins](https://en.wikipedia.org/wiki/Mixin) classes):
```
struct Size {
mut:
    width  int
    height int
}
struct Button {
    Size
    title string
}
mut button := Button {
    title: 'Click me'
    height: 2
}
```

## Builtin Functions
```
fn print(s string) // prints anything on stdout
fn println(s string) // prints anything and a newline on stdout

fn eprint(s string) // same as print(), but uses stderr
fn eprintln(s string) // same as println(), but uses stderr

fn exit(code int) // terminates the program with a custom error code
fn panic(s string) // prints a message and backtraces on stderr, and terminates the program with error code 1
fn print_backtrace() // prints backtraces on stderr
```
`println` can print anything: strings, numbers, arrays, maps, structs.
If you want to define a custom print value for your type, simply define a
`str() string` method:
```
struct Color {
    r int
    g int
    b int
}

pub fn (c Color) str() string {
    return '{${c.r}, ${c.g}, ${c.b}}'
}

red := Color{ r: 255, g: 0, b: 0 }
println(red)
```
You can dump/trace the value of any V expression using `dump(expr)`:
```
fn factorial(n u32) u32 {
    if dump(n <= 1) {
        return dump(1)
    }
    return dump(n * factorial(n - 1))
}
```

# References
- [V Documentation](https://github.com/vlang/v/blob/master/doc/docs.md)
- [V Playground](https://play.vosca.dev/)
- [vlib](https://modules.vlang.io/)
