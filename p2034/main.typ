// Document formatting rules
#let font-serif = "NotoSerif NFP"
#let font-sans  = "NotoSans NFP"
#let font-mono  = "NotoMono NFP"
#let font-size  = 10pt

#let link-blue = rgb("#0000EE")
#let diff-green = rgb("#BAECBF")
#let diff-red = rgb("#F7D0CC")
#let quote-gray = rgb("#D1D9E0")
#let quote-stroke = 0.25em

#set page("us-letter", margin: 0.75in)
#set heading(numbering: "1.1 ")
#set par(justify: true)
#set text(
    size: font-size,
    font: font-serif,
    hyphenate: false
)

#set list(marker: [--])
#show list: set block(above: 1.2em, below: 1.2em)

#show raw: set text(size: font-size, font: font-mono)
#show raw.where(block: true): it => block(breakable: false, it)

#show link: it => underline(stroke: link-blue, text(fill: link-blue, it))

#set quote(block: true)
#show quote: it => block(
    above: 1em,
    outset: (left: -quote-stroke, right: 0pt),
    inset: (left: 1em, y: 0.8em),
    stroke: (
        left: (
            thickness: quote-stroke,
            paint: quote-gray,
            cap: "round"
        )
    ),
    it
)

// prevent linebreak in the middle of grammar terms
#show emph: it => box(it)

#set sub(baseline: 0em) // hacky!
#set highlight(top-edge: 8.5pt, bottom-edge: -2pt)
#set underline(stroke: (paint: black, thickness: 0.5pt), offset: 1.5pt)
#set strike(stroke: (paint: black, thickness: 0.5pt), offset: -2.5pt)

#let ins(body) = highlight(fill: diff-green, underline(body))
#let del(body) = highlight(fill: diff-red, strike(body))
#let replace(before, after) = del(before) + ins(after)
#let nobreak(body) = block(breakable: false, body)
#let eelis(section, ..p) = {
    let url = "https://eel.is/c++draft/" + section
    let txt = "[" + section + "]"
    if p.pos().len() > 0 {
        let pp = p.pos().map(str).join(".")
        url += "#" + pp
        txt += " paragraph " + pp
    }
    link(url, txt)
}
#let grammar(body) = par(
    justify: false,
    hanging-indent: 2em,
    text(font: font-sans, style: "oblique", body)
)

#set document(
    title: "Partially Mutable Lambda Captures",
    author: ("Ryan McDougall", "Lakshay Garg"),
    keywords: ("C++29", "lambda", "capture", "mutable", "const")
)
#title()
#table(
    columns: 2,
    inset: (left: 0%, y: 4pt),
    stroke: none,
    "Document", link("https://wg21.link/P2034")[P2034R7],
    "Date",     datetime.today().display(),
    "Audience", "EWG",
    "Project",  [ISO/IEC JTC1/SC22/WG21 14882: Programming Language -- C++],

    table.cell(rowspan:2)[Authors],
    [Ryan McDougall `<mcdougall.ryan@gmail.com>`],
    [Lakshay Garg `<lakshayg.xyz@gmail.com>`],

    "GitHub Issue", link("https://wg21.link/P2034/github"),
    "Source", link("https://github.com/lakshayg/wg21/tree/main/p2034")
)

#outline(/*depth: 2*/)
#pagebreak()

// Table header highlight
#set table(
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { gray.lighten(40%) }
)

= Revision History
#set heading(numbering: none, outlined: false)
== Changes from R6: #link("https://wiki.isocpp.org/2026-03_Croydon:EvolutionWorkingGroup:P2034R6")[EWG Discussion]

- Fix code examples
- Changed the NSDM type for mutable captures
- TODO include mutable capture default
- TODO add design section discussing member types

// Interested people:
// - Ryan McDougall
// - Ville Voutilainen
// - Mattermost: xazax
// - Mattermost: opensdh
//
// ---
// opensdh:
// It is to me really weird that this already doesn't work:
// int f() {
//   const int x = 0;
//   auto g = [x]() mutable {return x++;};  // error: x is declared const
//   return g() + g();  // surely 1
// }
//
// I'd be happy with exploring this space if it meant that we could fix that someday.
// 9:43 AM
//
// auto y = x; wouldn't do that, but lambdas do (even without &).
// ---
//
// Design questions:
// - What should be the type of entities captured by const value
// - Can a lambda containing const members movable?
// - A lot of the lambda behavior diverges

