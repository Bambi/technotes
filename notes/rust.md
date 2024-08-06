# Rust
## Basics
Function call with a `!` are macro call:
```rust
fn main() {
    println!("Hello, World!");
}
```
`let` declares a unmuttable variable (like Nim). Use `let mut` to declare a
muttable variable (like `var` in Nim).
Variable declaration use the same syntax as Zig and Nim: `let bigint: i64 = 0;`.

The `()` is the empty type (like `void`).

There is no implicit type conversion, you must use a `cast`:
```rust
fn main() {
    let mut sum = 0.0;
    for i in 0..5 {
        sum += i as f64;
    }
    println!("sum is {}", sum);
}
```
Loops ranges are not inclusive: the previous loop goes from 0 to 4.

Storage of Rust values is up to the types being used and how they are implemented.
Local variables live on the stack. Anything inside a `Box`, `Vec`, `Rc`, or `Arc`
will be put on the heap, but the actual Box struct itself (i.e. the pointer)
will live on the stack.

### Default Values
Rust compiler will emit an error if you use an un-initialized variable. Theses
are just sensible default values.

| Type           | Default Value
|----------------|----------------
| `bool`         | `false`
| `char`         | `'\0'`
| `Option`	     | `None`
| `String, &str` | `""`
| `Vec<usize>`	 | `[]`
| `[usize; N]`   | `[0, 0, …, 0]`
| `&[u32]`       | `[]`
| `f64, f32…`    | `0.`
| `usize, u32…`  | `0`

### Functions
There is type inference in Rust but function types must be explicit.
The return value of a function is either giver by the `return` statement or by the last statement:
```rust
fn sqr(x: f64) -> f64 {
    x * x
}
```
Parameters may be passed by reference (`&` and `*`):
```rust
fn by_ref(x: &i32) -> i32{
    *x + 1
}
let i = 10;
let res1 = by_ref(&i);
let res2 = by_ref(&41);
```
Use `&mut` to pass a reference that can be modified.

### Arrays & Slices
Arrays are immutable and their size is fixed and knowed at comptime. The type of an array includes its size.
```rust
fn sum(values: &[i32]) -> i32 {
    let mut res = 0;
    for i in 0..values.len() {
        res += values[i]
    }
    res
}

fn main() {
    let arr = [10,20,30,40];
    // look at that &
    let res = sum(&arr);
    println!("sum {}", res);
}
```
A C programmer pronounces `&` as 'address of' ; a Rust programmer pronounces it
'borrow'. This is going to be the key word when learning Rust. Borrowing
is the name given to a common pattern in programming; whenever you pass
something by reference (as nearly always happens in dynamic languages)
or pass a pointer in C. Anything borrowed remains owned by the original owner.

Use `{:?}` to print an array:
```rust
let ints = [1, 2, 3];
println!("ints {:?}", ints);
```
Slices give you different views of the same array:
```rust
fn main() {
    let ints = [1, 2, 3, 4, 5];
    let slice1 = &ints[0..2];
    let slice2 = &ints[1..];  // open range!

    println!("ints {:?}", ints);
    println!("slice1 {:?}", slice1);
    println!("slice2 {:?}", slice2);
}
```

### Optionnal Value
The size of a slice is knowed at runtime and getting a slice element out of its bounds
will panic. The `get` method does not panic:
```rust
fn main() {
    let ints = [1, 2, 3, 4, 5];
    let slice = &ints;
    let first = slice.get(0);
    let last = slice.get(5);

    println!("first {:?}", first);
    println!("last {:?}", last);
}
// first Some(1)
// last None
```
`last` failed but returned something called `None`. `first` is fine, but
appears as a value wrapped in `Some`. Welcome to the `Option` type! It may
be either `Some` or `None`:
```rust
pub enum Option<T> {
    None,
    Some(T),
}
```
The Option type has some useful methods: `is_some()`, `is_none()`, `unwrap()`.

### Vectors
These are re-sizeable arrays and behave much like Python `List`:
```rust
let mut v = Vec::new();
v.push(10);
v.push(20);
v.push(30);

let first = v[0];  // will panic if out-of-range
let maybe_first = v.get(0);
```
Vectors must be `mut`. Use `vec!` macro to initialize a vector:
```rust
let mut v1 = vec![10, 20, 30];
v1.pop();

let mut v2 = Vec::new();
v2.push(10);
v2.push(20);

assert_eq!(v1, v2);

v2.extend(0..2);
assert_eq!(v2, &[10, 20, 0, 1]);
```

