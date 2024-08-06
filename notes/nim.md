# Nim
## Basic
Comments:

- `#`: Can be used anywhere
- `##`: Documentation comment
- `#[` and `]#`: Multi-line comment ; can be nested

The `var` statement declares a new local or global variable.

The `const` statement declares a symbol bound to a value knowed at compile time.

The `let` statement is like `var` but after their initialization their value cannot change.

`=` is the assigment operator and can be overload:
```nim
var x, y = 3
```

## Flow Control
### If Statement
With `if`, `elif` & `else`.

### Case Statement
With `case`, `of`, `else`. This statement must cover every value that the case may contain.

### While Statement
With `while` ; for simple loop constructs.

### For Statement
With `for` & `in`. Used to loop over any element an iterator provides.

### Block Statement And Break
Previous statements each open an implicit new scope and every variable created inside
a block is destroyed when leaving the block.

The block statement can be used to open a new block explicitly:
```nim
block myblock: # the block label (myblock) is optional
  var x = "hi"
echo x # does not work either
```
The `break` statement can be used to leave a block. The `continue` statement jump to
the beginning of a block.

### When Statement
With `when`, `elif` & `else`. Like `if` but:

- Each condition must be a constant expression since it is evaluated by the compiler.
- The statements within a branch do not open a new scope.
- The compiler checks the semantics and produces code only for the statements that
  belong to the first condition that evaluates to `true`.

Similar to C `#ifdef`.

## Procedures
Defined with the `proc` keyword:
```nim
proc yes(question: string): bool =
  echo question, " (y/n)"
  while true:
    case readLine(stdin)
    of "y", "Y", "yes", "Yes": return true
    of "n", "N", "no", "No": return false
    else: echo "Please be clear: yes or no"
```
A procedure that returns a value has an implicit `result` variable declared
that represents the return value. A `return` statement with no expression is
shorthand for `return result`. The `result` value is always returned automatically
at the end of a procedure if there is no `return` statement at the exit.

A procedure that does not have any `return` statement and does not use the special
`result` variable returns the value of its last expression.

### Parameters
Parameters are immutable in the procedure body.
If a mutable variable is needed inside the procedure,
it has to be declared with var in the procedure body. Shadowing the parameter
name is possible, and actually an idiom.

If the procedure needs to modify the argument for the caller, a `var` parameter can be used:
```nim
proc divmod(a, b: int; res, remainder: var int) =
  res = a div b        # integer division
  remainder = a mod b  # integer modulo operation

var
  x, y: int
divmod(8, 5, x, y) # modifies x and y
echo x
echo y
```

### Discard Statement
To call a procedure that returns a value just for its side effects and
ignoring its return value, a `discard` statement must be used. Nim does not
allow silently throwing away a return value:
```nim
discard yes("May I ask a pointless question?")
```
The return value can be ignored implicitly if the called proc/iterator has
been declared with the `discardable` pragma:

```nim
proc p(x, y: int): int {.discardable.} =
  return x + y

p(3, 4) # now valid
```

### Named Arguments
Arguments to a procedure can be named:

```nim
proc createWindow(x, y, width, height: int; title: string;
                  show: bool = false): Window =
   ...

var w = createWindow(show = true, title = "My Application",
                     x = 0, y = 0, height = 600, width = 800)
```
It is also possible to provide default values to procedures arguments.

### Procedure Overloading
Nim provides the ability to overload procedures similar to C++:
```nim
proc toString(x: int): string =
  result =
    if x < 0: "negative"
    elif x > 0: "positive"
    else: "zero"

proc toString(x: bool): string =
  result =
    if x: "yep"
    else: "nope"

assert toString(13) == "positive" # calls the toString(x: int) proc
assert toString(true) == "yep"    # calls the toString(x: bool) proc
```

### Operators
Apart from a few built-in keyword operators such as `and`, `or`, `not`,
operators always consist of these characters: `+ - * \ / < > = @ $ ~ & % ! ? ^ . |`.

User-defined operators are allowed. Nothing stops you from defining your
own `@!?+~` operator, but doing so may reduce readability.

To define a new operator enclose the operator in backticks "`":
```nim
proc `$` (x: myDataType): string = ...
# now the $ operator also works with myDataType, overloading resolution
# ensures that $ works for built-in types just like before
```

The "`" notation can also be used to call an operator just like any other procedure:
```nim
if `==`( `+`(3, 4), 7): echo "true"
```