== Changes from R5: #link("https://wiki.isocpp.org/2025-11_Kona:EWGP2034Notes")[EWG Discussion]

- Incorporate extensions into the main proposal.
- Add discussion of capture defaults to the proposal.
- Rearranged some sections and updated links.
- Add wording for:
  - mutable captures
  - const-ref captures
  - const-ref capture-default
  - const specifier

== Changes from R4: #link("https://wiki.isocpp.org/2025-06_Sofia:NotesEWGP2034")[EWG Discussion]

- Implementation experience.

== Changes from R3: #link("https://wiki.isocpp.org/2024-03_Tokyo:NotesEWGIP2034R2")[EWG-I Discussion]

- Meta-motivation: safety and security -- const should be easier to get right
  and harder to get wrong.
- Cleaned up some examples.

== Changes from R2

- Update author email addresses.
- Rename `any_invocable` to `move_only_function`.

== Changes from R1

- Add discussion of const captures on move construction and assignment.
- Add vocabulary type `as_mutable`.
- Add alternative implementation strategy for const members.
- Selective move feature in top section.

== Changes from R0: #link("https://wiki.isocpp.org/2020-02_Prague:P2034R0SG17")[Concerns from EWG-I]

- Interactions with `this` pointer.
- Interactions with init-capture packs.
- Clarify const as it applies to pointers.
- Add const-reference use case.
- Expanded prose.

#pagebreak()

#set heading(numbering: "1.1 ", outlined: true)
= Polls
#set heading(numbering: none)

== 2026-03 Croydon, R6

P2034R6 should include default mutable captures: _Strong Consensus in favor_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [3],[28],[4],[0],[0],
)

P2034R6 should explore making const-capture equivalent to a const member:
_Strong Consensus in favor_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [8],[25],[1],[2],[0],
)

Encourage more work in the direction of P2034R6: _Strong Consensus in favor_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [14],[26],[2],[0],[0],
)

== 2025-11 Kona, R5

We \[EWG\] encourage further work on this paper towards C++29:
_Strong Consensus_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [21],[27],[5],[0],[0],
)

== 2025-06 Sofia, R4

EWG encourages more work in the direction of Partially Mutable Lambda Captures:
_Consensus_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [1],[10],[4],[2],[1],
)

EWG encourages more work in the direction of Partially Mutable Lambda Captures,
including extensions: _Stronger consensus_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [2],[15],[3],[1],[0],
)

== 2024-03 Tokyo, R2

EWGI believes P2034R3 should include a `const` qualifier for lambda captures:
_Barely consensus_ (Comment: motivation could be better)

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [2],[4],[4],[1],[0],
)

EWGI believes P2034R3 is sufficiently well developed, EWGI forwards it to EWG:
_Consensus_

#table(
  columns: 5,
  [SF],[F],[N],[A],[SA],
  [3],[7],[0],[0],[0],
)

#pagebreak()

#set heading(numbering: "1.1 ")
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

`move_only_function` was accepted into the C++23 standard, and a central
improvement is that it respects the `const` modifier on function types (ie.
`move_only_function<void(int) const>`). This means a `move_only_function` with a
`const` modifier on its call type will only bind to lambdas that are not marked
`mutable`.

A type that is
#link("https://isocpp.org/wiki/faq/const-correctness#mutable-data-members")[
"logically const"] is a type that has some mutable members that do not
fundamentally change the invariants of the object, even when it is const. This
means `move_only_function`, and _any_ other const-correct library, _cannot_ work
with logically const lambdas.

= Meta-Motivation

The proposal would allow programmers to *apply `const` with simplicity and
precision* to lambda captures -- improving applicability of const in cases
where programmers would otherwise:

1. Declare the lambda blanket mutable.
2. Declare captures by const {non-}propagating wrapper.

Applying `const` with more purpose and simpler syntax would improve the safety
and security of such code -- especially for programmers that have learned about
the `const` declarations, but are not yet comfortable with
`const`-{non-}propagating wrappers. Avoiding use of wrappers also makes lambda
captures smaller and thus easier to read and reason about.

= Motivation

Type erased callables like `std::move_only_function` are the backbone of most
asynchronous systems. Users of such systems enclose their operations in lambdas
and place them in a concurrent queue to be processed elsewhere. Performance is
often key in such systems, and such operations may want its own local reusable
scratch memory. Or perhaps an accumulator for hysteresis over multiple calls.

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

