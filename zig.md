# Zig Language
Excluded features:

- string type
- classes/inheritance/runtime polymorphism
- interfaces/protocols
- constructors/destructors/RAII (zig uses defer/errdefer keyword)
- function/operator overloading
- closures or lambdas
- garbage collection
- exceptions (zig uses error codes instead)

Added features:

- Optional Values are first class citizen, replacing null pointers
- Errors as first class citizen algebraic types
- Structs as namespaces
- Compile time code execution replace macros
- Loops, labeled blocks, and if statements are expressions
- Slices

Coding style: `camelCaseFunctionName`, `TitleCaseTypeName`, `snake_case_variable_name`.

## Imports
`@import` to import stdlib/files/etc and assign to a namespace:

- `@import` is built-in function, evaluated at compile time.
- takes in a file, and gives you a struct type based on that file. All
declarations labeled as `pub` will end up in result struct for use.
- `@import("std")` is a special case in the compiler, and gives you access
to the standard library. Other `@imports` will take in a file path, or a
package name.
```zig
const std = @import("std");
```

## Variables
Defined with either `const` or `var` keyword. `const` declare a variable's value immutable.
Variable shadowing is not allowed.
```zig
const x: i32 = 5
```
Type of the variable can be inferred from its initializer:
```zig
const x = 5
```
Every variable must be assigned a value while being declared. It is possible
to assign the `undefined` value.
Each declared variable must be used but it is possible to assign a varible
to the thow-away variable `_`.

Constants in the global scope are by default comptime values.

Overflows are detectable illegal behaviour: use overflow operator if needed
(`+%`, `-%`, `*%`, `+%=`, `-%=`, `*%=`).

## Functions
Defined with the `fn` keyword. The `pub` keyword make it exportable from
the current scope (for the main function for example).
```zig
pub fn main() void {}
```
It is not possible to ignore return values for function (use `_` if you need).
All function arguments are immutable.

## Built-in Functions
Prefixed by `@`.

## Casting
- `@as` only allowed when the casting operation is unambiguous and safe.
- `@truncate` explicitly cast to a smaller-size integer with the same signedness,
by removing the most-significant bits.
- `@bitCast` to cast between same sized types, preserving the bitpattern
(between signed and unsigned).
- `@intCast` for runtime safety-checked narrowing conversions.
```zig
var x = @as(u8, 5);     // type inference allows the compiler to determine that x is type u8
var y = @as(i32, x);

var x = @as(u16, 513);    // x in binary: 0000001000000001
var y = @truncate(u8, x); // y in binary:         00000001

var x = @as(u8, 180);     // x in binary: 10110100 (value is 180)
var y = @bitCast(i8, x);  // y in binary: 10110100 (value is -76)

var x = @as(i16, 180);
var y = @intCast(u8, x); // this is fine
var z = @intCast(i8, y); // this will crash
```

## Other
- `@This` returns the type of the inner most struct/enum/union.
  Used often with anonymous struct and/or generics.

## Structs
Struct are declared by assigning them a name using the `const` keyword. Structs
can have default values and can coerce into an other struct as long as the
values can be figured out:
```zig
const Vec2 = struct{
    x: f64,
    y: f64,
    z: f64 = 0.0
};

pub fn main() void {
    var v = Vec2{.y = 1.0, .x = 2.0};
    std.debug.print("v: {}\n", .{v});
}
```
It is possible to drop functions into an struct to make it work like a
OOP-style object.
There is syntactic sugar where if you make the functions' first parameter
be a pointer to the object.
The typical convention is to make this obvious by calling the variable
`self`.
```zig
const LikeAnObject = struct{
    value: i32,

    fn print(self: *LikeAnObject) void {
        std.debug.print("value: {}\n", .{self.value});
    }
};

pub fn main() void {
    var obj = LikeAnObject{.value = 47};
    obj.print(); // or
    LikeAnObject.print(obj);
}
```
The std.debug.print's second parameter is a tuple: it is an anonymous
struct with numbered fields.
Their fields can be accessed with their position number:
```zig
var x = .{"foo", 34};
std.debug.print("{}\n", .{x.@"0"});
std.debug.print("{}\n", .{x.@"1"});
std.debug.print("{}\n", .{x.@"2"}); // error: no member named '2' in struct...
```