### Iterators
It is an 'object' with a `next` method which returns an `Option`. As long
as that value is not `None`, we keep calling next:
```rust
let mut iter = 0..2;
assert_eq!(iter.next(), Some(1));
assert_eq!(iter.next(), Some(2));
assert_eq!(iter.next(), None);
```
They are often used with `for` loops: `for i in arr.iter()`.

### Strings
The `String` type, like `Vec`, allocates dynamically and is resizeable.
But string litterals are not `Strings`, they are `&str` (string slice):
```rust
fn dump(s: &str) {
    println!("str '{}'", s);
}

fn main() {
    let text = "hello dolly";  // the string slice
    let s = text.to_string();  // it's now an allocated string

    dump(text);
    dump(&s);
}
```
Under the hood, String is basically a `Vec<u8>` and `&str` is `&[u8]`.
Like a vector, you can `push` a character and `pop` one off the end of `String`.

The `format!` macro is a very useful way to build up more complicated strings using the same format strings as `println!`:
```rust
fn array_to_str(arr: &[i32]) -> String {
    let mut res = '['.to_string();
    for v in arr {
        res += &v.to_string();
        res.push(',');
    }
    res.pop();
    res.push(']');
    res
}

fn main() {
    let arr = array_to_str(&[10, 20, 30]);
    let res = format!("hello {}", arr);

    assert_eq!(res, "hello [10,20,30]");
}
```

### Matching
`match` can operate like a C `switch` statement, and like other Rust constructs can return a value:
```rust
let text = match n {
    0 => "zero",
    1 => "one",
    2 => "two",
    _ => "many",
};
```
The `_` is like C `default` - it's a fall-back case. If you don't provide one
(or treat all possible values) then rustc will consider it an error.

Rust `match` statements can also match on ranges. Note that these ranges
have *three* dots and are inclusive ranges, so that the first condition
would match 3:
```rust
let text = match n {
    0...3 => "small",
    4...6 => "medium",
    _ => "large",
 };
```

### Result Types
An `Result` is a value that contain something or an error (like an `Option`). It is
often used as a return values for functions.
A `Result` is defined by 2 type parameters, for the `Ok` and the `Err` values. A `Result`
has 2 compartments, one labelled `Ok` and the other `Err`: 
```rust
fn good_or_bad(good: bool) -> Result<i32,String> {
    if good {
        Ok(42)
    } else {
        Err("bad".to_string())
    }
}

fn main() {
    println!("{:?}",good_or_bad(true));
    //Ok(42)
    println!("{:?}",good_or_bad(false));
    //Err("bad")

    match good_or_bad(true) {
        Ok(n) => println!("Cool, I got {}",n),
        Err(e) => println!("Huh, I just got {}",e)
    }
    // Cool, I got 42
}
```
A typical usage would be:
```rust
fn read_to_string(filename: &str) -> Result<String,io::Error> {
    let mut file = match File::open(&filename) {
        Ok(f) => f,
        Err(e) => return Err(e),
    };
    let mut text = String::new();
    match file.read_to_string(&mut text) {
        Ok(_) => Ok(text),
        Err(e) => Err(e),
    }
}
```
The `?` operator does almost exactly what the match on `File::open` does; if
the result was an error, then it will immediately return that error. Otherwise,
it returns the `Ok` result:
```rust
fn read_to_string(filename: &str) -> io::Result<String> {
    let mut file = File::open(&filename)?;
    let mut text = String::new();
    file.read_to_string(&mut text)?;
    Ok(text)
}
```

### Tuples
Tuples are a convenient to return multiple values from a function:
```rust
fn add_mul(x: f64, y: f64) -> (f64,f64) {
    (x + y, x * y)
}

fn main() {
    let t = add_mul(2.0,10.0);

    // can debug print
    println!("t {:?}", t);
    // can 'index' the values
    println!("add {} mul {}", t.0,t.1);
    // can _extract_ values
    let (add,mul) = t;
    println!("add {} mul {}", add,mul);
}
```
Tuples can contain different types.
`enumerate` is like the Python generator of the same name:
```rust
for t in ["zero","one","two"].iter().enumerate() {
    print!(" {} {};",t.0,t.1);
}
//  0 zero; 1 one; 2 two;
```
`zip` combines two iterators into a single iterator of tuples containing
the values from both:
```rust
let names = ["ten","hundred","thousand"];
let nums = [10,100,1000];
for p in names.iter().zip(nums.iter()) {
    print!(" {} {};", p.0,p.1);
}
//  ten 10; hundred 100; thousand 1000;
```