Lambdas in such cases require workarounds, such as abandoning logical const
correctness, abandoning ownership, or introducing intermediary
{non-}const-propagating intermediary types. Strict ownership rules are important
due the asynchronous nature of the handler, and const correctness is important
for memory- and thread-safety

= Proposal

We propose a number of enhancements to the lambda syntax that simplify creating
const-correct lambdas. In addition to const-correctness, these features improve
the consistency and symmetry -- which the authors believe is a justification in
its own right.

// The proposed enhancements are summarized below in the order of their perceived
// usefulness followed by a more detailed explanation for each of these items.
//
// Existing symmetries in lambdas:
// - each capture type has a corresponding capture default
//
// Unfortunate:
// [x] is not the same as [x = x];
//
//
// 2. Const capture
//    - mainly important for mutable lambdas
//    - to avoid surprising behavior, also allow for const lambdas
//    - this is a by-copy capture and therefore NSDM will be generated just like regular copy captures
//    - Choice
//      - the NSDM will have a top-level const added to it, OR
//        - What happens to move ctor and assignment?
//        - Are there any concerns?
//      - we need to treat this member as a const in operator()
//        - could it be confusing?
//    - also allow const capture-default for symmetry
//
// 3. Const capture by reference
//    - also allow as a capture-default, for symmetry
//    - does the standard require NSDM for reference captures?
//      - do we need to mandate a NSDM for const reference capture?
//      - if we don't mandate a NSDM,  the reference will need to be treated as const in operator()
//
// 4. Explicitly const call operator
//    - For symmetry and principle of least surprise

== Mutable Capture

We propose a new form of by-copy capture, called the mutable capture. Allow
lambda captures to be `mutable` qualified, as shown below. The standard
mandates that by-copy captures create a non-static data member (NSDM) in the
closure type. A mutable capture, in addition to defining a NSDM, would have the
effect of declaring it `mutable`.

=== Syntax

#table(
  columns: (auto, 1fr),
  [Capture Syntax],[Description],
  [```cpp [mutable x]() {}```],[creates a `mutable` NSDM in the closure type],
  [```cpp [mutable x...]() {}```],[],
  [```cpp [mutable x = init]() {}```],[mutable init capture],
  [```cpp [mutable ...xs = init]() {}```],[],
  [```cpp [mutable]() {}```],[mutable implicit capture, analogous to value implicit capture `[=]`]
)

=== Value

The table below shows code that can be written in the language today
and how it would benefit from the addition of this feature.

#table(
  columns: (1.1fr, 1fr),
  align: bottom,
  [Before], [After],
  [
```cpp
struct A {
  State state;
  mutable Buffer buf;
  void operator()() const {
    // ...
  }
};

// manual bespoke type
move_only_function<void() const> f =
  A{s, b};
```
  ],[
```cpp
move_only_function<void() const> f =
  [s, mutable b] { /* ... */ };
```
  ],[
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

// === Selective Moves with init-capture Packs
//
// Following the direction set out in
// #link("https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p2095r0.html")[
// P2095], using the example in
// #link("http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0780r2.html")[
// P0780], we are able to move arguments from caller, to lambda, to callee --
// without
// having to stop at the lambda:
//
// ```cpp
// template <class... Args>
// auto delay_invoke_foo(Args... args, State s) {
//   return [s, mutable ...args=std::move(args)] {  // <-- new
//     return foo(s, std::move(args)...);           // <-- improved
//   };
// }
// ```

=== Design Considerations

==== Applicability to mutable lambdas

We propose that mutable captures be allowed even for mutable lambdas. Even though
this would not have any effect on the functionality of the lambda, it improves the
symmetry of the language and avoids causing surprise to the end user.

==== Type of the non-static data member

For by-copy captures, the standard requires that the closure type contain a corresponding
non-static data member and defines rules for how the type of the NSDM is deduced.

#eelis("expr.prim.lambda.capture", 6)
#quote[
[...] behaves as if it declares and explicitly captures
a variable of the form "`auto` _init-capture_ `;`", [...]
]

#eelis("expr.prim.lambda.capture", 10)
#quote[
For each entity captured by copy, an unnamed non-static data member is declared
in the closure type. [...]. The
type of such a data member is the referenced type if the entity is a reference
to an object, an lvalue reference to the referenced function type if the entity
is a reference to a function, or the type of the corresponding captured entity
otherwise. [...]
]

Following these rules for mutable captures can lead to invalid constructs
because, unfortunately, simple-captures retain the cv-qualifiers of the
captured entity.

