// Document formatting rules
#let font-serif = "Palatino"
#let font-sans  = "IBM Plex Sans"
#let font-mono  = "Monaco"

#set heading(numbering: "1.1.")
#set text(size: 10pt, font: font-serif)
#set par(justify: true)
#set page("us-letter")

#set raw(lang: "cpp")
#show raw: set text(font: font-mono)

#show link: set text(fill: rgb("#0000EE"))
#show link: underline

#set quote(block: true)
#show quote: set pad(x: 2em)
#show quote: set block(above: 1em)

#set highlight(top-edge: 8.5pt, bottom-edge: -2pt)
#set underline(stroke: (paint: black, thickness: 0.5pt), offset: 1.5pt)
#set strike(stroke: (paint: black, thickness: 0.5pt), offset: -2.5pt)

// Custom styles
#let tab = h(2em)
#let consteval = text(fill: rgb("#D73948"))[`consteval`]
#let ins(body) = highlight(fill: rgb("#90EE90"), underline(body))
#let del(body) = highlight(fill: rgb("#FFC0CB"), strike(body))
#let replace(before, after) = del(before) + ins(after)
#let nobreak(body) = block(breakable: false, body)
#let grammar(body) = text(font: font-sans, style: "italic", body)

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

= Proposed Wording

#set list(marker: [--])

Change in #underline[expr.prim.id.unqual] (7.5.5.2) paragraph 4

#quote[
If
- the _unqualified-id_ appears in a _lambda-expression_ at program point P,
- the entity is a local entity or a variable declared by an _init-capture_,
- naming the entity within the _compound-statement_ of the innermost enclosing _lambda-expression_ of P, but not in an unevaluated operand, would refer to an entity captured by copy in some intervening _lambda-expression_, and
- P is in the function parameter scope, but not the _parameter-declaration-clause_, of the innermost such _lambda-expression_ _E_,

then the type of the expression is the type of a class member access expression naming the non-static data member that would be declared for such a capture in the object parameter of the function call operator of _E_.

\[_Note 3:_ If _E_ is not declared `mutable` #ins[and the variable is not captured as `mutable`], the type of such an identifier will typically be `const` qualified. --- _end note_\]
]

Change in #underline[expr.prim.lambda.general] (7.5.6.1)

#quote[#grammar[
lambda-specifier:  \ #tab
    consteval      \ #tab
    constexpr      \ #tab
    mutable        \ #tab
    static         \ #tab
    #ins[const]
]]

Change in #underline[expr.prim.lambda.general] (7.5.6.1) paragraph 4

#quote[
A _lambda-specifier-seq_ shall contain at most one of each _lambda-specifier_ and shall not contain both `constexpr` and #consteval.
If the _lambda-declarator_ contains an explicit object parameter, then no _lambda-specifier_ in the _lambda-specifier-seq_ shall be #ins[`const`,] `mutable`, or `static`.
The _lambda-specifier-seq_ shall #replace[not contain both `mutable` and `static`][contain at most one of `const`, `mutable`, or `static`].
If the _lambda-specifier-seq_ contains `static`, there shall be no _lambda-capture_.
]

#nobreak[
Add a note to #underline[expr.prim.lambda.general] (7.5.6.2) paragraph 7

#quote[
The function call operator or operator template is a static member function of static member function template if the _lambda-expression_'s _parameter-declaration-clause_ is followed by `static`.
Otherwise, it is a non-static member function or member function template that is declared `const` if and only if the _lambda-expression_'s _parameter-declaration-clause_ is not followed by `mutable` and the _lambda-declarator_ does not contain an explicit object parameter.
It is neither virtual nor declared `volatile`.
Any _noexcept-specifier_ or _function-contract-specifier_ specified on a _lambda-expression_ applies to the corresponding function call operator or operator template.
An _attribute-specifier-seq_ in a _lambda-declarator_ appertains to the type of the corresponding function call operator or operator template.
An _attribute-specifier-seq_ in a _lambda-expression_ preceding a _lambda-declarator_ appertains to the corresponding function call operator or operator template.
The function call operator or any given operator template specialization is a constexpr function if either the corresponding _lambda-expression_'s _parameter-declaration-clause_ is followed by `constexpr` or #consteval, or it is constexpr-suitable.
It is an immediate fuunction if the corresponding _lambda-expression_'s _parameter-declaration-clause_ is followed by #consteval.

#ins[\[_Note_: The `const` _lambda-specifier_ has no additional effect; the function call operator is declared const if and only if mutable and static are not specified, regardless of whether const is present. _-- end note_\]]
]
]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3)

#quote[#grammar[
lambda-capture:                    \ #tab
	capture-default                \ #tab
	capture-list                   \ #tab
	capture-default, capture-list

capture-default:                   \ #tab
	&                              \ #tab
	#ins[const &]                  \ #tab
	\=

capture-list:                      \ #tab
	capture                        \ #tab
	capture-list, capture

