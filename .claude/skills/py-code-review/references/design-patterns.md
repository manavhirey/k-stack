# Design Patterns Reference (Python)

Catalog of the Gang of Four design patterns adapted for Python, sourced from [refactoring.guru/design-patterns/python](https://refactoring.guru/design-patterns/python). Use this reference during code review to recognize when a pattern would simplify code or when an existing implementation deviates from the canonical form.

> **Reviewer guidance**: Recommend a pattern only when the code already exhibits the problem it solves. Premature pattern adoption is itself a code smell ("Speculative Generality").

---

## Creational Patterns

These patterns deal with object creation mechanisms.

### Factory Method
**Intent**: Provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created.

**When to suggest**: A class can't anticipate which class of objects it must create, or when subclasses need to specify the objects they create.

**Python idiom**: Often realized via a `@classmethod` factory or polymorphic `create()` method on a base class.

**Smell it replaces**: Long `if/elif` chains over a "type" string in a constructor.

---

### Abstract Factory
**Intent**: Lets you produce families of related objects without specifying their concrete classes.

**When to suggest**: Code needs to work with multiple variants of related products (e.g., GUI toolkits for different OSes, DB drivers for different engines).

**Python idiom**: Use `abc.ABC` for the abstract factory; concrete factories return matching product families.

**Smell it replaces**: Tight coupling to specific product classes scattered across the codebase.

---

### Builder
**Intent**: Lets you construct complex objects step by step. The pattern allows you to produce different types and representations of an object using the same construction code.

**When to suggest**: Constructors with many optional parameters (telescoping constructors), or objects requiring multi-step initialization.

**Python idiom**: Fluent builder class returning `self` from each method; alternatively use `@dataclass` with `field(default=...)` if construction is simple.

**Smell it replaces**: Long Parameter List, Primitive Obsession in constructor.

---

### Prototype
**Intent**: Lets you copy existing objects without making your code dependent on their classes.

**When to suggest**: Object creation is expensive or complex, but copying an existing instance is cheap.

**Python idiom**: Use `copy.copy()` / `copy.deepcopy()`, or implement `__copy__` / `__deepcopy__` for custom semantics.

**Reviewer note**: In Python, `copy.deepcopy` already implements this pattern — flag custom implementations only when the standard library is insufficient.

---

### Singleton
**Intent**: Ensures a class has only one instance and provides a global access point to it.

**When to suggest**: Truly unique resources (e.g., configuration, logger, hardware interface).

**Python idiom**:
- Module-level singleton (preferred — modules are already singletons in Python)
- Metaclass-based singleton for class-level enforcement
- `__new__` override for thread-safety

**Reviewer caution**: Singletons often hide global state and complicate testing. Prefer dependency injection where possible. Flag overuse.

---

## Structural Patterns

These patterns deal with object composition.

### Adapter
**Intent**: Allows objects with incompatible interfaces to collaborate.

**When to suggest**: Wrapping a third-party library or legacy class to match the expected interface used elsewhere.

**Python idiom**: A wrapper class that translates calls; duck typing often makes adapters lighter than in statically typed languages.

**Smell it replaces**: `if isinstance(...)` branching to handle different shapes of input.

---

### Bridge
**Intent**: Lets you split a large class or a set of closely related classes into two separate hierarchies — abstraction and implementation — which can be developed independently.

**When to suggest**: A class has multiple orthogonal axes of variation (e.g., shape × renderer, message × transport).

**Python idiom**: Composition where the abstraction holds a reference to an implementation interface.

**Smell it replaces**: Combinatorial explosion of subclasses (`SquareSvgRenderer`, `CircleSvgRenderer`, `SquarePngRenderer`, ...).

---

### Composite
**Intent**: Lets you compose objects into tree structures and then work with these structures as if they were individual objects.

**When to suggest**: Hierarchical data where leaves and containers should be treated uniformly (file system, UI components, expression trees).

**Python idiom**: Common base class with `add(child)`, `remove(child)`, and operation methods that recurse.

---

### Decorator
**Intent**: Lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors.

**When to suggest**: Adding cross-cutting concerns (logging, caching, validation) without modifying the original class.

**Python idiom**:
- Function decorators (`@functools.wraps`) for simple cases
- Class decorators wrapping object methods for stateful concerns
- `functools.lru_cache`, `contextlib.contextmanager` are decorator patterns

**Reviewer note**: Distinguish Python's `@decorator` syntax (which can implement this pattern) from the structural Decorator pattern itself.

---

### Facade
**Intent**: Provides a simplified interface to a library, a framework, or any other complex set of classes.

**When to suggest**: Client code reaches deep into a complex subsystem; many imports from internal modules.

**Python idiom**: A module's `__init__.py` re-exporting a clean public API; a high-level class that orchestrates lower-level components.

**Smell it replaces**: Message Chains, Inappropriate Intimacy.

---

### Flyweight
**Intent**: Lets you fit more objects into the available amount of RAM by sharing common parts of state between multiple objects instead of keeping all of the data in each object.

**When to suggest**: Memory pressure from many similar objects (game entities, text glyphs, parser tokens).

**Python idiom**: `__slots__` to reduce per-instance memory; interning via dict cache; `sys.intern()` for strings.

**Reviewer caution**: Premature flyweight optimization is a smell. Recommend only with profiling evidence.

---

### Proxy
**Intent**: Lets you provide a substitute or placeholder for another object. A proxy controls access to the original object, allowing you to perform something either before or after the request gets through to the original object.

**When to suggest**:
- Lazy loading (Virtual Proxy)
- Access control (Protection Proxy)
- Logging/monitoring (Logging Proxy)
- Caching (Caching Proxy)
- Remote calls (Remote Proxy)

**Python idiom**: Override `__getattr__` for transparent forwarding; use `weakref.proxy` for weak references.

---

## Behavioral Patterns

These patterns deal with object collaboration and responsibility distribution.

### Chain of Responsibility
**Intent**: Lets you pass requests along a chain of handlers. Upon receiving a request, each handler decides either to process the request or to pass it to the next handler.

**When to suggest**: Sequential processing where multiple handlers may apply (request middleware, validation pipelines, event handlers).

**Python idiom**: A list of callables, or a linked list of handler instances each holding a `next` reference. Frameworks like Django middleware use this.

**Smell it replaces**: Long `if/elif` chains dispatching by request type.

---

### Command
**Intent**: Turns a request into a stand-alone object that contains all information about the request. This transformation lets you pass requests as method arguments, delay or queue a request's execution, and support undoable operations.

**When to suggest**: Undo/redo, task queues, macro recording, deferred execution.

**Python idiom**: Callable classes (`__call__`) or `functools.partial`; for undo, pair `execute()` with `undo()` methods.

---

### Iterator
**Intent**: Lets you traverse elements of a collection without exposing its underlying representation.

**When to suggest**: Custom traversal logic, especially for non-sequential structures (trees, graphs, infinite streams).

**Python idiom**: Built-in via `__iter__` / `__next__` or generator functions (`yield`). Most Python iteration uses this pattern natively.

**Reviewer note**: Encourage generators (`yield`) over manual `__iter__` / `__next__` implementations.

---

### Mediator
**Intent**: Lets you reduce chaotic dependencies between objects. The pattern restricts direct communications between the objects and forces them to collaborate only via a mediator object.

**When to suggest**: Many-to-many object communication leading to tight coupling (UI dialog with many widgets, chat room with users).

**Python idiom**: A central class holding references to colleagues; colleagues notify the mediator instead of each other.

**Smell it replaces**: Inappropriate Intimacy among many classes.

---

### Memento
**Intent**: Lets you save and restore the previous state of an object without revealing the details of its implementation.

**When to suggest**: Undo functionality, snapshots, time-travel debugging.

**Python idiom**: Use `copy.deepcopy()` for simple cases; dataclass `replace()` for structured records; `pickle` for serialization.

---

### Observer
**Intent**: Lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they're observing.

**When to suggest**: Event-driven code, model-view separation, pub/sub messaging.

**Python idiom**: Subject holds list of observer callables; observers register/unregister. Libraries: `blinker`, `PyDispatcher`, framework signals (Django signals).

**Smell it replaces**: Tight coupling between data sources and consumers.

---

### State
**Intent**: Lets an object alter its behavior when its internal state changes. It appears as if the object changed its class.

**When to suggest**: Object behavior depends heavily on a state field, leading to large conditionals scattered across methods (e.g., order workflow, document lifecycle).

**Python idiom**: Each state is a class implementing the same interface; the context delegates to the current state object and allows transitions.

**Smell it replaces**: Switch Statements on a state enum throughout multiple methods.

---

### Strategy
**Intent**: Lets you define a family of algorithms, put each of them into a separate class, and make their objects interchangeable.

**When to suggest**: Multiple algorithms achieve the same goal (sort comparators, payment methods, compression algorithms).

**Python idiom**: Pass functions as first-class objects (Python's natural form); for stateful strategies, use classes with a common interface.

**Smell it replaces**: Conditional logic selecting an algorithm.

---

### Template Method
**Intent**: Defines the skeleton of an algorithm in the superclass but lets subclasses override specific steps of the algorithm without changing its structure.

**When to suggest**: Multiple classes share an algorithm structure but differ in specific steps (data parsers, training loops, request handlers).

**Python idiom**: Base class with a public method defining the algorithm and protected (`_method`) hooks for subclasses to override.

**Reviewer note**: Prefer composition (Strategy) over inheritance (Template Method) when the variation is significant or runtime-selectable.

---

### Visitor
**Intent**: Lets you separate algorithms from the objects on which they operate.

**When to suggest**: Adding new operations to a stable class hierarchy without modifying the classes themselves (AST traversal, document processing).

**Python idiom**: Use `functools.singledispatch` for type-based dispatch; classical visitor with `accept(visitor)` / `visit_X(node)` methods otherwise.

**Reviewer note**: Python's dynamic nature often makes Visitor unnecessary; prefer simple pattern matching (`match`/`case` in 3.10+) for AST-like work.

---

## Pattern Recognition Cheat Sheet

| Symptom in Code | Consider Pattern |
|---|---|
| Many `if/elif` on a type/state field | Strategy, State, Polymorphism |
| Constructor with many optional params | Builder |
| Tight coupling to concrete external classes | Adapter, Facade, DIP |
| Tree-like data structures | Composite |
| Cross-cutting concerns (logging, caching) | Decorator |
| Many objects with shared state | Flyweight |
| Need for undo/redo | Command, Memento |
| Event-driven coupling | Observer |
| Lazy/expensive resource access | Proxy |
| Complex object cloning | Prototype (or `copy.deepcopy`) |
| Algorithm with variable steps | Template Method, Strategy |
| Operations to add to stable hierarchy | Visitor (or `singledispatch`) |
| Many-to-many object chatter | Mediator |
| Sequential conditional handlers | Chain of Responsibility |

## Anti-Patterns to Flag

- **Singleton overuse** hiding global state
- **Pattern fever** — applying patterns where simple Python features (functions, dataclasses, generators) would suffice
- **Java-style abstract factories** when a simple factory function would do
- **Visitor with `isinstance` chains** instead of `singledispatch` or `match`/`case`
- **Classical Strategy classes** when first-class functions or `lambda` are clearer
