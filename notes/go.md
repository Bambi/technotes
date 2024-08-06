# Go Language
## Intro
The `GOPATH` environment should point to a directory where go is installed.

## Code Organization
Go programs are organized into _packages_. A package is a collection of
source files in the same directory that are compiled together.
On distingue plusieurs types de packages:
- packages exe: génèrent un éxécutable, il doit y avoir une fonction `main()`
- packages utilitaires: génèrent une librairie
Les packages sont stockés dans `$GOROOT/src` ou `$GOPATH/src`.

A repository contains one or more _modules_. A module is a collection of
related Go packages that are released together with their dependencies.
A Go repository typically contains only one module, located at the root of
the repository with filea named `go.mod` and `go.sum`.

An _import path_ is a string used to import a package. A package's import path
is its module path joined with its subdirectory within the module.
Import path should be in lower case (no CamelCase or snakeCase) and look like
`org/module/pkg`.

Principaux modules:
- `fmt`: fournit des fonctions de mise en forme des E/S, ex: `Print`, `Println`, `Printf`
- `io`: fournit des fonctions d'E/S: `ReadFull`, `Seek`, `WriteString`
- `math`: fonctions mathématiques: `Min`, `Max`, `Sqrt`, `Log`
- `os`: interface avec l'OS: `OpenFile`, `ReadAt`
- `strings`: fonctions de traitement des chaînes de caractères
- `time`: outils de mesure des temps d'exécution: `Now`, `Since`

## Main Commands
- `go build <path>`: compile
- `go install <path>`: (eventually) build and install package in `GOPATH/bin`
- `go env <variable>`: set or unset environment for future go commands
- `go env`: list environment
- `go mod init <path>`: init workspace for a new module (generates `go.mod`)
- `go run main.go`: exécute un programme

## Variables
Déclaration de variables:
```go
var <nom> <type> [= <init>] // forme générale
var <nom> = <init> // type induit
<nom> := <init> // uniquement dans une fonction
```
Les identifiants en Go:
- sont une séquence de lettres et de chiffres
- dont le premier caractère est une lettre ou `_`
- les caractères de ponctuation tels que `@, $, %, :` ne sont pas autorisés
- sont sensibles à la case

Nom des variables/fonctions/structures:
- minuscule, pour les données privées (dans un package)
- Majuscule, pour les données publiques
- `const Pi = 3.14`, constantes, pas de `:=` avec les constantes

Mots clé (non utilisable pour de identifiants):
- `break, default, func, interface, select, case, defer, go, map, struct, chan`
  `if, else, goto, package, switch, const, fallthrough, range, type, continue`
  `for, import, return, var`

Type de données:
- `int`, `uint`, `int8`, `uint8`, `uint16`, `uint32`, `uint64`: entiers
- `float32`, `float64`: flottants
- `string`: chaîne de caractères immuables, `len()` pour avoir sa longueur
- pointeurs: utiliser `*` pour déclarer et `&` pour déréférencer un pointeur

Fonctions:
```
func <nom> (<var param lst>) (<var result lst) {}
```

## Généralités sur le langage Go
### Conditions
```
if <cond> { code } [else { code }] [else if <cond> { code }]
cond: == != < > <= >= && || !
```
- `fmt.println()`: affiche une ligne
- `fmt.printf()`: affichage formatté

On met généralement une instruction par ligne sans `;` à la fin. Si on veut
plusieurs instructions il faut utiliser le `;`: `if count := 10; count > 10 {}`.
```go
switch <var> {
  case <val1>:
    ...
  case <val2>:
    ...
  case <val3>, <val4>:
    ...
  default:
    ...
}
```
Switch sans variable possible (équivalent à if-else):
```go
switch {
  case <test>:
}
```
Les conversions de type doivent être *explicites*: `<var> = type(<val>)`,
sauf int -> float.

Retour de fonction: utiliser `_` pour ignorer une valeur.
Imports/Variables: on ne peut pas les déclarer sans les utiliser.

### Tableaux
Taille fixe à la création. Index de départ: 0.
```
var <nom> [<taille>] <type>
```
Taille d'un tableau: `len (<tableau>)`.
Il est possible d'afficher un tableau directement avec `printf()`.
Déclaration et initialisation directe:
```go
odds := [4]int {1, 2, 3, 4}
```

### Slices
Tableaux de taille dynamique.
```
<var> := make([]<type>, <taille>, <capacité>)
  Taille: nb elements = len(<var>)
  Capacité: taille max = cap(<var>)
Déclaration et init:
  slc := []<type> {<val1>,<val2>,...}
```
Il est possible de faire des slices de slices:
```
sub := letters[0:2]  <- slice de 2 éléments
  0: inclusif
  2: exclusif
```
Les slices de slices _partagent les éléments_.
On peut copier les slices avec `copy(<dest>, <src>)`.

### Boucles For
```
for <init> ; <cond> ; <action fin boucle> { <code> }
for <cond> { <code> }  => while
for { <code> }  => for ever ; utiliser continue / break
Range: itération sur une liste:
  for <idx>,<value> := range <data> { <code> }
  data: tableau ou slice ou string
```
Go ne possède pas de boucle `while`.