capture:                           \ #tab
	simple-capture                 \ #tab
	init-capture

simple-capture:                            \ #tab
	identifier ...#sub[opt]                \ #tab
	#ins[mutable identifier ...#sub[opt]]  \ #tab
	& identifier ...#sub[opt]              \ #tab
	#ins[const & identifier ...#sub[opt]]  \ #tab
	this                                   \ #tab
	#ins[const this]                       \ #tab
	\*this

init-capture:                                           \ #tab
	...#sub[opt] identifier initializer                 \ #tab
	#ins[mutable ...#sub[opt] identifier initializer]   \ #tab
	& ...#sub[opt] identifier initializer               \ #tab
	#ins[const & ...#sub[opt] identifier initializer]
]]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 2

#quote[
If a _lambda-capture_ includes a _capture-default_ that is `&`, no identifier in a _simple-capture_ of that _lambda-capture_ shall be preceded by `&`.
#ins[If a _lambda-capture_ includes a _capture-default_ that is `const &`, no identifier in a _simple-capture_ of that _lambda-capture_ shall be preceded by `const &`.]
If a _lambda-capture_ includes a _capture-default_ that is `=`, each _simple-capture_ of that _lambda-capture_ shall be of the form "`&`~_identifier_ ...#sub[_opt_]" #ins[, "`const &` _identifier_ ...#sub[_opt_]"], "`this`", or "`* this`".
]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 6

#quote[
An _init-capture_ inhabits the lambda scope of the _lambda-expression_.
An _init-capture_ without ellipsis behaves as if it declares and explicitly captures a variables of the form "`auto` _init-capture_ `;`" #ins[(ignoring the `mutable` keyword)], except that:

- if the capture is by copy (see below), the non-static data member declared for the capture and the variable are treated as two different ways of referring to the same object, which has the lifetime of the non-static data member, and no additional copy and destruction is performed, and
- if the capture is by reference, the variable's lifetime ends when the closure object's lifetime ends#replace[.][, and]
- #ins[if the _init-capture_ contains `mutable` and the variable is not an lvalue reference to a function, the non-static data member declared for the capture is marked `mutable`.]
]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 10

#quote[
An entity is _captured by copy_ if
- it is implicitly captured, the _capture-default_ is `=`, and the captured entity is not `*this`, or
- it is explicitly captured with a capture that is not of the form `this`, #ins[`const this`], `&` _identifier_ ...#sub[_opt_], #ins[`const &` _identifier_ ...#sub[_opt_]] #replace[or][,] `&` ...#sub[_opt_] _identifier initializer_ #ins[or `const &` ...#sub[_opt_] _identifier initializer_].

#ins[If the capture contains the `mutable` keyword, the entity is said to be _captured mutably_.]

For each entity captured by copy, an unnamed non-static data member is declared in the closure type.
The declaration order of these members is unspecified.
The type of such a data member #replace[is the referenced type if the entity is a reference to an object, an lvalue reference to the referenced function type if the entity is a reference to a function, or the type of the corresponding captured entity otherwise.][:]
#ins[
- if the entity is captured non-mutably; is the referenced type if the entity is a reference to an object, an lvalue reference to the referenced function type if the entity is a reference to a function, or the type of the corresponding captured entity otherwise.
- if the entity is captured mutably; is the const-unqualified referenced type if the entity is a reference to an object, an lvalue reference to the referenced function type if the entity is a reference to a function, or the const-unqualified type of the corresponding captured entity otherwise. The data member is marked `mutable` unless it is a reference type.
]
A member of an anonymous union shall not be captured by copy.
]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 12

#quote[
An entity is _captured by reference_ if it is implicitly or explicitly captured but not captured by copy.
#ins[An entity is captured by const reference if it is captured by reference and either it is explicitly captured with a `const &` capture, or it is implicitly captured and the _capture-default_ is `const &`.]
It is unspecified whether additional unnamed non-static data members are declared in the closure type for entities captured by reference.
If declared, such non-static data members shall be of literal type.
]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 13

#quote[
An _id-expression_ within the _compound-statement_ of a _lambda-expression_ that is an odr-use of a reference captured by reference refers to the entity to which the captured reference is bound and not to the captured reference.
#ins[If the entity is captured by const reference, the type of such an id-expression is const-qualified.]
]

Change in #underline[expr.prim.lambda.capture] (7.5.6.3) paragraph 14

#quote[
If a _lambda-expression_ `m2` captures an entity and that entity is captured by an immediately enclosing _lambda-expression_ `m1`, then `m2`'s capture is transformed as follows:

- If `m1` captures the entity by copy, `m2` captures the corresponding non-static data member of `m1`'s closure type; if `m1` is not `mutable` #ins[and the entity is not captured mutably], the non-static data member is considered to be const-qualified.
- If `m1` captures the entity by reference, `m2` captures the same entity captured by `m1`#replace[.][; if `m1`'s capture is const-reference capture, the type of the captured entity as seen by `m2` is `const`-qualified.]
]
