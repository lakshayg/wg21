// Document formatting rules
#let font-serif = "New Computer Modern"
#let font-sans  = "Helvetica"
#let font-mono  = "Monaco"

#set heading(numbering: none)
#show heading: set block(below: 1.2em)

#set text(size: 10pt, font: font-serif, hyphenate: false)
#set par(justify: true)
#set page("us-letter", margin: 0.75in)

#set raw(lang: "txt")
#show raw: set text(font: font-mono)

#show link: set text(fill: rgb("#0000EE"))
#show link: underline

#set quote(block: true)
#show quote: set pad(x: 2em)
#show quote: set block(above: 1em)

// prevent linebreak in the middle of grammar terms
#show emph: it => box(it)

#set highlight(top-edge: 8.5pt, bottom-edge: -2pt)
#set underline(stroke: (paint: black, thickness: 0.5pt), offset: 1.5pt)
#set strike(stroke: (paint: black, thickness: 0.5pt), offset: -2.5pt)

#set list(marker: [--])

// Custom styles
#let tab = h(2em)
#let ins(body) = highlight(fill: rgb("#90EE90"), underline(body))
#let del(body) = highlight(fill: rgb("#FFC0CB"), strike(body))
#let replace(before, after) = del(before) + ins(after)
#let nobreak(body) = block(breakable: false, body)
#let grammar(body) = text(font: font-sans, size: 9.5pt, weight: "light", style: "italic", body)

// Document
#title[P2034: Partially Mutable Lambda Captures]
#table(
    columns: (6em, 1fr),
    inset: (left: 0em, top: 0.2em),
    stroke: none,
    "Document", "P2034R6",
    "Authors",  [Ryan McDougall ```txt <mcdougall.ryan@gmail.com>```],
    "",         [Lakshay Garg ```txt <lakshayg.xyz@gmail.com>```],
    "Audience", "EWG",
    "Project",  [ISO/IEC JTC1/SC22/WG21 14882: Programming Language -- C++],
)

#outline(depth: 2)
#pagebreak()

// Table header highlight
#set table(fill: (x, y) => if y == 0 { gray.lighten(40%) })

= Revision History

=== Changes from R5: #link("https://wiki.isocpp.org/2025-11_Kona:EWGP2034Notes")[EWG Discussion]

- Incorporate extensions into the main proposal.
- Add discussion of capture defaults to the proposal.
- Rearranged some sections and updated links.
- Add wording for:
  - mutable captures
  - const-ref captures
  - const-ref capture-default
  - const specifier

=== Changes from R4: #link("https://wiki.isocpp.org/2025-06_Sofia:NotesEWGP2034")[EWG Discussion]

- Implementation experience.

=== Changes from R3: #link("https://wiki.isocpp.org/2024-03_Tokyo:NotesEWGIP2034R2")[EWG-I Discussion]

- Meta-motivation: safety and security -- const should be easier to get right
  and harder to get wrong.
- Cleaned up some examples.

=== Changes from R2

- Update author email addresses.
- Rename `any_invocable` to `move_only_function`.

=== Changes from R1

- Add discussion of const captures on move construction and assignment.
- Add vocabulary type `as_mutable`.
- Add alternative implementation strategy for const members.
- Selective move feature in top section.

=== Changes from R0: #link("https://wiki.isocpp.org/2020-02_Prague:P2034R0SG17")[Concerns from EWG-I]

- Interactions with `this` pointer.
- Interactions with init-capture packs.
- Clarify const as it applies to pointers.
- Add const-reference use case.
- Expanded prose.

#pagebreak()

= Polls

== 2025-11 Kona, R5

#nobreak[

We \[EWG\] encourage further work on this paper towards C++29.

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [21],[27],[5],[0],[0],
)

*Strong Consensus*
]

== 2025-06 Sofia, R4

#nobreak[
EWG encourages more work in the direction of Partially Mutable Lambda Captures.

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [1],[10],[4],[2],[1],
)

*Consensus*
]

#nobreak[
EWG encourages more work in the direction of Partially Mutable Lambda Captures,
including extensions.

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [2],[15],[3],[1],[0],
)

*Stronger consensus*
]

== 2024-03 Tokyo, R2

#nobreak[
EWGI believes P2034R3 should include a `const` qualifier for lambda captures.

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [2],[4],[4],[1],[0],
)

*Barely consensus*

Comment: motivation could be better.
]

#nobreak[
EWGI believes P2034R3 is sufficiently well developed, EWGI forwards it to EWG.

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [3],[7],[0],[0],[0],
)

