Lambdapi user manual
====================

This document explains several of the concepts behing `lambdapi` and serves as
a user documentation. Installation instructions can be found in the repository
(see [README.md](README.md)). Here is a rough summary:
```bash
git clone https://github.com/rlepigre/lambdapi.git
cd lambadpi
make && make install
```

What is Lambdapi?
-----------------

The `lambdapi` system is several things!

### A logical framework

The core (theoretical) system of `lambdpi` is a logical framework based on the
λΠ-calculus modulo rewriting. In other words, it is dependent type theory that
is somewhat similar to Martin-Lőf's dependent type theory  (i.e., an extension
of the λ-calculus) but that has the peculiarity of allowing the user to define
function symbols with associated rewriting rules. Although the system seems to
be very simple at first, it is surprisingly powerful. In particular, it allows
the encoding of the theories behind Coq or HOL.

### A tool for interoperability of proof systems

The ability to encode several rather different systems make of `lambdapi` (and
its predecessor `Dedukti`) an ideal target for proof interoperability. Indeed,
one can for example export a proof written in Matita (an implementation of the
calculus of inductive constructions) to the OpenTheory format (shared  between 
several implementation of HOL).

### An interactive proof system

Being aimed at interoperability, `Dedukti` was never intended to become a tool
for writing proofs directly. On the contrary, `lambdapi` is aimed at providing
an interactive proof mechanism, while remaining compatible with `Dedukti` (and
its interoperability capabilities).

Here is a list of new features brought by `lambdapi`:
 - a new syntax suitable for proof developments (including tactics),
 - support for unicode (UTF-8) and (user-defined) infix operators,
 - automatic resolution of dependencies,
 - a simpler, more reliable and fully documented implementation,
 - more reliable operations on binders tanks to the Bindlib library,
 - a general notion of metavariables, useful for implicit arguments.

### An experimental proof system

Finally,  let us note that `lambdapi` is to be considere (at least for now) as
an experimental proof system based on the λΠ-calculus modulo rewriting.  It is
aimed at exploring (and experimenting with)  the many possibilities offered by
rewriting, and the associated notion of conversion. In particular, it leads to
simple proofs, where many details are delegated to the conversion rule.

Although the language may resemble Coq at a surface level, it is fundamentally
different in the way mathematics can be encoded. It is yet unclear whether the
power of rewriting will be a significant advantage of `lambdapi` over  systems
like Coq. That is something that we would like to clarify (in the near future)
thanks to `lambdapi`.

Command line flags and tools
----------------------------

The installation of `lambdapi` give you:
 - a main executable named `lambdapi` in your `PATH`,
 - an OCaml library called `lambdapi`,
 - an LSP-compatible server called `lp-lsp` in your `PATH`,
 - a `lambdapi` mode for `Vim` (optinal),
 - a `lambdapi` mode for `emacs` (optinal).

### Main Lambdapi program

The `lambdapi` executable is the main program. It can be used to process files
written in the `lambdapi` syntax (with the ".lp" extension), and files written
in the legacy (Dedukti) syntax (with the ".dk" extension).

Several files can be given as command-line arguments, and they are all handled
independently (in the order they are given). Note that the program immediately
stops on the first failure, without going to the next file (if any).

**Important note:** the paths given on the command-line for input files should
be relative to the current directory. Moreover, they should not start with the
`./` current directory marker, and they should not contains `..`.  This is due
to the fact that the directory structure is significant  (more details on that
will be given later).

Command line flags can be used to control the behaviour of `lambdapi`. You can
used `lambdapi --help` to get a short description of the available flags.  The
available options are described in details below.

#### Mode selection

The `lambdapi` program may run in three different modes. The standard mode (it
is selected by default) parses, type-checks and handles the given files. Other
modes are selected with one of the following flags:
 - `--justparse` enables the parsing mode: the files are parsed and `lambdapi`
   only fails in case of parse error (variable scopes are not checked). In any
   case, the compilation of dependencies may be triggered in order to retrieve
   user-defined notations.
 - `--beautify` enables the pretty-printing mode: the files are printed to the
   standard output in `lambdapi` syntax.  This mode can be used for converting
   legacy syntax files (with the ".dk" extension) to the standard syntax. Note
   that, as for the parsing mode (`--justparse` flag),  the compilation of the
   dependencies of the input files may be triggered.