## Unions
Union types do not have a guaranteed memory layout. They cannot be used
to reinterpret memory. Accessing a field in a union which is not active is
detectable illegal behavior.
```zig
const Payload = union {
    int: i64,
    float: f64,
    bool: bool,
};
test "simple union" {
    var payload = Payload{ .int = 1234 };
    payload.float = 12.34; // error => test "simple union"...access of inactive union field
}
```

## Enums
Defined with the `enum` keyword.

- In some cases you can shortcut the name of the enum.
- You can set the value of an enum to an integer, but it does not automatically coerce,
  you have to use `@enumToInt` or `@intToEnum` to do conversions.
```zig
const EnumType = enum{
    EnumOne,
    EnumTwo,
    EnumThree = 3
};

pub fn main() void {
    std.debug.print("One: {}\n", .{EnumType.EnumOne});
    std.debug.print("Two?: {}\n", .{EnumType.EnumTwo == .EnumTwo});
    std.debug.print("Three?: {}\n", .{@enumToInt(EnumType.EnumThree) == 3});
}
```

## Tagged Unions
Tagged unions are unions which use an enum used to detect which field is
active. Here we make use of a switch with payload capturing; captured values
are immutable so pointers must be taken to mutate the values:
```zig
const Tag = enum { a, b, c };

const Tagged = union(Tag) { a: u8, b: f32, c: bool };

test "switch on tagged union" {
    var value = Tagged{ .b = 1.5 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*b| b.* = !b.*,
    }
    expect(value.b == 3);
}
```
The tag type of a tagged union can also be inferred. Shorthand for above:
```zig
const Tagged = union(enum) { a: u8, b: f32, c: bool };
```
`void` member types can have their type omitted from the syntax. Here,
none is of type `void`:
```zig
const Tagged2 = union(enum) { a: u8, b: f32, c: bool, none };
```

## Arrays & Slices
An Array is a contiguous memory with comptime known length. Its length
is accessible with the `len` field of the array.
Arrays are zero-indexed.
```zig
var array: [3]u32 = [3]u32{47, 47, 47};
// also valid:
// var array = [_]u32{47, 47, 47};

var invalid = array[4]; // error: index 4 outside array of size 3.
std.debug.print("array[0]: {}\n", .{array[0]});
std.debug.print("length: {}\n", .{array.len});
```
A slice is run-time known length. They are constructed from arrays or other
slices with the slicing operation.
Note: the interval parameter in slicing operation is open (non-inclusive)
on the big end.
Attempting to access beyond the range of the slice is a runtime panic.
```zig
var array: [3]u32 = [_]u32{47, 47, 47};
var slice: []u32 = array[0..2];
// also valid:
// var slice = array[0..2];

var invalid = slice[3]; // panic: index out of bounds

std.debug.print("slice[0]: {}\n", .{slice[0]});
std.debug.print("length: {}\n", .{slice.len});
```

## Strings
Strings literals are null-terminated utf8 encoded arrays of `const u8` bytes.
- length does not include the null terminator
- indices are by byte
```zig
const string = "hello 世界";
const world = "world";
var slice: []const u8 = string[0..5];

std.debug.print("string {}\n", .{string});
std.debug.print("length {}\n", .{world.len});
std.debug.print("null {}\n", .{world[5]});
std.debug.print("slice {}\n", .{slice});
std.debug.print("huh? {}\n", .{string[0..7]});
```
Const arrays can be coerced into const slices:
```zig
fn foo() []const u8 {  // note function returns a slice
    return "foo";      // but this is a const array.
}
```

## Control Structures
If / switch / For statements are also expressions.

### If
```zig
if (v < 0) {
    return "negative";
} else {
    return "non-negative";
}
```
As an expression: `x += if (a) 1 else 2;`

### Switch
```zig
var x: i8 = 10;
switch (x) {
    -1...1 => {
        x = -x;
    },
    10, 100 => {
        //special considerations must be made
        //when dividing signed integers
        x = @divExact(x, 10);
    },
    else => {},
}
```

