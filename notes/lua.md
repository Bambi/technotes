# Lua

## Language Basics
Comments begins with `-- `. Constant are named in CAPITAL. Ignored variable names generally
start with `_`. A statement can optionally end with a `;`.

### Types
* `nil`: different from every other value.
* `boolean`: can be `true` or `false`. `nil` and `false` are false, all other value are true.
* `number`: real floating-point number.
* `string`: table of characters.
* `function`: Callable Lua or C code.
* `userdata`: a block of memory to store arbitrary C data.
* `thread`: thread of execution for coroutines.
* `table`: associative tables. Index can be any value except nil.
  Value are heterogeneous except for the value nil. `table["key"]` and `table.key` are the same.
  Table are created with `{}`.

### Variables
Variables can be global or local. Local variables are declared with the keyword `local`.
All non local variables are considered global and not need to be declared.

Variables only hold references to values. The function `type(val)` return a string
describing the type of a value.

### Length Operator
Unary `#` operator. For a string return the number of bytes. For a table gives the number of keys.

### Concatenation
String concatenation is done with `..` (ex: `str1..str2`).
Numbers are automatically converted to strings.

### Tables
Tables can be used as array:
```lua
t = {5, 1, 10}
print(t[1])
> 5
print(t[2])
> 1
print(#t)
> 3
```
First index is always 1. `t[0]` is always `nil`. You can add an element at the end
of a table with `table.insert(tbl, val)`: it will use the last index + 1.

Indexes may not be in order. In this case the table is no longer an array
and the length operator result is undefined.

Tables can also be used as dictionaries:
```lua
t = { apple="green", orange="orange", banana="yellow" }
```
The key can be any type but if the key is a string then theses 2 syntax are identical:
```lua
tbl["key"] = val
tbl.key = val
```

It is possible to mix an array and a dictionary in the same table:
```lua
t = {2,4, language="Lua", version="5"}
for k,v in pairs(t) do print(k,v) end
> 1	2
> 2	4
> version	5
> language	Lua
```

Remark: array table are in fact dictionary table with a sequenced number as the key
plus a `n` key with the number of elements.
The function `table.pack()` create an array with a list of values:
```lua
t=table.pack(1, 5, 2)
for k,v in pairs(t) do print(k,v) end
> 1	1
> 2	5
> 3	2
> n	3
```

### MetaTables
A meta table is a dictionary with specific values for key and functions (metamethods) for values.
A meta table can be associated with a table with the function `setmetatable(tbl, metatbl)`.
This will allow to define specific operations on tables, for example the `add` operation:
```lua
t1 = {25}
t2 = {18}
mt = {}    -- metatable.
-- Add operation.
mt.__add = function(a, b)
  return{valeur = a[1] + b[1]}
end
setmetatable(t1, mt)    -- Associate mt with t1
print(unpack(t1 + t2))
---> 43
```

### Functions
Functions are declared with:
```lua
function my_function(arg1, arg2, ...)
	-- body of the function
end
```
and called with: `my_function(p1, p2, p3, p4)`. `...` express a variable number of arguments.

Function parameters are local variables.
A function can be assigned to a variable or returned by another function.
A function can return multiple values (with the `return` keyword).

The unpack function takes a table and return all its elements as a list.
t can be used to call a function with its parameters stored in a table:
```lua
fct(unpack(m_table))
```

### Environment Table
All global variables are stored in a special table called `_G`.
Global variables can thus be accessed with `val = _G["varname"]`.
A metatable can be associated with the global table so it is possible for example
to modify the default behavior that it is not necessary to declare a global variable.

### Modules
Module is like a library that can be loaded using `require` and has a single global
name containing a table:
```lua
local mymath =  {}
function mymath.add(a,b)
   print(a+b)
end
return mymath
```
And used with:
```lua
mymathmodule = require("mymath")
mymathmodule.add(10,20)
```
The modules and the file you run should in the same directory. Module name and its file name should be the same.

### Objects
Lua has no fist-class notion of objects. But OOP can be done with tables and metatables:
```lua
-- Meta class
Rectangle = {area = 0, length = 0, breadth = 0}
-- Derived class method new
function Rectangle:new (o,length,breadth)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.length = length or 0
   self.breadth = breadth or 0
   self.area = length*breadth;
   return o
end
-- Derived class method printArea
function Rectangle:printArea ()
   print("The area of Rectangle is ",self.area)
end
-- creating an object
r = Rectangle:new(nil,10,20)
-- accessing properties
print(r.length)
-- accessing member function
r:printArea()
```
Here we use the `:` syntax which is a syntactic sugar:
```lua
function t:f (params) body end -- is equal to:
t.f = function (self, params) body end
```

## References
- [Lua Tutorial](https://www.tutorialspoint.com/lua/index.htm)