### Structs
A struct contain named fields:
```rust
struct Person {
    first_name: String,
    last_name: String
}

fn main() {
    let p = Person {
        first_name: "John".to_string(),
        last_name: "Smith".to_string()
    };
    println!("person {} {}", p.first_name,p.last_name);
}
```
A function can be made into an *associated function* of a struct by putting it
into an `impl` block:
```rust
impl Person {

    fn new(first: &str, name: &str) -> Person {
        Person {
            first_name: first.to_string(),
            last_name: name.to_string()
        }
    }
    fn full_name(&self) -> String {
        format!("{} {}", self.first_name, self.last_name)
    }
}
let p = Person::new("John","Smith");
println!("fullname {}", p.full_name());
```
The keyword `Self` refers to the struct type:


- no `self` argument: you can associate functions with structs, like the
  `new` "constructor".
- `&self` argument: can use the values of the struct, but not change them
- `&mut self` argument: can modify the values
- `self` argument: will consume the value, which will move.

The `#[derive(Debug)]` _directive_ makes the compiler generate a Debug
implementation, which is very helpful to display a struct with `println!`
or `format!`.

## Ownership & Borrowing
Theses concepts are used to ensure that no memory is deallocated before its
last use. If you try to do that you will have a compile error instead of a
runtime error.
In Rust when you pass a variable to a function, the function takes ownership
of the memory for that variable:
```rust
#[derive(Debug)]  // that macro generates an implementation of the Debug Trait
struct SomeStruct {
    num: i32,
}

fn print_struct(the_struct: SomeStruct) {
    println!("{:?}", the_struct); // "{:?}": use the implementation of Debug 
}

fn main() {
    let my_struct = SomeStruct { num:2 };
    print_struct(my_struct);
    print_struct(my_struct); // Error!
}
```
Outside of workarounds like `Rc`, a value cannot be owned by more than one variable.
In the previous example `my_struct` have been moved to the `the_struct` argument
variable on the first call to `print_struct`. After this the `my_struct` variable
does not exist anymore (the variable lost its ownership on the data), hence
the error on the second call to `print_struct`.

There are 3 ways to work arround this problem:

- clone the data: Add the `Clone` trait to your struct and call `clone()` on
  your first function call: `print_struct(my_struct.clone())`. This will pass
  a copy of the struct, which may pose a performance problem.
- copy the data: Add the `Copy` trait to your struct (the `Copy` trait requires
  that a `Clone` trait has been implemented). The copy trait makes a full copy
  of your data, just like the clone trait, but this time its usage is implicit:
  with each call of `print_struct` a copy of the struct is done automatically.
- pass a _read only reference_ to the function. It is a way of handing off a
  variable without handing off its ownership. You can create as many read-only
  references of a variable as you want. Modify the function signature to
  `fn print_struct(the_struct: &SomeStruct)` and call it with
  `print_struct(&my_struct);`.

Rust has also the concept of _mutable reference_ to allow a function to modify
its parameter but contrary to _read only references_ you can only have one
mutable reference at time:
```rust
fn mutate_struct(the_struct: &mut SomeStruct) {
    the_struct.num = 5
}
let mut my_struct = SomeStruct { num:1 };
mutate_struct(&mut my_struct);
```

## Lifetimes
Lifetimes are what the Rust compiler uses to keep track of how long references are valid for.
Lifetime annotations enable you to tell the borrow checker (which takes care
of allocating and freeing memory) how long references are valid for.
In many cases, the borrow checker can infer the correct lifetimes but sometimes
it needs your help to figure it out.

Lifetimes are annotated by a leading apostrophe followed by a variable name,
we often use single, lowercase letters, starting from `'a`, `'b`.

The following example:
```rust
let x;
{                           // create new scope
    let y = 42;
    x = &y;
}                           // y is dropped
println!("The value of 'x' is {}.", x);
```
will not compile with the error `error[E0597]: 'x' does not live long enough`
because the inner scope (lifetime) ends and values with that lifetime are
invalidated.

When writing functions that accept references as arguments, the compiler can
infer the correct lifetimes in many cases. When lifetime annotations are implicit,
we call this _lifetime elision_.

Lifetime annotations in functions can be elide if one of the following is true:

- The function doesn’t return a reference
- There is exactly one reference input parameter
- The function is a method, taking `&self` or `&mut self` as the first parameter