*Consenus*
]

#pagebreak()

= Background

Lambdas were introduced in
#link("http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2008/n2550.pdf")[
N2550], and while
#link("http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2008/n2529.pdf")[
previous] drafts considered mutable capture by value, the original wording
left captures entirely const.
#link("http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2008/n2658.pdf")[
N2658] salvaged mutable for _all_ captures by allowing the `mutable` keyword
to modify the call.

#link("https://wg21.link/P0288")[P0288] (`move_only_function`) was approved by
LEWG, and a central improvement is that it respects the const modifier on
function types (ie. `move_only_function<void(int) const>`). This means a
`move_only_function` with a const modifier on its call type will only bind to
lambdas that are not marked `mutable`.

A type that is
#link("https://isocpp.org/wiki/faq/const-correctness#mutable-data-members")[
"logically const"] is a type that has some mutable members that do not
fundamentally change the invariants of the object, even when it is const. This
means `move_only_function`, and _any_ other const-correct library, _cannot_ work
with logically const lambdas.

= Meta-Motivation

The proposal and most extensions would allow programmers to *apply `const` with
simplicity and precision* to lambda captures -- improving applicability of const
in cases where programmers would otherwise:

1. Declare the lambda blanket mutable.
2. Declare captures by const {non-}propagating wrapper.

Applying `const` with more purpose and simpler syntax would improve the safety
and security of such code -- especially for programmers that have learned about
the `const` declarations, but are not yet comfortable with
`const`-{non-}propagating wrappers. Avoiding use of wrappers also makes lambda
captures smaller and thus easier to read and reason about.

= Motivation

Type erased callables like `std::move_only_function` are the backbone of most
asynchronous systems. Users of such systems close their operations in lambdas
and place them in a concurrent queue to be processed elsewhere. Performance is
often key in such systems, and such operations may want its own local reusable
scratch memory. Or perhaps an accumulator for hysteresis over multiple calls.

#nobreak[
```cpp
struct MyRealtimeHandler {
  Callback callback_;
  State state_;
  mutable Buffer accumulator_;

  void operator()(Timestamp t) const {
    callback_(state_, accumulator_, t);
  }
};

concurrent::queue<move_only_function<void(Timestamp) const> queue;
queue.push(MyRealtimeHandler{f, s});
```
]

Lambdas in such cases require work-arounds, such as abandoning logical const
correctness, abandoning ownership, or introducing intermediary
{non-}const-propagating intermediary types. Strict ownership rules are important
due the asynchronous nature of the handler, and const correctness is important
for memory- and thread-safety

= Proposal

We propose a number of enhancements to the lambda syntax that simplify creating
const-correct lambdas. In addition to const-correctness, these features improve
the consistency and symmetry -- which the authors believe is a justification in
its own right.

The proposed enhancements are summarized below in the order of their perceived
usefulness followed by a more detailed explanation for each of these items.

1. Mutable capture on const call operator
2. Const capture on mutable call operator
3. Const capture by reference
4. Const default capture
5. Const default capture by reference
6. Explicitly const call operator
7. Const capture on const call operator
8. Mutable capture on mutable call operator

== Feature 1: Mutable Capture on Const Call Operator

Allow
#link("https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2013/n3610.html")[
lambda capture initialization] to be mutable qualified, as below. This
would have the effect of declaring the captured variable to be mutable.

```cpp
auto a = [mutable x, y]() {};

// equivalent to

struct A {
  mutable X x;
  Y y;
  void operator()() const {}
};
```

#table(
  columns: (1fr, 1fr),
  align: bottom,
  [Before], [After],
  [
```cpp
struct A {
  const State state;
  mutable Buffer buf;
  void operator()() const {
    // ...
  }
};

// manual bespoke type
move_only_function<void() const> f = A{s, b};
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, mutable b] {
    // ...
  };
```
  ],nobreak[
```cpp
template <typename T>
class as_owned_mutable {
  mutable T value;
 public:
  T& ref() const {
    return value;
  }
};

// new vocabulary type
move_only_function<void() const> f =
  [s, b = as_owned_mutable<Buffer>{}]() {
    auto& buffer = b.ref();
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, mutable b] {
    // ...
  };
```
  ],[
```cpp
// loss of const correctness
move_only_function<void()> f =
  [s, b]() mutable {
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, mutable b] {
    // ...
  };
```
  ],[
```cpp
// loss of ownership
move_only_function<void() const> f =
  [s, buf_ptr = &b]() {
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, mutable b] {
    // ...
  };
```
  ]
)