### For
For loop that works only on arrays and slices:
```zig
var array = [_]i32{47, 48, 49};

for (array) | value | {
    std.debug.print("array {}\n", .{value});
}
for (array) | value, index | {
    std.debug.print("array {}:{}\n", .{index, value});
}
```
While loops for general purpose iteration
(first block is evaluated at the beginning of the loop and the second block is evaluated at the end of the loop):
```zig
while (i < x) : (i += 1) { ... }
```

## Error Handling
Errors are special union types, you denote that a function can error by
prepending `!` to the front.
You throw the error by simply returning it as if it were a normal return.

If you write a function that can error, you must decide what to do with it
when it returns.
Two common options are `try` which simply forwards the error to be the error
for the function and `catch` explicitly handles the error.
```zig
const MyError = error{
    GenericError
};

fn foo(v: i32) !i32 {
    if (v == 42) return MyError.GenericError;
    return v;
}

pub fn main() !void {
    // catch traps and handles errors bubbling up
    _ = foo(42) catch |err| {
        std.debug.print("error: {}\n", .{err});
    };

    // try won't get activated here.
    std.debug.print("foo: {}\n", .{try foo(47)});

    // this will ultimately cause main to print an error trace and return nonzero
    _ = try foo(42);
}
```
You can also use if to check for errors:
```zig
// note that it is safe for wrap_foo to not have an error ! because
// we handle ALL cases and don't return errors.
fn wrap_foo(v: i32) void {    
    if (foo(v)) | value | {
        std.debug.print("value: {}\n", .{value});
    } else | err | {
        std.debug.print("error: {}\n", .{err});
    }
}
```

## Defer
Allow statement to execute on lexical scope exit. Multiple defers get executed
in reverse order.
```zig
var x: i16 = 5;
{
    defer x += 2;
    expect(x == 5);
}
expect(x == 7);
```
There is also `errdefer` which are executed only when the function returns an
error.
Defer is used to free dynamically allocated memory or deinit ressources.

## Pointers
Declared by prepending `*` to the front of the type.
They are dereferenced, with the `.*` field.
Pointers need to be aligned correctly with the alignment of the value it's
pointing to.
```zig
pub fn printer(value: *i32) void {
    std.debug.print("pointer: {}\n", .{value});
    std.debug.print("value: {}\n", .{value.*});
}

pub fn main() void {
    var value: i32 = 47;
    printer(&value);
}
```
For structs, similar to Java, you can dereference the pointer and get the
field in one shot with the `.` operator.
Note this only works with one level of indirection, so if you have a pointer
to a pointer, you must dereference the outer pointer first.
```zig
const MyStruct = struct {
    value: i32
};

pub fn printer(s: *MyStruct) void {
    std.debug.print("value: {}\n", .{s.value});
}

pub fn main() void {
    var value = MyStruct{.value = 47};
    printer(&value);
}
```
Zig allows any type (not just pointers) to be nullable, but note that they
are unions of the base type and the special value `null`. To access the
unwrapped optional type, use the `.?` field:
```zig
var value: i32 = 47;
var vptr: ?*i32 = &value;
var throwaway1: ?*i32 = null;
var throwaway2: *i32 = null; // error: expected type '*i32', found '(null)'

std.debug.print("value: {}\n", .{vptr.*}); // error: attempt to dereference non-pointer type
std.debug.print("value: {}\n", .{vptr.?.*});
```
Note: when you use pointers from C ABI functions they are automatically
converted to nullable pointers.

Another way of obtaining the unwrapped optional pointer is with the `if`
statement:
```zig
fn nullChoice(value: ?*i32) void {
    if (value) | v | {
        std.debug.print("value: {}\n", .{v.*});
    } else {
        std.debug.print("null!\n", .{});
    }
}

var value: i32 = 47;
var vptr1: ?*i32 = &value;
var vptr2: ?*i32 = null;

nullChoice(vptr1);
nullChoice(vptr2);
```

# Zig New Concepts
## Optional Values
Optionnal types are declared `?T`. It means that the type can be either of
type `T` or `null`.