- `const` qualified object -> ```cpp mutable const T obj;```
- reference to a `const` qualified object -> ```cpp mutable const T obj;```

It would be possible to create such scenarios easily in template code or during
refactors. We have a few options here:

1. Disallow mutable simple-capture of cv-qualified objects and references to such objects, or
2. Discard the top-level const qualifier from captured objects, or
3. Use `auto` deduction rules like init-captures do

It is unclear if one of these is clearly the superior option but option 3 seems the
most appropriate because it could be understood as: "the language uses decltype like
rules unless the user explicitly specifies the kind of declaration they want". This
will also be applicable to `const` captures. This will also avoid introducing another
set of type deduction rules.

// #table(
//   columns: 2,
//   [],[],
// [
// ```cpp
// const T x;
// auto outer = [x] () {
//   auto inner = [x] () mutable {
//     // x is const
//   };
// };
// ```
// ],[],
// [
// ```cpp
// const T x;
// auto outer = [mutable x] () {
//   auto inner = [x] () mutable {
//     // x is non-const
//   };
// };
// ```
// ],[]
// )
//
==== Mutable capture of reference types

We explicitly disallow capture of the form ```cpp [mutable &x]```. This is
because `mutable` references are not permitted by the language. Note that
this is not the same as mutable capture of a reference type:

```cpp
T& x = ...;
auto f = [mutable x]() { }; // closure type gets a `mutable T x;` member
```

==== Implicit capture of `this` with `mutable` _capture-default_

C++20 deprecated the implicit reference capture of `*this` when using `=` as the
capture default. Keeping in line with this direction, we propose that `*this`
not be captured implicitly when `mutable` is used as the capture default.

```cpp
struct Foo {
  int x;
  void func() {
    auto lambda1 = [=] () {
      return x;   // deprecated, but compiles
    };
    auto lambda2 = [mutable] () {
      return x;   // fails to compile, *this is not captured implicitly
    };
    auto lambda3 = [mutable, this] () {
      return x;   // *this is captured explicitly, good!
    };
  }
};
```

==== Interaction with `consteval` and `constexpr` lambdas

The standard (#eelis("expr.const", 8, 8)) excludes `mutable` members from being
used in constant expressions. Keeping in line with this behavior, we disallow
mutable captures in `constexpr` and `consteval` lambdas.

== Const Capture

If lambda captures can be modified by `mutable` and lambda closure call can be
modified by `mutable`, then lambda closure calls modified by `mutable` should
be able to declare some of their captures `const` -- an inversion of this
paper's core proposal.

=== Syntax

#table(
  columns: (auto, 1fr),
  [Capture Syntax],[Description],
  [```cpp [const x]() mutable {}```],[],
  [```cpp [const x...]() mutable {}```],[],
  [```cpp [const x = init]() mutable {}```],[],
  [```cpp [const ...xs = init]() mutable {}```],[],
  [```cpp [const]() mutable {}```],[]
)

=== Value

If most of the values captured are modifiable, but one should be `const`, then
this variation would be shorter and more readable. The alternative is to simply
leave otherwise const captures modifiable, or to use `std::cref`. The former is
less safe, and the latter may be undesirable because the lambda does not own
the object referred to, which may create lifetime issues. Moreover it requires
a more verbose assignment syntax.

Allowing `const` captures is ergonomic and simple.

#table(
  columns: (1.3fr, 1fr),
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
move_only_function<void()> f =
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
    // b can be mutated
  };
```
  ],[
```cpp
move_only_function<void()> f =
  [s, const b] mutable {
    // ...
  };
```
  ],
  [
```cpp
// loss of ownership
move_only_function<void()> f =
  [s, b = std::cref(buf)]() mutable {
    // ...
  };
```
  ],[
```cpp
move_only_function<void()> f =
  [s, const b] mutable {
    // ...
  };
```
  ],
)

=== Design Considerations

==== Applicability to const lambdas

==== Type of the non-static data member

similar to mutable rules

==== Const capture of reference types

Should we mandate creating a const ref member?
Otherwise nested lambdas will need to figure out some way to do things correctly

==== Implicit capture of `this` with const _capture-default_

Not allowerd


== Const Capture by Reference

Capture by reference is not implicitly `const`, as capture by value is. However
there are situations where it would be useful to capture by `const` reference,
such as when a read-only object is too large to copy.

=== Syntax

=== Value

The same effect can be achieved using `std::cref` and `std::as_const` -- but
this syntax is intuitive, concise and improves symmetry of this proposal.

#table(
  columns: (1fr, 1fr),
  [Before], [After],
  [
```cpp
move_only_function<void()> f =
  [s, huge = std::cref(huge)] mutable {
    // ...
  };
