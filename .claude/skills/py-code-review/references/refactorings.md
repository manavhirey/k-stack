# Refactoring Techniques Reference (Python)

Catalog of refactoring techniques from [refactoring.guru](https://refactoring.guru/refactoring/techniques) adapted for Python. Use during review to recommend specific, named refactorings rather than vague "clean this up" feedback.

---

## Composing Methods

Streamline methods, remove duplication, simplify logic.

### Extract Method
**When**: A code fragment can be grouped together with a clear purpose.

**Example**:
```python
def print_owing(self):
    print_banner()
    outstanding = self._calculate_outstanding()
    print_details(outstanding)
```
Extract banner printing, calculation, and detail printing as separate methods.

---

### Inline Method
**When**: A method's body is just as clear as its name; the indirection adds no value.

**Apply**: Replace the call with the body; delete the method.

---

### Extract Variable
**When**: A complex expression is hard to understand.

**Example**:
```python
if (platform.upper().find("MAC") > -1 and browser.upper().find("IE") > -1):
    ...
```
→
```python
is_mac = "MAC" in platform.upper()
is_ie = "IE" in browser.upper()
if is_mac and is_ie:
    ...
```

---

### Inline Temp
**When**: A temporary variable is assigned the result of a simple expression and used only once.

**Apply**: Inline the expression where the variable is used.

---

### Replace Temp with Query
**When**: A temporary variable holds the result of an expression. Promote it to a method/property so other code can also use it.

---

### Split Temporary Variable
**When**: A single variable is assigned more than once for different purposes within a method.

**Apply**: Use one variable per concept; rename meaningfully.

---

### Replace Method with Method Object
**When**: A method is too long with many local variables that prevent extraction.

**Apply**: Move the method into its own class where local variables become instance fields.

---

### Substitute Algorithm
**When**: An algorithm should be replaced with a clearer or more efficient one.

**Apply**: Replace the body wholesale; keep tests green.

---

## Moving Features Between Objects

Move responsibility to the right place.

### Move Method
**When**: A method uses (or is used by) another class more than its own.

**Apply**: Move the method to the class where it belongs. Often paired with Feature Envy.

---

### Move Field
**When**: A field is used more by another class than its owning class.

---

### Extract Class
**When**: One class does the work of two.

**Apply**: Create a new class; move the related fields and methods into it.

---

### Inline Class
**When**: A class isn't pulling its weight.

**Apply**: Move its features into another class; delete it.

---

### Hide Delegate
**When**: Client code calls a delegate method on a server class via direct attribute chains (`server.delegate.method()`).

**Apply**: Add a method on the server that delegates internally, hiding the chain. Reduces Message Chains.

---

### Remove Middle Man
**When**: A class is simply forwarding calls to another with no added value.

**Apply**: Have clients call the delegate directly.

---

## Organizing Data

Improve how data is represented and encapsulated.

### Self Encapsulate Field
**When**: Direct attribute access scattered throughout a class makes future changes hard.

**Apply**: Use `@property` to wrap access; useful before adding validation or computed values.

---

### Replace Data Value with Object
**When**: A primitive carries meaning beyond its type (e.g., `phone: str`, `status: str`).

**Apply**: Create a small class (or `Enum` for finite sets) to give the value identity.

---

### Replace Magic Number with Symbolic Constant
**When**: A literal number/string with special meaning appears in code.

**Example**:
```python
if response.status_code == 200:
    ...
```
→
```python
HTTP_OK = 200
if response.status_code == HTTP_OK:
    ...
```
Or use `http.HTTPStatus.OK` from the standard library.

---

### Encapsulate Field
**When**: A public field is being accessed directly from outside the class.

**Apply**: Make the field private (`_field`); expose via `@property`.

---

### Encapsulate Collection
**When**: A method returns the internal collection directly, allowing callers to mutate it.

**Apply**: Return a copy or read-only view (`tuple(...)`, `frozenset(...)`, `MappingProxyType(...)`).

---

### Replace Type Code with Class / Subclasses / State / Strategy
**When**: A class has a type/kind code (often a string or int) that controls behavior.

**Apply**: Replace with `Enum`, polymorphic subclasses, or State/Strategy pattern depending on complexity.

---

## Simplifying Conditional Expressions

Make branching logic easier to read.

### Decompose Conditional
**When**: A complex `if`-`else` block obscures intent.

**Apply**: Extract the condition, then-branch, and else-branch into well-named methods/functions.

---

### Consolidate Conditional Expression
**When**: Multiple separate conditional checks lead to the same result.

**Example**:
```python
if person.seniority < 2: return 0
if person.months_disabled > 12: return 0
if person.is_part_time: return 0
```
→
```python
def is_not_eligible_for_disability(person):
    return (person.seniority < 2
            or person.months_disabled > 12
            or person.is_part_time)
```

---

### Consolidate Duplicate Conditional Fragments
**When**: The same code appears in all branches of a conditional.

**Apply**: Move the duplicated code outside the conditional.

---

### Remove Control Flag
**When**: A boolean variable acts as a control flag for a series of conditionals.

**Apply**: Use `break`, `return`, or restructure to eliminate the flag.

---

### Replace Nested Conditional with Guard Clauses
**When**: Deeply nested conditionals obscure the main flow.

**Example**:
```python
def get_pay(employee):
    if employee.is_separated:
        result = separated_amount
    else:
        if employee.is_retired:
            result = retired_amount
        else:
            result = normal_pay_amount
    return result
```
→
```python
def get_pay(employee):
    if employee.is_separated:
        return separated_amount
    if employee.is_retired:
        return retired_amount
    return normal_pay_amount
```

---

### Replace Conditional with Polymorphism
**When**: Conditionals dispatch on a type field across multiple methods.

**Apply**: Create subclasses; let the runtime dispatch.

In Python, `functools.singledispatch` or `match`/`case` (3.10+) are lighter alternatives.

---

### Introduce Null Object
**When**: Many checks for `None` clutter the code.

**Apply**: Create a "null" instance with the same interface that does nothing harmful.

---

### Introduce Assertion
**When**: A piece of code assumes something must be true.

**Apply**: Make the assumption explicit with `assert` or a runtime check that raises a specific error.

> Note: `assert` is removed in optimized Python (`-O`); for production invariants, raise explicit exceptions.

---

## Simplifying Method Calls

Make method signatures easier to use.

### Rename Method
**When**: A method name doesn't reveal its purpose.

**Apply**: Rename it. Keep an alias temporarily if it's a public API.

---

### Add Parameter / Remove Parameter
**When**: A method needs additional information or a parameter is unused.

---

### Separate Query from Modifier
**When**: A method both returns a value and changes state.

**Apply**: Split into a pure query and a separate command. (Command-Query Separation)

---

### Parameterize Method
**When**: Several similar methods differ only by hard-coded values.

**Apply**: Replace with one method taking a parameter.

---

### Replace Parameter with Explicit Methods
**When**: A method has an enum-like parameter that switches behavior.

**Apply**: Create separate methods for each value.

---

### Preserve Whole Object
**When**: A caller extracts several values from an object only to pass them as separate arguments.

**Apply**: Pass the whole object instead.

---

### Replace Parameter with Method Call
**When**: A parameter value can be obtained by calling a method.

---

### Introduce Parameter Object
**When**: Several parameters always travel together (Data Clump).

**Apply**: Group them into a `dataclass` or `NamedTuple`.

---

### Hide Method
**When**: A method is not used by any other class.

**Apply**: Make it private (`_method` convention).

---

### Replace Constructor with Factory Method
**When**: Construction needs to do more than simple field assignment, or multiple construction paths exist.

**Apply**: Use `@classmethod` factories (e.g., `from_json`, `from_file`).

---

### Replace Error Code with Exception
**When**: A method returns a special error code (`-1`, `None`, `False`) instead of raising.

**Apply**: Raise a specific exception class; document it in the docstring.

---

### Replace Exception with Test
**When**: An exception is being thrown for a condition the caller could have checked.

**Apply**: Replace exception-driven logic with a precondition check (e.g., `if x is None: ...` before calling).

---

## Dealing with Generalization

Move features up/down the inheritance hierarchy or restructure relationships.

### Pull Up Field / Method
**When**: Subclasses share identical fields/methods.

**Apply**: Move them to the superclass.

---

### Push Down Field / Method
**When**: A field/method in the superclass is only used by some subclasses.

**Apply**: Move it down to the relevant subclass(es).

---

### Extract Subclass / Superclass / Interface
**When**: A class has features used only in some instances (subclass), or two classes share features (superclass), or you want to capture a contract (interface).

**Apply**:
- Subclass: split feature variants.
- Superclass: extract common parent.
- Interface: use `typing.Protocol` (structural) or `abc.ABC` (nominal) in Python.

---

### Collapse Hierarchy
**When**: A class hierarchy doesn't differ enough to justify itself.

**Apply**: Merge subclass into superclass (or vice versa).

---

### Form Template Method
**When**: Two methods in subclasses perform similar steps in the same order.

**Apply**: Extract the common skeleton into a superclass method that calls hook methods overridden by subclasses.

---

### Replace Inheritance with Delegation
**When**: A subclass uses only some features of its superclass, or inheritance creates Refused Bequest.

**Apply**: Replace `class Child(Parent)` with composition: `Child` holds a `Parent` instance and delegates needed calls.

> In Python, prefer composition over inheritance unless there's a true is-a relationship.

---

### Replace Delegation with Inheritance
**When**: A class delegates to another so much that it's clearly a subtype.

**Apply**: Make the delegate the parent class. (Use sparingly; the reverse refactoring is more common in good Python.)

---

## Refactoring Priority Heuristic

When recommending refactorings, prioritize in this order:

1. **Correctness fixes** — bugs, mutable defaults, race conditions
2. **Reduce duplication** — Extract Method, Form Template Method, Pull Up
3. **Simplify conditionals** — Guard Clauses, Polymorphism, Strategy
4. **Improve naming and signatures** — Rename, Introduce Parameter Object
5. **Reorganize hierarchies** — Move Method/Field, Extract Class
6. **Apply patterns** — only when the smell clearly calls for one

Always pair each recommendation with a concrete before/after, the affected location, and the rationale.