### Main
Un exécutable doit avoir une fonction `main()` du package `main`.
Un programme Go minimal:
```go
package main
func main() {
}
```

## Gestion d'erreurs
Code retour ajouté aux retours de fonction:
```go
v, err = func()
if err != nil { <code erreur> }
```
`err` est une chaine de caractères: `return errors.New("erreur")`.
> privilégier le pattern _early return_.

`defer <inst>`: appel de `inst` à la suite de la fonction courante. Maintient
une liste LIFO d'instructions (il peut y avoir plusieurs defer).

## Modules
Pour gérer les dépendances d'un projet:
- évolution des dépendences: pouvoir utiliser une version spécifique
- conflit des dépendences: pouvoir utiliser plusieurs versions d'une dépendence

Init d'un projet: `go mod init <org>/<projet>` -> crée un fichier `go.mod`
Ajout d'une dépendence:
- importer le module dans les sources
- `go get`: télécharge les dépendences et les enregistres dans `go.mod`.
  `go.sum` liste les dépendences directes et transitives ainsi que les
  signatures des modules.

- Maj d'une dépendence vers la dernière version: `go get <dep>`
- Lister les dépendences: `go list -u -m all`
- Supprimer une dépendence: supprimer import dans code + `go mod tidy`

## Structures
```
type <nom> struct {
  var ...
} 
```
- ne peut contenir que des variables (pas de fonction)
- les règles de visibilité (Majuscule/minuscule) s'appliquent sur le nom des
  structures et sur les variables.
- `fmt.Printf("%v")` permet d'afficher une structure complète.
Init d'une structure:
- `x := <type> {<val1>,<val2> ...}` <- tous les champs doivent être présents
- `x := <type> {<var1>:<val1>, ...}` <- juste les champs que l'on désire
- avec une fonction: `x := <type>.new(<param> ...)`
  `func New (<param> ...) <type> { }`

Structures imbriquées:
```go
type Addr struct { City string }
type User struct {
  Name string
  Addr  // pas de nom de variable!
}
// on peut faire: var.City = "..."
// init:
x := User {
  Name: "val"
  Addr: Addr {
    City: "val",
  },
}
```

## Dates
Utilier le package `time` qui fournit:
- `Now()`: retourne la date/heure courrante
- `Date()`: crée une date à partir des spécifications données en paramètre
- `Sub()`: durée entre deux dates
- `Add()`: ajout de durée
- `Year()`, `Month()`, `Day()`, `Hour()`: accéder aux différents éléments d'une date

## Méthodes (receivers)
Permet de lier des données (structure) avec des fonctions (-> objet).
```
type <type> struct { <nom> <type>, ... }
func (x <type>) <fct>() { ... x.<champ> ... }
         ^-- receiver (instance d'une structure)
```
Appel: `x := <type>; x.<func>()` <- value receiver
  `x` est passé en _copie_ à la fonction
  pas de modification de la structure originale

Example: convertion d'une structure en chaine:
```go
func (x <type>) String() string {
  return fmt.Sprintf("...", ...)
}
```
Cette fonction est appellée automatiquement pour `Printf("%v", x)`

## Pointeurs
Pas de désallocation (ramasse miette).
- Déclaration: `p := &x` ou `var p *<type>`
- Déréférencement: `val := *p`
- Pointer receiver (méthode, passage par référence): `func (u *<type>) <fct> { }`

## Dictionaires (maps)
```
var <nom> map[<type clé>]<type valeur>
<var> = make(map[<type>]<type>)
```
- type de clé: tout type comparable (sauf `slice`, `map`, `fct`)
- assigner une valeur: `m[<clé>] = val`
- test présence d'une clé: `val,ok := m[<clé>]`
  `if _,ok := m[<clé>]; ok { }`
- supprimer une clé: `delete(m, <clé>)`
- parcours: `for cle,val := range <map> { }`
  ou `for cle := range <map> { }`

## Interfaces (polymorphisme)
Regroupement nommé de signatures de fonctions.
```go
type MyInterface interface {
  // signatures des fonctions
  Foo() error
  Bar() string
}
```
Pour implementer une interface il faut redéfinir _toutes_ ses fonctions:
```go
type MyStruct struct {}
func (m MyStruct) Foo() error { ... }
func (m MyStruct) Bar() string { ... }
```
Go déduit automatiquement que `MyStruct` est du type `MyInterface`.
On peut faire: `var x MyInterface = &MyStruct {}` (_duck typing_).

Une interface est toujours un pointeur.
Une interface ne contient jamais de variable.

> _Convention_: une interface avec une fonction porte un nom terminé par `er`

