# Code Smells Reference (Python)

Catalog of code smells from [refactoring.guru](https://refactoring.guru/refactoring/smells) adapted for Python review. Use this guide to identify problematic patterns and recommend remediations.

---

## Bloaters

Code, methods, and classes that have grown so large they're hard to work with.

### Long Method
**Symptom**: Function spans more than ~20 lines or does multiple things.

**Detect in Python**:
- Count logical sections separated by blank lines or comments
- Functions with many local variables
- Nested loops or deep conditionals (>3 levels)

**Refactor**: Extract Method, Replace Temp with Query, Decompose Conditional, Replace Method with Method Object.

---

### Large Class
**Symptom**: Class with many fields, methods, or lines of code (>200 lines or >15 public methods is a warning sign).

**Detect in Python**:
- Many `self.x = ...` assignments in `__init__`
- Mixed concerns (e.g., a class handling persistence, validation, AND business logic)

**Refactor**: Extract Class, Extract Subclass, Extract Interface (via `Protocol` / `ABC`).

---

### Primitive Obsession
**Symptom**: Using primitives (`str`, `int`, `dict`) where a small class would clarify intent.

**Detect in Python**:
- `dict` passed around with implicit schema (use `dataclass` or `TypedDict`)
- Strings carrying meaning (`status: str`) where `Enum` would be safer
- Tuples with positional meaning (use `NamedTuple` or `dataclass`)

**Refactor**: Replace Data Value with Object, Replace Type Code with Class, use `Enum` / `dataclass` / `pydantic`.

---

### Long Parameter List
**Symptom**: Function with more than 3-4 parameters.

**Detect in Python**:
- Many positional args
- Many `Optional[...]` parameters with `None` defaults
- Repeated parameter groups across functions (Data Clump)

**Refactor**: Introduce Parameter Object, Preserve Whole Object, Replace Parameter with Method Call. Use keyword-only args (`def f(*, a, b, c)`) or `dataclass` config.

---

### Data Clumps
**Symptom**: The same group of variables appears together in many places.

**Detect in Python**:
- `(start_x, start_y, end_x, end_y)` repeated in signatures → extract `Range` or `Rect`
- `(host, port, username, password)` repeated → extract `ConnectionConfig`

**Refactor**: Extract Class, Introduce Parameter Object.

---

## Object-Orientation Abusers

Incomplete or incorrect application of OO principles.

### Switch Statements / `if`-`elif` Chains on Type
**Symptom**: Long `if/elif` chains checking type or a "kind" field.

**Detect in Python**:
- `if isinstance(obj, X): ... elif isinstance(obj, Y):`
- `if shape.kind == "circle": ... elif shape.kind == "square":`

**Refactor**: Replace Conditional with Polymorphism, Replace Type Code with Subclasses, Replace Type Code with State/Strategy. In modern Python, `match`/`case` (3.10+) or `functools.singledispatch` may suffice.

---

### Temporary Field
**Symptom**: A field is only used in certain circumstances; otherwise empty/None.

**Detect in Python**: Attributes initialized to `None` and only set inside a specific method.

**Refactor**: Extract Class, Introduce Null Object.

---

### Refused Bequest
**Symptom**: A subclass uses only some inherited methods/properties; ignores or overrides the rest with no-ops.

**Detect in Python**: Subclass methods raise `NotImplementedError` or override parent with empty bodies.

**Refactor**: Push Down Method/Field; Replace Inheritance with Delegation. Often signals composition would fit better.

---

### Alternative Classes with Different Interfaces
**Symptom**: Two classes do similar things but expose different method names.

**Detect in Python**: Manual dispatch picking between similar classes.

**Refactor**: Rename Method, Move Method, Extract Superclass / `Protocol`.

---

## Change Preventers

Code structures where one change forces many others.

### Divergent Change
**Symptom**: One class is changed for many different reasons.

**Detect in Python**: A module/class touched repeatedly in unrelated commits.

**Refactor**: Extract Class — split by reason for change (SRP).

---

### Shotgun Surgery
**Symptom**: A single conceptual change requires edits in many classes/files.

**Detect in Python**: A bug fix or feature requires touching 5+ files for the same logical concern.

**Refactor**: Move Method, Move Field, Inline Class — consolidate the concern in one place.

---

### Parallel Inheritance Hierarchies
**Symptom**: Every time you create a subclass of A, you must also create a subclass of B.

**Detect in Python**: Mirror class hierarchies (`UserController` ↔ `UserView` ↔ `UserModel`).

**Refactor**: Move Method/Field to consolidate the parallel structure.

---

## Dispensables

Things whose absence would make code cleaner.

### Comments
**Symptom**: Comments explaining *what* the code does (rather than *why*).

**Detect in Python**:
- Comments restating the next line in English
- Outdated comments contradicting the code

**Refactor**: Extract Method (with a self-documenting name), Rename Variable, Introduce Assertion. Replace explanatory comments with clearer code; keep comments only for *why*, *constraints*, or *non-obvious context*.

---

### Duplicate Code
**Symptom**: The same code structure appears in multiple places.

**Detect in Python**: Copy-paste blocks; similar function bodies; repeated boilerplate.

**Refactor**: Extract Method, Extract Class, Form Template Method, Pull Up Method, Substitute Algorithm.

---

### Lazy Class
**Symptom**: A class doesn't do enough to justify its existence.

**Detect in Python**: A class with one method that's just called once. Often a leftover from refactoring.

**Refactor**: Inline Class, Collapse Hierarchy.

---

### Data Class
**Symptom**: A class consisting only of data fields and getters/setters with no behavior.

**Detect in Python**:
- `@dataclass` is fine for DTOs/value objects
- Smell: external code performs operations that *belong* to the data (Feature Envy)

**Refactor**: Move Method to bring behavior into the class. Encapsulate Field for true encapsulation needs.

---

### Dead Code
**Symptom**: Code that is no longer used.

**Detect in Python**: Unused imports, unreachable branches, commented-out blocks, unused functions/parameters.

**Refactor**: Delete it. Use tools like `vulture`, `ruff`, `pyflakes` to find dead code.

---

### Speculative Generality
**Symptom**: Abstractions, hooks, or parameters created for "future flexibility" that's never used.

**Detect in Python**: Unused abstract methods, single-implementation interfaces, configuration knobs nothing reads.

**Refactor**: Collapse Hierarchy, Inline Class, Remove Parameter, Rename Method.

---

## Couplers

Code structures that introduce excessive coupling between classes.

### Feature Envy
**Symptom**: A method in class A uses class B's data more than its own.

**Detect in Python**: Many `other.attr` references inside a method; calling many getters on another object.

**Refactor**: Move Method, Extract Method (then move).

---

### Inappropriate Intimacy
**Symptom**: Two classes know too much about each other's private parts.

**Detect in Python**: Reaching into `_private` attributes; circular imports; classes that always change together.

**Refactor**: Move Method/Field, Change Bidirectional Association to Unidirectional, Replace Inheritance with Delegation, Hide Delegate.

---

### Message Chains
**Symptom**: Long chains of method calls: `a.get_b().get_c().get_d().do_thing()`.

**Detect in Python**: Deep attribute access (`obj.x.y.z.method()`).

**Refactor**: Hide Delegate, Extract Method.

---

### Middle Man
**Symptom**: A class delegates almost everything to another, adding no real value.

**Detect in Python**: Classes whose methods are mostly `return self._other.method(...)`.

**Refactor**: Remove Middle Man, Inline Method, Replace Delegation with Inheritance.

---

## Python-Specific Smells

Beyond the classic catalog, watch for these Python-specific issues:

### Mutable Default Arguments
```python
def append_to(value, target=[]):  # BUG: shared across calls
    target.append(value)
    return target
```
**Fix**: Use `None` sentinel: `def append_to(value, target=None): target = target or []`.

---

### Bare `except:` or `except Exception:`
**Symptom**: Catching all exceptions, swallowing errors silently.

**Fix**: Catch specific exceptions; log unexpected ones; never silently `pass`.

---

### `from module import *`
**Symptom**: Pollutes namespace, hides origin of names.

**Fix**: Explicit imports; define `__all__` if star-import is required.

---

### Missing Type Hints on Public APIs
**Symptom**: Functions/methods at module/class boundaries lack type annotations.

**Fix**: Add type hints (PEP 484); use `mypy` / `pyright` in CI.

---

### God `__init__.py`
**Symptom**: Package `__init__.py` re-exports everything and grows uncontrollably.

**Fix**: Define `__all__` thoughtfully; let consumers import from submodules where appropriate.

---

### Overuse of `**kwargs`
**Symptom**: Functions accept `**kwargs` and silently ignore unknown keys, hiding API contract.

**Fix**: Use explicit keyword-only parameters or `TypedDict` for structured config.

---

### Class-level Mutable State
```python
class Cache:
    items = {}  # SHARED across all instances
```
**Fix**: Initialize per-instance state in `__init__`.

---

### Circular Imports
**Symptom**: Two modules import each other, causing `ImportError` or partial-init bugs.

**Fix**: Extract shared types to a third module; use `TYPE_CHECKING` for type-only imports; redesign module boundaries.

---

## Smell Severity Heuristic

| Severity | Examples |
|---|---|
| **Critical** | Mutable default args, bare `except`, dead `try` blocks, race conditions in shared state |
| **High** | Large Class with mixed concerns, Long Method >50 lines, Shotgun Surgery, Inappropriate Intimacy with private attrs |
| **Medium** | Long Method 20-50 lines, Long Parameter List, Duplicate Code, Primitive Obsession |
| **Low** | Naming improvements, missing type hints on internal helpers, Speculative Generality |