In Zig you cannot do anything with a pointer that is potentially null. You
have to unwrap it before Zig lets you do anything with it.
One way is using `orelse`:
```zig
const first = list.first orelse return null;
```
If `list.first` contains a `null` then `return null` will be executed.
A number of control flow statements in Zig has this form to deal with optionals:
```zig
if (optional) |value| {}
while (optional) |value| {}
for (optional_elements) |value| {}
```
The `|value|` part unwraps an optional within the conditional. So e.g. this
gives the opportunity to easily use `while` with an iterator. The code block is
only repeated each time it is possible to unwrap and optional. Thus as soon
as the `next()` function inside while-loop returns a `null` the iteration stops.

## Labelled Blocks
Blocks in Zig are expressions and can be given labels, which are used to
yield values. Blocks yield values, meaning that they can be used in place
of a value. The value of an empty block `{}` is a value of the type `void`.
```zig
const count = blk: {
    var sum: u32 = 0;
    var i: u32 = 0;
    while (i < 10) : (i += 1) sum += i;
    break :blk sum;
};
expect(count == 45);
```
Loops can be given labels, allowing you to `break` and `continue` to outer loops:
```zig
var count: usize = 0;
  outer: for ([_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }) |_| {
    for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
      count += 1;
      continue :outer;
    }
  }
  expect(count == 8);
```
Loops can be expressions. Like `return`, `break` accepts a value. This can be
used to yield a value from a loop. Loops in Zig also have an else branch on
loops, which is evaluated when the loop is not exited from with a `break`:
```zig
return while (i < end) : (i += 1) {
    if (i == number) {
      break true;
    }
  } else false;
```
  
# Metaprogramming
Zig's metaprogramming is driven by a few basic concepts:

- types are valid values at compile-time.
- most runtime code will also work at compile-time.
- struct field evaluation is compile-time duck-typed.
- the zig standard library gives you tools to perform compile-time reflection.

## Comptime Function Call
```zig
fn multiply(a: i64, b: i64) i64 {
    return a * b;
}

pub fn main() void {
    const len = comptime multiply(4, 5);
    const my_static_array: [len]u8 = undefined;
}
```
Note how the function definition doesn’t have any attribute that states
it must be available at compile-time. It’s just a normal function, and we
request its compile-time execution at the call site.

But if a function parameter is comptime then the function is always comptime.
```zig
fn insensitive_eql(comptime uppr: []const u8, str: []const u8) bool {}
```
It is also possible to add comptime block with `comptime {...}` to make the
equivalent of `Static_assert` in C.

## Generic Structs
To create a generic struct, all you have to do is create a function that
takes a type argument and return a new struct definition.
```zig
fn Vec2Of(comptime T: type) type {
    return struct{
        x: T,
        y: T
    };
}

const V2i64 = Vec2Of(i64);
var vi = V2i64{.x = 47, .y = 47};
```
The function returns a type, which means it can only be called at `comptime`.

## Generic Functions
Made with the `comptime` argument. This function can be used with any kind of
slice:
```zig
/// Compares two slices and returns whether they are equal.
pub fn eql(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    for (a) |item, index| {
        if (b[index] != item) return false;
    }
    return true;
}
```

## C Interface
### Types
- `[]const u8`: Zig string, an array (length knowed at comptime) of `u8`. No sentinel.
- `[:0]const u8`: slice of `u8` (length knowed at runtime).
- `[*:0]const u8`: pointer to a zone of unknowed size, ending with `0`.
- `[*c]const u8`: c string, ending with `0`.

The first 2 types are Zig types while the latter 2 types are c types. To convert between
them a cast is not enough: the Zig type need to know the length of the memory zones.