Composition d'interfaces:
```go
type Saver interface() { ... }
type Loader interface() { ... }
type SaverLoader interface {
  Saver
  Loader
}
```
### Type assertion
Permet de tester dynamiquement le type d'une variable: `t, k = <var>(Type)`.
`t`: référence de type `Type` si convertion OK
`k`: booléen indiquant si convertion OK
Méthode alternative:
```go
switch v := a.(type) {
  case Type1: ...
  case Type2: ...
}
```
### Interface générique
Empty interface: `interface {}` -> type générique, peut contenir tous les types
(idem `void`):
```go
var x interface {}
x = 2
x = "hello"
```
Voir `io.Reader / io.Writer`.

## Divers langage
Chaîne de caractères sur plusieurs lignes: `\`...\``.
Commentaires fonctions:
```go
// <nom fct> <commentaires sur plusieurs lignes>
func fct
```
`printf("%T")`: affiche le type d'une variable.

### Constantes
Valeur définie à la compilation: `const <nom var> = <val>`.
Que pour les types de base.

### Logging
```go
import "log"
log.Println("...")
log.Fatal()
log.SetOutput()
```

### Fonction literals
Fonction anonyme. Peuvent être assignées à des variables ou appelées directement:
```go
f := func(x, y int) int { return x + y }
func(ch chan int) { ch <- ACK }(replyChan)
```
Fonction générateur (renvoi une fonction): `func Gen() func() {}`.

### Structures anonymes
Très utiles pour les tests:
```go
s := struct {
  name: string
}{
  "bob"
}
```

## Tests unitaires
Pour chaque `src.go` créer un fichier `src_test.go`:
```go
package xxx
import "testing"
func TestXxx(t *testing.T) {
  <check>
  if err t.Errorf("__", ...) // ou
  if err t.Failure()
}
```
`go test` dans un projet execute tous les tests existants.

### Table Driver Test
```go
func TestX(t *testing.T) {
  var tests = []struct {
    in int
    out int
  } {
    {1, 2},
    {2, 3}
  }
  for _, tt := range tests {
    v := tstFun(tt.in)
    if v != tt.out { ... }
  }
}
```

### Benchmark
```go
func BenchmarkX(b *Testing.B) {
  for i := 0; i < b.N; i++ { // b.N est fourni par Go
    ...
  }
}
```
Pour exécuter: `go test -bench=.`.

## Go Routines
Lightweight threads. Les threads Go sont différents des threads OS.
Les Go routines:
- démarrent plus rapidement
- on peut en créer des milliers

Lancement d'une fonction dans un thread Go spécifique: `go fct()`.

Les `channels` sont des tuyaux de communication entre Go routines. Les channels
sont toujours synchrones (bloquants). Construction:
```go
c := make(chan <type>)
// envoi d'une valeur dans le tube
c <- val
// lecture d'une valeur dans le tube
var := <- c
```
Go est capable de détecter les deadlocks (quand les go-routines sont bloquées).

### Channels unidirectionnels
```go
send := make(chan <- int)
recv := make(<- chan int)
// fermeture d'un channel
close(c)
// la fonction range c retourne vrai tant que le channel reste ouvert, ex:
for v := range c { ... }
```

### Buffered Channels
Équivalent d'une queue FIFO: on peut y insérer n éléments avant que la queue ne
soit pleine (nécessite de retirer des éléments):
```go
v := make(chan int, 2) // 2: capacité du channel (taille)
```
- l'emetteur bloque quand le channel est plein.
- le récepteur bloque quand le channel est vide.
- la capacité d'une channel est fixe.
- l'émetteur a généralement la responsabilité de fermer le channel.

### Sélection
Il est possible de lire sur plusieurs channels en même temps:
```go
c1 := make(chan int)
c2 := make(chan int)
select {
  case v := <- c1: ...
  case v := <- c2: ...
  default: ... // appelé qund il n'y a rien à lire sur les autres cases
}
```

## Miscelaneous
### Erreur custom
Il faut implémenter l'interface `Error`.
```go
type MyError {
  module string
  err error
}
func (e *MyError) Error() string { ... }
// Utilisation:
func process() error {
  return &MyError { module:"main", err:...}
}
```

### Package Alias
```go
import (
  t "test/template"
  h "html/template"
)
// t & h sont des alias
func main() {
  t.New(...)
  h.New(...)
}
```

### Custom Type Alias
```go
type Direction int // Direction est un alias de type
const NORTH Direction = 1
// alias de type + const => enum
type ErrorCode int
const (
  ERR_OK ErrorCode = iota // 0 au début
  ERR_NOK // (= iota) <- implicite par la suite ; +1
)
```
On peut faire des fonctions receivers sur notre alias de type:
```go
func (ec ErrorCode) IsCritical() bool {
  return rc == ...
}
// utilisation:
err ErrorCode
err.IsCritical()
func (ec ErrorCode) String() string {
  return [...] string {
    "ok",
    "nok"
  }[ec]
}
```

### Cross Compilation
Set environment variables for your target:
- GOOS: linux|darwin|windows
- GOARCH: 386|arm|amd64
- GOARM: 7 (only for arm)

ex: `env GOOS=linux GOARCH=arm GOARM=7 go build`

## References
- [Cross Compiling](http://golangcookbook.com/chapters/running/cross-compiling/)
- [How to Write Go Code](https://go.dev/doc/code)