```
  ],[
```cpp
move_only_function<void()> f =
  [s, const& huge] mutable {
    // ...
  };
```
  ]
)

=== Design Considerations


== Explicitly const Call Operator

=== Syntax

=== Value

=== Design Considerations


// = Benefits of Consistency and Symmetry
//
// The core benefits of features 6, 7, and 8 is lower cognitive load for
// programmers learning C++, and principle of least surprise. We can teach why
// lambdas default the way they do, but lambdas should have consistent and
// symmetric vocabulary for teaching how lambdas transform into callable types
// under the hood.
//
// Experienced users will also benefit from additional self-documentation,
// especially in critical reliability contexts where verbosity and redundancy are
// preferred. Users would declare the lambda `mutable` or `const` according to
// ideal or majority semantics, and some minority of capture initialization would
// be the opposite, as an exception.

// = Design
//
// const specifier on lambda
//
// TODO Discuss behavior in:
// - const lambdas
// - mutable lambdas
// - nested lambdas
//
// - object (consider cv-qualifiers)
// - reference (consider whether referred type is const or not)
// - function type
//
// - \*this
// - const \*this
//
// - NSDMs are created for entities captured by copy - expr.prim.lambda.closure p10
// - It is unspecified whether additional unnamed non-static data members are
//   declared in the closure type for entities captured by reference. If declared,
//   such non-static data members shall be of literal type. -
//   expr.prim.lambda.closure p12
//
//
// == Simple Capture or Implicit Capture by Copy
//
// - Non static data member is declared
// - The type of the non-static data member is:
//   - if the entity is an object, the type is the entity's type
//   - if the entity is a reference, the type is the referenced type
//   - if the entity is a function reference, the type is an lvalue reference to
//     the referenced function
//
// For mutable captures, we extend these three cases as follows:
//
// - The type of the mutable non-static data member is
//   - object: entity's type, with any top-level const removed
//   - reference: the referred type with any top-level const removed
//   - function reference: mutable is ignored
//
// - For const capture, we extend these three cases as follows:
//   - object: const type
//
//
// Unfortunate that simple capture preserves the cv qualifiers.
// This was done to help with code migration.
//
// === should mutable capture be allowed for const entities?
// Yes
//
// === should mutable capture be allowed for references?
// Yes
//
// === should const capture produce a const NSDM or should it use the as-if rule?
//
// how does simple capture work for const objects? it creates a const NSDM
//
// benefits of the as-if rule: freedom of implementation.
//
// Are there any unexpected behaviors that might emerge from const captures being
// implemented without a const member?
//
//
// == Simple Capture or Implicit Capture by Reference
//
//
// == Init Capture
//
// #nobreak(table(
//   columns: 4, //(1fr, 1fr, 1fr, 1fr, 1fr),
//   align: left,
//
//   table.cell(rowspan:2)[#align(bottom)[Capture Syntax]],
//   table.cell(colspan:3)[#align(center)[What's being captured?]],
//
//   // [Capture Syntax],
//   [Object],
//   [Reference],
//   [Function],
//
//   [```cpp [x]
//   [=]```],
//   [The closure type gets a NSDM of the same type as the captured entity],
//   [The closure type gets a NSDM of the referenced type],
//   table.cell(rowspan:3)[The closure type gets a NSDM that is an lvalue reference to the referenced function type],
//
//   [```cpp [mutable x]
//   [mutable]```],
//   [The closure type gets a `mutable` NSDM of the same type as the captured entity with any top-level `const` dropped],
//   [`mutable` qualified NSDM of the referred type with any top-level `const` dropped],
//   // [],
//
//   [```cpp [const x]
//   [const]```],
//   [type of NSDM is `const T`],
//   [NSDM],
//   // [],
//
//   [```cpp [&x]
//   [&]```],[],[],[],
//
//   [```cpp [const &x]
//   [const &]```],[],[],[],
// ))
//
// #table(
//   columns: (1fr, 1fr, 1fr, 1fr, 1fr),
//   [Capture Type],[object],[reference],[function],[static object],
//   [```cpp [x = init]```],[NSDM],[NSDM],[NSDM],[],
//   [```cpp [mutable x = init]```],[NSDM],[NSDM],[NSDM],[],
//   [```cpp [const x = init]```],[NSDM],[NSDM],[NSDM],[],
//   [```cpp [&x = init]```],[],[],[],[],
//   [```cpp [const &x = init]```],[],[],[],[],
// )
//
// 1. mutable capture, mutable init-capture, mutable implicit capture, mutable
//    capture of a function type, mutable capture of a reference type, mutable
//    capture of a const object, mutable capture of a non-const object
// 2. const capture, const init-capture, const implicit capture, const capture of a
//    function type, const capture of a reference type, const capture of a const
//    object, const capture of a non-const object
// 3. const reference capture, const ref init-capture, const ref implicit capture,
//    const ref capture of a function type, const ref capture of a non
// 4. mutable implicit capture
// 5. const implicit capture
// 6. const& implicit capture
// 7. explicitly const lambda

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