=== Selective Moves with init-capture Packs

Following the direction set out in
#link("https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p2095r0.html")[
P2095], using the example in
#link("http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0780r2.html")[
P0780], we are able to move arguments from caller, to lambda, to callee --
without
having to stop at the lambda:

```cpp
template <class... Args>
auto delay_invoke_foo(Args... args, State s) {
  return [s, mutable ...args=std::move(args)] {  // <-- new
    return foo(s, std::move(args)...);           // <-- improved
  };
}
```

== Feature 2: Const Capture on Mutable Call Operator

If lambda capture initialization can be modified by `mutable` and lambda
closure call can be modified by `mutable`, then lambda closure calls modified by
`mutable` should be able to declare some of their captures `const` -- an
inversion of this paper's core proposal.

=== Value

If most of the values captured are mutable, but one should be `const`, then this
variation would be shorter and more readable. The alternative is to simply leave
otherwise const captures mutable, or to use `std::cref`. The former is
less safe, and the latter may be undesirable because the lambda does not own the
object referred to, which may create lifetime issues. Moreover it requires a
more verbose assignment syntax.

Allowing `const` captures is ergonomic and simple.

#table(
  columns: (1fr, 1fr),
  align: bottom,
  [Before], [After],
  [
```cpp
template <typename T>
class as_owned_const {
  T value;
 public:
  const T& ref() const {
    return value;
  }
};

// new vocabulary type
move_only_function<void()> f =
  [s, b = as_owned_const<Buffer>{}] mutable {
    auto& buffer = b.ref();
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, const b] mutable {
    // ...
  };
```
  ],
  [
```cpp
// loss of const correctness
move_only_function<void()> f =
  [s, b]() mutable {
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, const b] mutable {
    // ...
  };
```
  ],
  [
```cpp
// loss of ownership
move_only_function<void()> f =
  [s, buf = std::cref(b)]() mutable {
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, const b] mutable {
    // ...
  };
```
  ],
)

=== Implementation

```cpp
auto b = [x, const y]() mutable {};

// equivalent to:

struct B {
  X x;
  const Y y;
  void operator()() {}
};
```

A `const` member would make the lambda closure assignment operators deleted, but
lambda closures with captures
#link("https://eel.is/c++draft/expr#prim.lambda.closure-15")[already delete the
copy assignment operator].

A `const` member would also cause the move constructor to be implemented via
copy, potentially causing it non-noexcept, depending on the copy constructor of
the const member.

We can avoid these problems with another implementation strategy by invoking
"as-if":

```cpp
// equivalent to:

struct B {
  X x;
  Y y;
  void operator()() {
    // as-if y was declared const
  }
};
```

== Feature 3: Const Capture by Reference

Capture by reference is not implicitly `const`, as capture by value is. However
there are situations where it would be useful to capture by `const` reference,
such as when a read-only object is too large to copy.

=== Value

The same effect can be achieved using `std::cref` and `std::as_const` -- but
this syntax is intuitive, concise and improves symmetry of this proposal.

#table(
  columns: (1fr, 1fr),
  [Before], [After],
  [
```cpp
move_only_function<void() const> f =
  [s, huge = std::cref(huge)] mutable {
    // ...
  };
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, const& huge] mutable {
    // ...
  };
```
  ]
)

=== Implementation

```cpp
auto b = [&x, const &y]() {};

// equivalent to:

struct B {
  X &x;
  const Y &y;
  void operator()() const {}
};
```

We could also invoke compiler magic using "as-if"

```cpp
// equivalent to:

struct B {
  X &x;
  Y &y;
  void operator()() {
    // as-if y was declared const Y&
  }
};
```

== Feature 4: Const Default Capture

When capturing by value with `=`, the constness of the captured entities
depends on the declaration of the captured entity and the presence of the
mutable specifier. There is no way to express the intent of const capture
for capture defaults.

```cpp
int x = 42;
auto b = [const =] () {
    // x is captured as-if it was const
    x = 1; // error
}
```

=== Value

Declaring `[const =]` makes the read-only intent clear even on a mutable lambda,
without requiring each capture to be individually annotated const. It is the
default-capture analogue of "Const Capture on Mutable Call Operator".

== Feature 5: Const Default Capture by Reference

