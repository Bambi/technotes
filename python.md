# Python
## Data Types
### Strings
8-bit string and unicode strings are different types in Python.
Prefix string constants with `'u'` to have unicode strings: `u'string'`.
As an [alternative](http://sametmax.com/lencoding-en-python-une-bonne-fois-pour-toute/),
use unicode strings directly in your code: make sure that code source files are encoded
in utf-8 and add at the beginning of your files:
```python
# coding: utf-8
from __future__ import unicode_literals
```

### Lists
List of mutable homogeneous (usually) elements accessed by sequential iteration.
Elements can be duplicated in a list.

List are created by enumeration of its elements between []:
```python
l = [ 'val1', 'val2', 'valx' ]
```
Functions available on lists are:
`append, extend, insert, remove, pop, clear, index, count, sort, reverse, copy, del`.

Lists can be used for stacks (with append and pop) and queues (with `append`, `deque` and `popleft`).

Lists are used to make arrays. In a list (or array) elements are zero-indexed (index start at 0).
Individual elements are accessed using its index between `[]`.

To get all elements of a list with its index use the `enumerate()` function:
```python
for idx,val in enumerate(list):
	print (idx, val)
```

### Tuples
List of immutable heterogeneous elements accessed via unpacking or indexing (or by name for named tuples).

Tuples are created by enumerating its elements separated by commas (optionally between `()`):
```python
t = ( 'val1', val2, 3 ) or
t = 'val1', val2, 3
```

### Sets
Unordered collection with no duplicates. Used for membership testing and
eliminating duplicates and doing mathematical operations on sets.

Use `{}` or the `set()` function to create sets:
```python
s = { 'val1', 'val2', 'val3' }  or
s = set( 'val1', 'val2', 'val3' )
s = set() # creates an empty set
```

### Dictionaries
List of keys-values. Dictionaries are indexed by keys (any immutable type like strings or numbers).
Keys are unique.
```python
d = { 'k1': 'val1', 'k2': 'val2' }
```
Use `dict()` to build a dictionary from a sequence of key-value pairs:
```python
d = dict( [ ('key1', val1), ('key2', val2) ] )
```
To add or modify an entry:
```python
d[ 'key' ] = 'val'
```
To get an entry:
```python
d[ 'key' ]
```
with this notation you will receive an exception if the key does not exist.
With the following usage you will receive either the key value or a default value
(with no default value specified you will get `None` if the key does not exist):
```python
d.get( key, <default> )
```
To remove an entry:
```python
del d[ 'key' ]
```
To iterate over all keys and values:
```python
for key,val in released.items():
```
To delete an element use the `del()` method (gives `KeyError` if you try to
delete an unexisting element) or the `pop()` method.

To test the presence of a key use the `has_key()` method.

To merge 2 dictionaries use the `update()` method.

### Literals
- `[]` = empty list
- `()` = empty tuple
- `{}` = empty dict

There is no literal for empty set, use `set()`.

### Function Arguments
Function arguments can be Tuples or Dictionary:
- `*args` collect all unnamed arguments as a Tuple.
- `**args` collect all named arguments as a Dictionary.

### Function Call
With `*` it is possible to force unpacking of a tuple: it transform the tuple into
the list of unnamed parameters:
```python
f( *tuple )  =>  f( val1, val2 … )
```
With `**` it is possible to force unpacking of a dictionary: the dictionary is
transformed into a list of named parameters:
```python
f( *dict )  =>  f( key1=val1, key2 = val2 … )
```
Each key of the dictionary must match a name in the parameter list, the function
must be declared:
```python
def f( key1, key2 …)
```

### Global Variables
With Python variables are local, if not otherwise declared. All variables have
the scope of the block, where they are declared and defined in.
They can only be used after the point of their declaration.
This means that if you want to read a global variable you can just use it like a local variable.
But if you want to make an assignment to a global variable you must use the global keyword.
Otherwise the assignment will create a new local variable that will hide the global variable.

## Language
### Name spaces
A *name space* is mapping from name to object (or attributes).
Any attribute may be accessible from anywhere if prefixed by its name space: `namespace.attribute`.

A *scope* is a textual region where a name space is directly accessible (without a prefix).

During execution, there are at least three nested scopes whose name spaces are directly accessible:
* the innermost scope, which contains the local names (function or class)
* scopes of any enclosing functions which contains non-local, but also non-global names
* the current module’s global names
* the outermost scope (searched last) is the name space containing built-in names

If a name is declared global, then all references and assignments go directly
to the middle scope containing the module’s global names. Otherwise, all variables
found outside of the innermost scope are read-only (an attempt to write to such a
variable will simply create a _new_ local variable in the innermost scope,
leaving the identically named outer variable unchanged).

Outside functions, the local scope references the same name space as the global scope.

If no [global](https://docs.python.org/2/reference/simple_stmts.html#global)
statement is in effect – assignments to names always go into the innermost scope.
Assignments do not copy data — they just bind names to objects.
The same is true for deletions: the statement `del x` removes the binding of `x`
from the name space referenced by the local scope.

There are several reserved name spaces:

Namespace     | Usage
------------- | ------------------------------
`__builtin__` | module name for built-in names
`__main__`    | statements executed by the top-level invocation are considered part of this module
`__all__`     | list of public objects of a module. Affects the from <module> import * behavior only. Members that are not mentioned in `__all__` are still accessible from outside the module and can be imported with from <module> import <member>.

### Modules
A module is a text file containing python code. The text file must be named `<module>.py`.
The name of the module is stored in the `__main__` variable.
With the `import` statement all symbols defined inside a module will be created
inside a new name space with a name equal to the module name.
Theses symbols can are accessible with the `<module>.<symbol>` notation.

The `from <module> import <symbols>` statement import symbols from the module
directly inside the calling name space.

The import statement will first search for a module from the native modules
then it will search for a filename `<module>.py` from the `sys.path` variable.
This variable is set up from:
*   the current directory
*   the `PYTHONPATH` environment variable
*   defaults values from the python installation

A more generalized way to import a module is:
```
<module> = imp.load_source('<name>', '<path to filename>')
```

This allows to import a module with a filename with no `.py` extension or out of the `sys.path` variable.
You can also use `sys.dont_write_bytecode = True` to prevent `<filename>c` file creation (compiled module).

#### `__name__`
`__name__` is a special variable set by python for every script. Its value is either:

*   The name of the script.
*   The value `__main__` for the first loaded script (with `python <script>` or `python -m <script>`)..

#### Import
An import statement can be absolute or relative (python3 support only explicit relative imports):
```python
	from base import class	# <- absolute
	from .base import class	# <- explicit relative
```
Relative imports are based on the name of the current module (`__name__`).
As the main module name is always `__main__` explicit relative import is not
possible from the main module (and must always use absolute imports).

### Classes
#### Class Definition
```python
class ClassName:
	val1 = 'value'	# shared by all instances of class
	def fct(self):	# class method (bounded method)
		self.val2 = 5 # instance attribute
```
When executed it creates a name space and a class object.

#### Class Objects
Class objects support attribute references (MyClass.x) and instantiation.
Instantiation uses function notation to create a new instance of the class:
```python
x = MyClass()
```
Class objects may have special functions:

Function      | Usage
------------- | ------------------------------
`__init__()`  |  Called automatically by class instantiation to initialize the instance. May have parameters and must return nothing.
`__new__()`   | Called before object creation (before `__init__`). Must return an object, usually created with `super()`.
`__doc__`     | Attribute, contains the doc string of the class.
`__dict__`    | Attribute, list all functions and attributes of the class
`__getattr__` | Called when the default attribute access (through `__dict__`) fails
`__str__`     | function defined by user. Returns a string object and called by srt(). Build an informal string representation of an object.
`__call__(self)` | What to do when: <code>x=Class(); x()</code>. (Calling an instance).
`__getitem__(self, idx)` | What to do when: `x=Class(); x[idx]`. May raise `IndexError` exception.
`__iter__(self)` | What to do for things like `for …`
`__len__(self)` | What to do when `len()` is called.
`__repr__`    |

A method can be called after it is bounded: `python x.f()`

But a bounded method can also be stored: `python y = x.f`

and called later: `python y()`

#### Inheritance
A class may derive from one or multiple other classes:
```python
class MyClass(Base1, Base2)
	…
```

#### Methods
A method is a function in a class namespace. It takes a class instance as the
first parameter called `self` by convention.

All methods are `virtual`. There is no private method but by convention methods
those name start with _ should not be called from outside the class.

Methods can be of different types with function decorators:

Decorator                     | Usage
----------------------------- | ------
@classmethod                  | Can be called `Class.classmethod()` or `Class().classmethod()`.
def classMethod(cls, args...) | Take a class object as the first parameter instead of a class instance.
                              | Used for factory methods.
@staticmethod                 | Create a static method: does not take a class instance as the first parameter. Called `Class.method()`.

### Decorators
Functions in Python are objects and a variable can hold a function:
```python
def myfunction()
		Pass
myvar = myfunction
```

It is also possible to declare a function inside another function:
```python
def myfunction()
		def myotherfunction()
			pass
		myotherfunction()
```

`myotherfunction()` is reachable only inside `myfunction()` and cannot be called from the outside.

A decorator is a function which returns a hidden function (closure).
The purpose is to add code before and after the function call:
```python
def wrapper( func )
		def trt( )
			print("before")
			func()
			print("after")
		return trt
```
And use it with: `myfunction = wrapper(myfunction)`.
In this case `myfunction` attributes (`__doc__` for example) will be the `trt` attributes
which usually is not what we want. You can use the `@functools.wrap(func)`
before the `def trt()` which will copy attributes of the `func` function to the `trt` function.

With python syntax use:
```python
@wrapper
def myfunction()
```

If your decorator needs arguments you must implement another level of indirection:
you wrapper must create an other decorator wrapper and you wrapper must be called like a function (`@wrapper(arg)`).

### Map, filter, reduce (list functions)
`Map` takes a function and a list, tuple or iterable objects and call function for each elements.
It returns a iterator other the results which can be converted to a list with the `list()` function:
```python
def area(r):
		return math.pi * (r**2)
	rad = [ 5, 8, 2.5 ]
	res = list(map(area, rad))
```

The Filter function (`filter(funct, data)`) returns data for which the function is true:
```python
list(filter(lambda x: x > 0, data))
list(filter(None, data))` # removes empty (false) data (“”, 0, 0j, [], (), {}, False, None)
```
Reduce apply a function (f(x, y)) for each pair in data:
```
functool.reduce(f, data)
```

## Python 3
A new type is used from strings: `str`.

With python 3 all strings are unicode encoded. This means that a string of character
cannot be anymore considered as a string of bytes.

In order to represent a stream of bytes a new type was created: `bytes`, a stream of integers.

A bytes literal is created with `b'xxx'`.

To convert a bytes to a string: `var.encode()` (returns a `str` type)

To convert a string of characters to a byte string: `var.decode()` (returns an `bytes` type)

## Python Project Structure
Every Python code file (.py) is a module.

Organize your modules into packages. Each package must contain a special `__init__.py` file.

Modules should have short, all-lowercase names. Underscores can be used in the module name
if it improves readability. Python packages should also have short, all-lowercase names,
although the use of underscores is discouraged.
Remember that modules are named by filenames, and packages are named by their directory name.

Your project should generally consist of one top-level package, usually containing sub-packages.
That top-level package usually shares the name of your project,
and exists as a directory in the root of your project's repository.

Use absolute (prefered) or eventually relative imports to refer to other modules in your project.

Executable projects should have a `__main__.py` in the top-level package.
Then, you can directly execute that package with `python -m myproject`.

## Calling C Functions
```python
import ctypes
_libc = ctypes.cdll.LoadLibrary("libc.so.6")
result = _libc.umount(ctypes.c_char_p(target))
```

## Debugging
`python -m pdb script.py`

To display attributes of a object: `p obj.__dict__	OR  p vars(obj)`

To list names in a scope: `dir(obj)`

To get the type (or class) of a variable: `type(var)`

### Commands
Command         | Usage
--------------- | ------
b(reak)         | list breakpoints
b(reak) <breakpoint> | add a new breakpoint
c(ontinue)      | continue execution
n(ext)          | continue execution until next line
s(tep)          | continue execution and stop ASAP
r(eturn)        | continue execution until current function returns
j(ump           | set next line to be executed
cl(ear) <bp list> | delete breakpoint
a(rgs)          | print arguments of current function
l(ist)          | print source code around line
pp              | pretty print value or expression

It is possible to integrate a breakpoint inside the code:
```python
import pdb
pdb.set_trace()
```

The `.pdbrc` file contains commands that are executed when a debugger session is started.

## Remarks
`Do .. while` does not exist in Python. Use a `While True: <body> if <test>: break;` instead.

To make logging write on stdout, add a streamHandler to the root logger:
```python
root = logging.getLogger()
root.setLevel(logging.DEBUG)
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
root.addHandler(handler)
```

[Writing portable python ⅔ code](https://python-future.org/compatible_idioms.html).

## References
[Python tips](http://book.pythontips.com/en/latest/index.html): many tips on python development.
[Built-in functions list](https://docs.python.org/2/library/functions.html).
[Native types](https://docs.python.org/fr/2/library/stdtypes.html).
[Output formatting](https://pyformat.info/).