#quote[
In general, the implementation was very straightforward, after discussing the
approach with the maintainer, and coming to the conclusion that it's simply a
matter of adjusting the types of the capture members of lambda for const, and
the storage-class-specifier for mutable. The implementation effort was a matter
of a single afternoon.
]

The implementation is available on
#link("https://github.com/villevoutilainen/gcc/tree/lambda-p2034")[GitHub] and
can be tested on #link("https://godbolt.org/z/9fcoYeMMf")[Compiler Explorer].

= Proposed Wording
#set heading(numbering: none)

The proposed changes are based on
#link("https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2025/n5008.pdf")[
N5008].

== [expr.prim.id.unqual]

#nobreak[
=== Change #eelis("expr.prim.id.unqual", 4)
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
mutably (#eelis("expr.prim.lambda.capture")) by _E_], the type of such an
identifier will typically be `const` qualified. --- _end note_\]
]
]

== [expr.prim.lambda.general]

=== Change #eelis("expr.prim.lambda.general")
#quote[#grammar[
lambda-specifier:      \
    `consteval`        \
    `constexpr`        \
    #ins[`const`]      \
    `mutable`          \
    `static`
]]

=== Change #eelis("expr.prim.lambda.general", 4)
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

== [expr.prim.lambda.closure]

#nobreak[
=== Add a note to #eelis("expr.prim.lambda.closure", 7)
#quote[
The function call operator or operator template is a static member function or
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
are not specified, regardless of whether `const` is present. --- _end note_\]]
]
]

== [expr.prim.lambda.capture]

=== Change #eelis("expr.prim.lambda.capture")
#quote[
#grammar[
lambda-capture:                      \
    capture-default                  \
    capture-list                     \
    capture-default, capture-list
]

#grammar[
capture-default:                     \
    #ins[`const`#sub[opt]] &         \
    \=
]

#grammar[
capture-list:                        \
    capture                          \
   capture-list, capture
]

#grammar[
capture:                             \
    simple-capture                   \
    init-capture
]

#grammar[
simple-capture:                                         \
    #ins[`mutable`#sub[opt]] identifier ...#sub[opt]    \
    #ins[`const`#sub[opt]] & identifier ...#sub[opt]    \
    this                                                \
    \*this
]

#grammar[
init-capture:                                                    \
    #ins[`mutable`#sub[opt]] ...#sub[opt] identifier initializer \
    #ins[`const`#sub[opt]] & ...#sub[opt] identifier initializer
]
]

#nobreak[
=== Change #eelis("expr.prim.lambda.capture", 2)
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
=== Change #eelis("expr.prim.lambda.capture", 6)
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
=== Change #eelis("expr.prim.lambda.capture", 10)
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
=== Change #eelis("expr.prim.lambda.capture", 12)
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
=== Change #eelis("expr.prim.lambda.capture", 13)
#quote[
An _id-expression_ within the _compound-statement_ of a _lambda-expression_ that
is an odr-use of a reference captured by reference refers to the entity to which
the captured reference is bound and not to the captured reference.
#ins[If the entity is captured by const reference, the type of such an
id-expression is const-qualified.]
]
]

#nobreak[
=== Change #eelis("expr.prim.lambda.capture", 14)
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

#set heading(numbering: "1.1 ")
= Thanks

Thanks Patrick McMichael for suggesting the idea. Thanks to Nevin Liber,
Matt Calabrese for offering important corrections. Thanks to Nevin Liber,
Davis Herring, Barry Revzin, and Victoria Tsai, for examples and suggestions.
Thanks to Ville for the exploratory implementation! Thanks to Lakshay Garg for
becoming the second author. Thanks to Daveed Vandevoorde for providing
suggestions and feedback on the wording.