Similarly to "Const Default Capture", the constness of entities captured by
reference depends on the declaration of the entity. `[const &]` as a
capture-default expresses the read-only intent clearly. Applying `std::cref` or
`std::as_const` to each captured entity represents a chance to miss a variable
and lose the protection of `const`. The capture-all does not post this issue.
This can also be used as a novel means of creating read-only code blocks.

#table(
  columns: (1fr, 1fr),
  [Before], [After],
  [
```cpp
X a, b, c;
...
{
  // manual wrapping
  auto& c_a = std::as_const(a);
  auto& c_b = std::as_const(b);
  auto& c_c = std::as_const(c);
  // ... enter const context
}
```
  ],[
```cpp
X a, b, c;
...
[const &] {


  // ... const context


}();
```
  ]
)

== Feature 6: Explicitly Const Call Operator

For symmetry with the call operator of bespoke types, declaring the lambda const
should not be an error.

```cpp
auto c = [x]() const {};

// equivalent to:

struct C {
  X x;
  void operator()() const {}
};
```

== Feature 7: Const Capture by Value on Const Call Operator

For symmetry and principle of least surprise, declaring a const capture of a
const lambda should not be an error.

```cpp
auto c = [const x]() {};
```

See "Const Capture by Value on Mutable Call Operator".

== Feature 8: Mutable Capture on Mutable Call Operator

For symmetry and principle of least surprise, declaring a mutable capture of a
mutable lambda should not be an error.

```cpp
auto c = [mutable x]() mutable {};

// equivalent to:

struct C {
  mutable X x;
  void operator()() {}
};
```

== Benefits of Consistency and Symmetry

The core benefits of features 6, 7, and 8 is lower cognitive load for
programmers learning C++, and principle of least surprise. We can teach why
lambdas default the way they do, but lambdas should have consistent and
symmetric vocabulary for teaching how lambdas transform into callable types
under the hood.

Experienced users will also benefit from additional self-documentation,
especially in critical reliability contexts where verbosity and redundancy are
preferred. Users would declare the lambda `mutable` or `const` according to
ideal or majority semantics, and some minority of capture initialization would
be the opposite, as an exception.

= Concerns

== East v. West Const

In both East or West-const, the const always appears before the identifier. This
proposal does not change that.

== Pointer to Const v. Const Pointer

Current lambda behavior mandates bitwise const, which is const-pointer (not
pointer to const). This proposal seeks to continue and not to modify that rule.

```cpp
auto c = [const x = ptr]() {
  *x = {};      // ok
  x = nullptr;  // error
};
```

== Interactions with `this`

The keyword `this` is a prvalue expression, and is special cased with regard to
lambda captures. As such, the meaning of `mutable this` and `const this` doesn’t
have obvious semantics -- or if we defined them may be hard to teach. We
recommend these two combinations be disallowed until further experience is
accrued.

Students will likely expect the following to compile (it would not):

```cpp
struct A {
  void mutate() {}
  void test() const {
    [mutable this] {
      this->mutate();
    }();
  }
};
```

Whereas the following would compile and work:

```cpp
struct B {
  void mutate() {}
};

void test(B* that) {
  [mutable that] {
    that->mutate();
    that = nullptr;
  }();
}
```

Recall const pointer lambda capture is _bitwise_ const, which affects if the
pointer itself can be modified. The `this` pointer can never be modified and so
`mutable this` or `const this` would either be meaningless if bitwise const, or
inconsistent if logically const.

The meaning of `mutable *this` and `const *this` is much clearer, but for the
sake of consistency when teaching "`this` is special", we recommend dis-allowing
this form as well.

== Complexity of Implementation

Ville Voutilainen implemented the proposal along with the extensions proposed in
P2034R5 in GCC with regression tests, and gave the following report.

#block(stroke: (left: 2pt + gray))[
#quote[
In general, the implementation was very straightforward, after discussing the
approach with the maintainer, and coming to the conclusion that it's simply a
matter of adjusting the types of the capture members of lambda for const, and
the storage-class-specifier for mutable. The implementation effort was a matter
of a single afternoon.
]
]

The implementation is available on
#link("https://github.com/villevoutilainen/gcc/tree/lambda-p2034")[GitHub] and
can be tested on #link("https://godbolt.org/z/9fcoYeMMf")[Compiler Explorer].

= Thanks

Thanks Patrick McMichael for suggesting the idea. Thanks to Nevin Liber,
Matt Calabrese for offering important corrections. Thanks to Nevin Liber,
Davis Herring, Barry Revzin, and Victoria Tsai, for examples and suggestions.
Thanks to Ville for the exploratory implementation! Thanks to Lakshay Garg for
becoming the second author. Thanks to Daveed Vandevoorde for providing
suggestions and feedback on the wording.