Note that when several mode selection flags are given,  only the latest one is
taken into account. Moreover, other command-line flags are ignored (except the
`--help` and `-help` flags).

#### Default mode flags

When in default mode, the following flags are available for configuration:
 - `--gen-obj` instructs `lambdapi` to generate object files for every checked
   module (including dependencies). Object files have the ".lpo" extension and
   they are automatically read back when necessary if they exist and are up to
   date (they are regenerated otherwise).
 - `--verbose <int>` sets the verbosity level to the given natural number (the
   default value is 1). A value of 0 should not print anything, and the higher
   values (up to 3) print more and more information.

#### Confluence checking

Confluence checking (and also termination) must be established for each of the
considered rewriting systems contained in `lambdapi` files. By default,  these
checks are not performed, and they must be explicitly requested.

We provide an interface to external confluence checkers using the TPDB format.
The `--confluence <cmd>` flag specifies the confluence-checking command to  be
used. The command is expected to behave as follows:
 - take the problem description (in `.trs` format) on its standard input,
 - output on its first line either `YES`, `NO` or `MAYBE`.

As an example,  `echo MAYBE` is the simplest possible (valid) confluence-check
that one may use.

For now, only the `CSI^ho` confluence checker has been tested with `lambdapi`.
It can be called in the following way.
```bash
lambdapi --confluence "path/to/csiho.sh --ext trs --stdin" input_file.lp
```

To generate the `.trs` file corresponding to some `lambdapi` file, one may use
a dummy confluence-checking command as follows.
```bash
lambdapi --confluence "cat > output.trs; echo MAYBE" input_file.lp
```

#### Termination checking

For now, there is not support for termination checking.

#### Debugging flags

The following flags may be useful for debugging:
 - `--debug <str>` enables the debugging modes specified by every character of
   the string `<str>`. Details on available character flags are obtained using
   the `--help` flag.
 - `--timeout <int>` gives up type-checking after the given number of seconds.
   Note that the timeout is reset between each files.  The given parameter is
   expected to be a natural number.
 - `--toolong <flt>` gives a warning for each command (i.e., file item) taking
   more than the given number of seconds to be checked. The given parameter is
   expected to be a floating point number.

Finally, remember that `--help` or `-help` gives you a list of available flags
with a minimal documentation.

### Lambdapi OCaml library

The `lambdapi` OCaml library gives access to the core data structures that are
used by `lambdapi`. It can be used to experiment with the type-checker and the
rewriting engine of `lambdapi`, but also to propose new (compatible) tools. It
is currently used by the implementation of the LSP server (next section).

### Lambdapi LSP server

The `lambdapi` LSP server, called `lp-lsp`, implements an interface to editors
supporting the LSP standard. Limitations in the LSP protocol may require us to
consider a non-standard extension for the proof mode. For now,  we support the
`emacs` editor through the `eglot` plugin for interactive proof,  and also the
`Atom` editor with a custom plugin.

See the file [lp-lsp/README.md](lp-lsp/README.md) for more details.

### Emacs mode

The `emacs` mode can optionally (and automatically) installed with the command
`make install_emacs` in the `lambdapi` repository.  Support for the LSP server
is enabled by default, and requires the `eglot` plugin.

See the file [lp-lsp/README.md](lp-lsp/README.md) for more details.

### Vim mode

The `Vim` mode can optionally (and automatically) installed using the  command
`make install_vim` in the `lambdapi` repository. It does not yet have built-in
support for the LSP server.

### Atom mode

Support for the `Atom` editor exists,  but is deprecated since the editor will
most certainly disappear in the near future (in favor of `VS Code`).

See [atom-dedukti](https://github.com/Deducteam/atom-dedukti) for instructions
related to the `Atom` editor.

Compilation and module system
-----------------------------

<!-- TODO -->

Syntax of Lambdapi
------------------

<!-- TODO -->

Interactive proof system
------------------------

<!-- TODO -->

Compatibility with Dedukti
--------------------------

<!-- TODO -->