You can’t return a reference from a function without also passing in a reference
(execpt with the `'static` lifetime).
If your function takes exactly one reference parameter, then you’ll be fine
without annotations:
```rust
fn f(s: &str) -> &str {
    s
}
```
But if you add another input parameter:
```rust
fn f<'a, 'b>(s: &'a str, t: &'b str) -> &'??? str {
    if s.len() > 5 { s } else { t }
}
```
the compiler do not know what will be the lifetime of the return value.
One way to correct this is to give both input parameters the same lifetime
annotation:
```rust
fn f<'a>(s: &'a str, t: &'a str) -> &'a str {
    if s.len() > 5 { s } else { t }
}
```
An other way if you know exactly which parameter you're returning is to annotate
that specific lifetime:
```rust
fn f<'a, 'b>(s: &'a str, _t: &'b str) -> &'a str {
    s
}
```
In summary, lifetimes:

- are only relevant for references
- do not change the lifetime of the parameters
- sometimes they can be inferred

See [here](https://blog.logrocket.com/understanding-lifetimes-in-rust/)
for details, especially for references in structures.

## Modules & Cargo
### Modules
A module is a namespace. In a module all exported symbols must be marked `pub`:
```rust
mod foo {
    #[derive(Debug)]
    pub struct Foo {
        s: &'static str
    }

    impl Foo {
        pub fn new(s: &'static str) -> Foo {
            Foo{s: s}
        }
    }
}

fn main() {
    let f = foo::Foo::new("hello");
    println!("{:?}", f);
}
```
Within a module, all items are visible to all other items.

It is usual to put modules in separate files. In the previous example you can put
the content of the `foo` module in a file `foo.rs` (without the `mod foo` block)
and use `mod foo;` at the beginning of the main file. When compiling the main file
with `rustc main.rs` will also compile `foo.rs`.
The compiler will also look at `<mod name>/mod.rs` for the module file.

### Crates
It is the compilation unit for rust: it is either an executable or a library.
To create a static library:
```
src$ rustc foo.rs --crate-type=lib
src$ ls -l libfoo.rlib
-rw-rw-r-- 1 steve steve 7888 Jan  5 13:35 libfoo.rlib
```
We can now link this into our main program:
```
src$ rustc main.rs --extern foo=libfoo.rlib
```
The main program use the library with the `extern crate` statement which include
an implicit `mod` statement:
```rust
extern crate foo;

fn main() {
    let f = foo::Foo::new("hello");
    println!("{:?}", f);
}
```

### Cargo
Dependency tool for Rust: can download sources for modules for a specific version
and all required dependencies. Main commands are:

- `cargo init`: initialize a new project
- `cargo build`: build a project
- `cargo run`: launch a project

# Tips & Trics
## Generic IO (File / stdin-out)
Stdin-out and File are @ different types in Rust (Stdin or Stdout and File).
3 solutions for this problem:

- use libc::File
- use a `Box` type (soft polymorphic reference)
- use a [generic function](https://stackoverflow.com/questions/36088116/how-to-do-polymorphic-io-from-either-a-file-or-stdin-in-rust?rq=3)

# References
- [Rust Playground](https://play.rust-lang.org/)
- [A Gentle Introduction To Rust](https://stevedonovan.github.io/rust-gentle-intro/)
- [Command Line Applications in Rust](https://rust-cli.github.io/book/index.html)
- [Rust By Example](https://doc.rust-lang.org/rust-by-example/)
- [Rust Documentation: Crate std](https://doc.rust-lang.org/stable/std/index.html)
- [Serde Documentation](https://serde.rs/)
- [Working with Files and Doing File I/O](https://www.linuxjournal.com/content/getting-started-rust-working-files-and-doing-file-io)
- [Global Variables in Rust](https://www.sitepoint.com/rust-global-variables/)
- [Getting started with the Rust package manager, Cargo](https://opensource.com/article/20/3/rust-cargo)
- [Wrapping around generic IO?](https://www.reddit.com/r/rust/comments/3gtpy9/wrapping_around_generic_io/)
- [Learning Rust: Interfacing with C](https://piware.de/post/2021-08-27-rust-and-c/)
- [Rust by Example](https://riptutorial.com/rust)
- [Using C Libraries in Rust](https://medium.com/dwelo-r-d/using-c-libraries-in-rust-13961948c72a)
- [Apprendre Rust en 30 mins](https://github.com/bots-garden/apprendre-rust-en-30-mins?tab=readme-ov-file#apprendre-rust-en-30-mins)