#pagebreak()

= Proposed Wording

== expr.prim.id.unqual

#nobreak[
=== Change in #underline[expr.prim.id.unqual] (7.5.5.2) paragraph 4
#quote[
If
- the _unqualified-id_ appears in a _lambda-expression_ at program point P,
- the entity is a local entity or a variable declared by an _init-capture_,
- naming the entity within the _compound-statement_ of the innermost enclosing
  _lambda-expression_ of P, but not in an unevaluated operand, would refer to an
  entity captured #del[by copy] in some intervening _lambda-expression_, and
- P is in the function parameter scope, but not the
  _parameter-declaration-clause_, of the innermost such _lambda-expression_ _E_,

then the type of the expression is #replace[the type of a class member access
expression naming the non-static data member that would be declared for such a
capture in the object parameter of the function call operator of _E_.][:
- the type of a class member access expression naming the non-static data member
  that would be declared for such a capture in the object parameter of the
  function call operator of _E_ if some intervening _lambda-expression_ captures
  the entity by copy,
- the type of the entity if all the intervening _lambda-expression_\s capture
  the entity by non-const reference, or
- the const qualified type of the entity if all intervening
  _lambda-expression_\s capture the entity by reference, and at least one
  captures the entity by const reference.
]

\[_Note 3:_ If _E_ is not declared `mutable` #ins[and the entity is not captured
mutably (expr.prim.lambda.capture) by _E_], the type of such an identifier will
typically be `const` qualified. --- _end note_\]
]
]

== expr.prim.lambda.general

#nobreak[
=== Change in #underline[expr.prim.lambda.general] (7.5.6.1)
#quote[#grammar[
lambda-specifier:  \ #tab
	`consteval`      \ #tab
	`constexpr`      \ #tab
	#ins[`const`]    \ #tab
	`mutable`        \ #tab
	`static`
]]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.general] (7.5.6.1) paragraph 4
#quote[
A _lambda-specifier-seq_ shall contain at most one of each _lambda-specifier_
and shall not contain both `constexpr` and `consteval`.
If the _lambda-declarator_ contains an explicit object parameter, then no
_lambda-specifier_ in the _lambda-specifier-seq_ shall be #ins[`const`,]
`mutable`, or `static`.
The _lambda-specifier-seq_ shall #del[not contain both `mutable` and `static`]
#ins[contain at most one of `const`, `mutable`, or `static`].
If the _lambda-specifier-seq_ contains `static`, there shall be no
_lambda-capture_.
]
]

== expr.prim.lambda.closure

#nobreak[
=== Add a note to #underline[expr.prim.lambda.closure] (7.5.6.2) paragraph 7
#quote[
The function call operator or operator template is a static member function of
static member function template if the _lambda-expression_'s
_parameter-declaration-clause_ is followed by `static`.
Otherwise, it is a non-static member function or member function template that
is declared `const` if and only if the _lambda-expression_'s
_parameter-declaration-clause_ is not followed by `mutable` and the
_lambda-declarator_ does not contain an explicit object parameter.
It is neither virtual nor declared `volatile`.
Any _noexcept-specifier_ or _function-contract-specifier_ specified on a
_lambda-expression_ applies to the corresponding function call operator or
operator template.
An _attribute-specifier-seq_ in a _lambda-declarator_ appertains to the type of
the corresponding function call operator or operator template.
An _attribute-specifier-seq_ in a _lambda-expression_ preceding a
_lambda-declarator_ appertains to the corresponding function call operator or
operator template.
The function call operator or any given operator template specialization is a
constexpr function if either the corresponding _lambda-expression_'s
_parameter-declaration-clause_ is followed by `constexpr` or `consteval`, or it
is constexpr-suitable.
It is an immediate function if the corresponding _lambda-expression_'s
_parameter-declaration-clause_ is followed by `consteval`.

#ins[\[_Note_: The `const` _lambda-specifier_ has no additional effect; the
function call operator is declared `const` if and only if `mutable` and `static`
are not specified, regardless of whether `const` is present. _-- end note_\]]
]
]

== expr.prim.lambda.capture

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3)
#quote[#grammar[
lambda-capture:                    \ #tab
	capture-default                \ #tab
	capture-list                   \ #tab
	capture-default, capture-list

capture-default:                   \ #tab
	#ins[`const`#sub[opt]] &   \ #tab
	\=