The function `std.mem.span(ctype)` convert a ctype pointer (endind with a sentinel) to
a Zig array/slice (with a length).
See [Pass a C string into a Zig function](https://stackoverflow.com/questions/72736997/how-to-pass-a-c-string-into-a-zig-function-expecting-a-zig-string?rq=1)

# Zig Build
Zig build scripts (usually named `build.zig`) are ordinary Zig programs with
a special exported function (`pub fn build(b: *std.build.Builder) void`)
utilizing `std.build.Builder`.
The build runner is invoked by `zig build` which in turn invokes `build.zig:build()`.

This will create DAG of `std.build.Step` nodes where each `Step`
executes a part of our build process. Each step has a set of dependencies
that need to be made before the step itself is made. A step is created with
`Builder.step`:
```zig
pub fn build(b: *std.build.Builder) void {
    const named_step = b.step("step-name", "This is what is shown in help");
}
```
User can invoke named steps by calling `zig build step-name` or predefined
steps (e.g. `install`).

## Compiling Executables
Builder exposes `Builder.addExecutable` which will create a new `LibExeObjStep`.
```zig
pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable("fresh", "src/main.zig");

    const target = b.standardTargetOptions(.{});
    exe.setTarget(target);

    const mode = b.standardReleaseOptions();
    exe.setBuildMode(mode);

    // will create a 'zig compile' command, same as 'zig build'
    const compile_step = b.step("compile", "Compiles src/main.zig");
    compile_step.dependOn(&exe.step);
}
```

## Cross Compilation
Cross compilation is enabled by setting the target and build mode of our program:

- `exe.setBuildMode(.ReleaseSafe);` will pass `-O ReleaseSafe` to the build invocation.
- `exe.setTarget(...);` will set what `-target ...` will see.
- `Builder.standardReleaseOptions`/`Builder.standardTargetOptions`: convenience
functions to make both the build mode and the target available as a command
line option.

Invoke `zig build --help` to see command line options added by
`standardTargetOptions` (first two) and `standardReleaseOptions` (rest)
```
zig build -Dtarget=x86_64-windows-gnu -Dcpu=athlon_fx
zig build -Drelease-safe=true
zig build -Drelease-small
```

## Installing Artifacts
Installation involves making a step on the install step of the Builder:

- the `install` is step always created and accessed via `Builder.getInstallStep()`
- `InstallArtifactStep` is build step responsible for copying exe artifact to
install directory.
```zig
pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable("fresh", "src/main.zig");

    const install_exe = b.addInstallArtifact(exe);
    b.getInstallStep().dependOn(&install_exe.step);
}
```
This will now do several things:

- `b.addInstallArtifact` creates a new `InstallArtifactStep` that copies
  the compilation result of `exe` to `$prefix/bin` (usually zig-out)
- `InstallArtifactStep` (implicitly) depends on `exe` so will build exe as well
- invoke by `zig build install` (or `just zig build` for short)
- the `InstallArtifactStep` registers the output file for `exe` in a list
  that allows uninstalling it again
- uninstall the artifact (but not directories!) by invoking `zig build uninstall`

# Receipes
- [Calling Zig code from Python](https://zig.news/pyrolistical/how-to-escape-python-and-write-more-zig-228m)
- [Project with C dependency/patching](https://github.com/zigzap/zap)

## References
- [Zig in 30 minutes](https://gist.github.com/ityonemo/769532c2017ed9143f3571e5ac104e50)
- [Zig Crash Course](https://ikrima.dev/dev-notes/zig/zig-crash-course/)
- [Zig Language Reference](https://ziglang.org/documentation/0.10.1/)
- [Zig Code Examples](https://ziglang.org/learn/samples/)
- [Testing and building C projects with Zig](https://renato.athaydes.com/posts/testing-building-c-with-zig.html)
- [Using Zig As Cross Platform C Toolchain](https://ruoyusun.com/2022/02/27/zig-cc.html)
- [Dev Blog](https://www.openmymind.net/)
- [Zig Snippets](https://github.com/sayden/zig-snippets)
- [Zig Notes](https://dev.to/crinklywrappr/zig-notes-378m)
- [Awesome Zig](https://www.trackawesomelist.com/catdevnull/awesome-zig/readme/)
- [Build Compile Commands with Zig](https://codeberg.org/john-nanney/zig_writecc)
- [Extend a C/C++ Project with Zig](https://zig.news/kristoff/extend-a-c-c-project-with-zig-55di)
- [Testing and building C projects with Zig](https://renato.athaydes.com/posts/testing-building-c-with-zig.html)
- [Interaction with C in Zig](https://dev.to/dannypsnl/interaction-with-c-in-zig-540c)
- [Zig Package Manager -- WTF is Zon](https://zig.news/edyu/zig-package-manager-wtf-is-zon-558e)