### Forward Declaration
Every variable, procedure, etc. needs to be declared before it can be
used. However, this cannot be done for mutually recursive procedures

The syntax for such a forward declaration is simple: just omit the `=`
and the procedure's body.

## Iterators
```nim
echo "Counting to ten: "
for i in countup(1, 10):
  echo i

iterator countup(a, b: int): int =
  var res = a
  while res <= b:
    yield res
    inc(res)
```
Iterators look very similar to procedures, but there are several important differences:

- Iterators can only be called from for loops.
- Iterators cannot contain a `return` statement (and procs cannot contain a `yield` statement).
- Iterators have no implicit `result` variable.
- Iterators do not support recursion.
- Iterators cannot be forward declared (may change in the future).

## Basic Types
### Booleans
Type is called `bool` and can receive 2 values `true` & `false`.
Operators `not, and, or, xor, <, <=, >, >=, !=, ==` are defined for the bool type.

### Characters
Type is called `char`, size is 1 byte and literals are enclosed in single quotes.
Chars can be compared with the `==, <, <=, >, >=` operators.
The `$` operator converts a `char` to a `string`.

### Strings
Type is called `string` and are mutable. They are both zero-terminated and have a field length.
String's length can be retreived with the `len` procedure but accessing the terminating
zero is an error.

Nim strings can be conterted to `cstring` without doing a copy.
The assignment operator for strings copies the string. You can use the `&`
operator to concatenate strings and `add` to append to a string.

### Integers
Nim has these integer types built-in:
`int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64`.
The default integer type is `int` that has the same size as a pointer.
Integer literals can have a type suffix to specify a non-default integer type:
```nim
let
  x = 0     # x is of type `int`
  y = 0'i8  # y is of type `int8`
  z = 0'i32 # z is of type `int32`
  u = 0'u   # u is of type `uint`
```
The common operators `+ - * div mod < <= == != > >=` are defined for
integers. The `and or xor not` operators are also defined for integers and
provide bitwise operations. Left bit shifting is done with the `shl`, right
shifting with the `shr` operator. Bit shifting operators always treat their
arguments as `unsigned`. For arithmetic bit shifts ordinary multiplication or
division can be used.

### Floats
Floating-point types built-in: `float float32 float64`.
The default float type is `float` (always 64-bits currently).

The common operators `+ - * / < <= == != > >=` are defined for floats and
follow the IEEE-754 standard.

Integer types are not converted to floating-point types automatically,
nor vice versa. Use the `toInt` and `toFloat` procs for these conversions.

## Advanced Types
### Enumerations
```nim
type
  Direction = enum
    north, east, south, west

var x = south     # `x` is of type `Direction`; its value is `south`
```
Each symbol is mapped to an integer value internally. The first symbol is
represented at runtime by 0.

The `$` operator can convert any enumeration value to its name, and the `ord`
proc can convert it to its underlying integer value.

### Ordinal Types
Enumerations, integer types, `char` and `bool` (and subranges) are called
ordinal types. Ordinal types have quite a few special operations:

| Operation	| Comment
|-----------|--------
| ord(x)	  | returns the integer value that is used to represent x's value
| inc(x)	  | increments x by one
| inc(x, n)	| increments x by n; n is an integer
| dec(x)	  | decrements x by one
| dec(x, n)	| decrements x by n; n is an integer
| succ(x)	  | returns the successor of x
| succ(x, n)|	returns the n'th successor of x
| pred(x)	  | returns the predecessor of x
| pred(x, n)|	returns the n'th predecessor of x

### Subranges
```nim
type
  MySubrange = range[0..5]
```
`MySubrange` is a subrange of `int` which can only hold the values 0
to 5. Assigning any other value to a variable of type `MySubrange` is a
compile-time or runtime error.

The `system` module defines the important `Natural` type as `range[0..high(int)]`
(`high` returns the maximal value).

### Sets
The set type models the mathematical notion of a set for ordinal types of certain
types: `int8-int16, uint8/byte-uint16, char, enum`.
```nim
type
  CharSet = set[char]
var
  x: CharSet
x = {'a'..'z', '0'..'9'} # This constructs a set that contains the
                         # letters from 'a' to 'z' and the digits
                         # from '0' to '9'
```
These operations are supported by sets:

| operation	     | meaning
|----------------|--------------
| A + B	         | union of two sets
| A * B          | intersection of two sets
| A - B          | difference of two sets (A without B's elements)
| A == B         | set equality
| A <= B         | subset relation (A is subset of B or equal to B)
| A < B	         | strict subset relation (A is a proper subset of B)
| e in A         | set membership (A contains element e)
| e notin A	     | A does not contain element e
| contains(A, e) | A contains element e
| card(A)        | the cardinality of A (number of elements in A)
| incl(A, elem)  | same as A = A + {elem}
| excl(A, elem)  | same as A = A - {elem}

### Bit Fields
Sets are often used to define a type for the flags of a procedure. This is
a cleaner (and type safe) solution than defining integer constants that have
to be `or`'ed together.

Enum, sets and casting can be used together as in:
```nim
type
  MyFlag* {.size: sizeof(cint).} = enum
    A
    B
    C
    D
  MyFlags = set[MyFlag]

proc toNum(f: MyFlags): int = cast[cint](f)
proc toFlags(v: int): MyFlags = cast[MyFlags](v)

assert toNum({}) == 0
assert toNum({A}) == 1
assert toNum({D}) == 8
assert toNum({A, C}) == 5
assert toFlags(0) == {}
assert toFlags(7) == {A, B, C}
```

Note how the set turns enum values into powers of 2.
If using enums and sets with C, use distinct `cint`.
For interoperability with C see also the `bitsize pragma`.

### Arrays
An array is a simple fixed-length container of elements with the same
type. The array's index type can be any ordinal type.
Arrays can be constructed using `[]`:
```nim
type
  IntArray = array[0..5, int] # an array that is indexed with 0..5
var
  x: IntArray
x = [1, 2, 3, 4, 5, 6]
for i in low(x) .. high(x):
  echo x[i]
```
Multidimensional array can have index of different types:
```nim
type
  LightTower = array[1..10, array[north..west, BlinkLights]]
```

### Sequences
Sequences are similar to arrays but of dynamic length which may change
during runtime (like strings). Since sequences are resizable they are always
allocated on the heap and garbage collected.

Sequences are always indexed with an `int` starting at position 0. The len,
low and high operations are available for sequences too. The notation `x[i]`
can be used to access the i-th element of `x`.

Sequences can be constructed by the array constructor `[]` in conjunction
with the array to sequence operator `@`. Another way to allocate space for a
sequence is to call the built-in `newSeq` procedure.
```nim
var
  x: seq[int] # a reference to a sequence of integers
x = @[1, 2, 3, 4, 5, 6] # the @ turns the array into a sequence allocated on the heap
```
Sequence variables are initialized with `@[]`.
The for statement can be used with one or two variables when used with a sequence.
```nim
for value in @[3, 4, 5]:
  echo value
# --> 3
# --> 4
# --> 5

for i, value in @[3, 4, 5]:
  echo "index: ", $i, ", value:", $value
# --> index: 0, value:3
# --> index: 1, value:4
# --> index: 2, value:5
```

### Open Arrays
Often fixed-size arrays turn out to be too inflexible; procedures should
be able to deal with arrays of different sizes. The `openarray` type allows
this. Openarrays are always indexed with an int starting at position
`0`. Openarrays can only be used for parameters.
```nim
var
  fruits:   seq[string]       # reference to a sequence of strings that is initialized with '@[]'
  capitals: array[3, string]  # array of strings with a fixed size

capitals = ["New York", "London", "Berlin"]   # array 'capitals' allows assignment of only three elements
fruits.add("Banana")          # sequence 'fruits' is dynamically expandable during runtime
fruits.add("Mango")

proc openArraySize(oa: openArray[string]): int =
  oa.len

assert openArraySize(fruits) == 2     # procedure accepts a sequence as parameter
assert openArraySize(capitals) == 3   # but also an array type
```

### Varargs
A `varargs` parameter is like an openarray parameter. However, it is also a
means to implement passing a variable number of arguments to a procedure. The
compiler converts the list of arguments to an array automatically:
```nim
proc myWriteln(f: File, a: varargs[string]) =
  for s in items(a):
    write(f, s)
  write(f, "\n")

myWriteln(stdout, "abc", "def", "xyz")
# is transformed by the compiler to:
myWriteln(stdout, ["abc", "def", "xyz"])
```

### Objects
An object is a value type, which means that when an object is assigned to
a new variable all its components are copied as well.

Each object type `Foo` has a constructor `Foo(field: value, ...)` where all of
its fields can be initialized. Unspecified fields will get their default value.
```nim
type
  Person = object
    name: string
    age: int

var person1 = Person(name: "Peter", age: 30)

echo person1.name # "Peter"
echo person1.age  # 30
```
Object fields that should be visible from outside the defining module have
to be marked with `*`:
```nim
type
  Person* = object # the type is visible from other modules
    name*: string  # the field of this type is visible from other modules
    age*: int
```

### References & Pointers
Nim distinguishes between traced and untraced references. Untraced
references are also called pointers. Traced references point to objects in a
garbage-collected heap, untraced references point to manually allocated objects
or objects elsewhere in memory. Thus untraced references are unsafe. However,
for certain low-level operations (e.g. accessing the hardware), untraced
references are necessary.

Traced references are declared with the `ref` keyword; untraced references
are declared with the `ptr` keyword.
```nim
type
  Node = ref object
    le, ri: Node
    data: int

var n = Node(data: 9)
echo n.data
# no need to write n[].data; in fact n[].data is highly discouraged!
```
To allocate a new traced object, the built-in procedure new can be used:
```nim
var n: Node
new(n)
```
To deal with untraced memory, the procedures `alloc, dealloc and realloc` can
be used. The system module's documentation contains further details.

If a reference points to nothing, it has the value `nil`.

### Procedural Type
A procedural type is a pointer to a procedure. `nil` is
an allowed value for a variable of a procedural type. Nim uses procedural
types to achieve functional programming techniques:
```nim
proc greet(name: string): string =
  "Hello, " & name & "!"

proc bye(name: string): string =
  "Goodbye, " & name & "."

proc communicate(greeting: proc (x: string): string, name: string) =
  echo greeting(name)

communicate(greet, "John")
communicate(bye, "Mary")
```

## Modules
Modules are files. A module may gain access to the symbols of other module with the
`import` statement. Only top-level symbols that are marked with `*` are exported:
```nim
# Module A
var
  x*, y: int

proc `*` *(a, b: seq[int]): seq[int] =
  # allocate a new sequence:
  newSeq(result, len(a))
  # multiply two int sequences:
  for i in 0 ..< len(a): result[i] = a[i] * b[i]

when isMainModule:
  # test the new `*` operator for sequences:
  assert(@[1, 2, 3] * @[1, 2, 3] == @[1, 4, 9])
```
Each module has a special magic constant `isMainModule` that is true if the
module is compiled as the main file.

# Object Oriented Programming
## Inheritance
To enable inheritance with runtime type information the object needs to inherit
from `RootObj`. This can be done directly, or indirectly by inheriting from an
object that inherits from `RootObj`. Usually types with inheritance are also
marked as `ref` types even though this isn't strictly enforced. To check at
runtime if an object is of a certain type, the `of` operator can be used.
```nim
type
  Person = ref object of RootObj
    name*: string  # the * means that `name` is accessible from other modules
    age: int       # no * means that the field is hidden from other modules
  
  Student = ref object of Person # Student inherits from Person
    id: int                      # with an id field

var
  student: Student
  person: Person
assert(student of Student) # is true
# object construction:
student = Student(name: "Anton", age: 5, id: 2)
echo student[]
```

# References
- [Nim By Example](https://nim-by-example.github.io/getting_started/)
- [Nim Notes](https://scripter.co/tags/nim/)
- [Nim Programming](https://ssalewski.de/nimprogramming.html)
- [Nim Days](https://xmonader.github.io/nimdays/book_intro.html)
- [Peter's DevLog](https://peterme.net/)
- [Nim Manual](https://nim-lang.org/docs/manual.html)
- [Nim Std Lib](https://nim-lang.org/docs/lib.html)
- [Internet of Tomohiro](https://internet-of-tomohiro.netlify.app/index.en.html)

C FFI:

- [Creating a Nim Wrapper](https://blog.johnnovak.net/2018/07/07/creating-a-nim-wrapper-for-fmod/)
- [Nim in Action: Chapter 8](https://livebook.manning.com/book/nim-in-action/chapter-8/)
- [Nim C Biding](https://nekonya.cyou/2020/05/17/nim-xue-xi-ji-lu/)
- [Nim Wrapping C](https://goran.krampe.se/2014/10/16/nim-wrapping-c/)