capture-list:                      \ #tab
	capture                        \ #tab
	capture-list, capture

capture:                           \ #tab
	simple-capture                 \ #tab
	init-capture

simple-capture:                            \ #tab
	#ins[`mutable`#sub[opt]] identifier ...#sub[opt] \ #tab
	#ins[`const`#sub[opt]] & identifier ...#sub[opt] \ #tab
	this                                   \ #tab
	\*this

init-capture:                                           \ #tab
	#ins[`mutable`#sub[opt]] ...#sub[opt] identifier initializer \ #tab
	#ins[`const`#sub[opt]] & ...#sub[opt] identifier initializer
]]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 2
#quote[
If a _lambda-capture_ includes a _capture-default_ that is
#replace[`&`][not `=`], no #del[identifier in a] _simple-capture_ of that
_lambda-capture_ shall #del[be preceded by `&`]
#ins[begin with that _capture-default_].
If a _lambda-capture_ includes a _capture-default_ that is `=`, each
_simple-capture_ of that _lambda-capture_ shall be of the form
"`&`~_identifier_ ...#sub[_opt_]"
#ins[, "`const &` _identifier_ ...#sub[_opt_]"], "`this`", or "`* this`".
]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 6
#quote[
An _init-capture_ inhabits the lambda scope of the _lambda-expression_.
An _init-capture_ without ellipsis behaves as if it declares and explicitly
captures a variables of the form "`auto` _init-capture_ `;`"
#ins[ignoring any leading `mutable` keyword], except that:

- if the capture is by copy (see below), the non-static data member declared for
  the capture and the variable are treated as two different ways of referring to
  the same object, which has the lifetime of the non-static data member, and no
  additional copy and destruction is performed, and
- if the capture is by reference, the variable's lifetime ends when the closure
  object's lifetime ends.
]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 10
#quote[
An entity is _captured by copy_ if
- it is implicitly captured, the _capture-default_ is `=`, and the captured
  entity is not `*this`, or
- it is explicitly captured with a capture that is not of the form `this`,
  `&` _identifier_ ...#sub[_opt_], #ins[`const &` _identifier_ ...#sub[_opt_]]
  #replace[or][,] `&` ...#sub[_opt_] _identifier initializer_
  #ins[or `const &` ...#sub[_opt_] _identifier initializer_].

#ins[An entity captured by copy is said to be _captured mutably_ if the
_capture_ begins with the `mutable` keyword.]

For each entity captured by copy, an unnamed non-static data member is declared
in the closure type.
The declaration order of these members is unspecified.
The type of such a data member #replace[is the referenced type if the entity is
a reference to an object, an lvalue reference to the referenced function type if
the entity is a reference to a function, or the type of the corresponding
captured entity otherwise.][corresponding to a captured entity of type `T` is:]
#ins[
- an lvalue reference to the referenced function type if the entity is a
  reference to a function,
- `std::remove_const_t<std::remove_reference_t<T>>` if the entity is captured
  mutably, or
- `std::remove_reference_t<T>` otherwise.]
#ins[The data member is declared `mutable` if the entity is captured mutably.]
A member of an anonymous union shall not be captured by copy.
]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 12
#quote[
An entity is _captured by reference_ if it is implicitly or explicitly captured
but not captured by copy.
#ins[An entity captured by reference is _captured by const reference_ if it is
either explicitly captured with a `const &` capture, or it is implicitly
captured and the _capture-default_ is `const &`.]
It is unspecified whether additional unnamed non-static data members are
declared in the closure type for entities captured by reference.
If declared, such non-static data members shall be of literal type.
]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 13
#quote[
An _id-expression_ within the _compound-statement_ of a _lambda-expression_ that
is an odr-use of a reference captured by reference refers to the entity to which
the captured reference is bound and not to the captured reference.
#ins[If the entity is captured by const reference, the type of such an
id-expression is const-qualified.]
]
]

#nobreak[
=== Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 14
#quote[
If a _lambda-expression_ `m2` captures an entity and that entity is captured by
an immediately enclosing _lambda-expression_ `m1`, then `m2`'s capture is
transformed as follows:

- If `m1` captures the entity by copy, `m2` captures the corresponding
  non-static data member of `m1`'s closure type; if `m1` is not `mutable`
  #ins[and the entity is not captured mutably], the non-static data member is
  considered to be const-qualified.
- If `m1` captures the entity by reference, `m2` captures the same entity
  captured by `m1`.
]
]

// vim:cc=81:tw=80
