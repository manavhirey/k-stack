# SOLID Principle Examples (Python)

Concrete violations and corresponding refactorings for each SOLID principle. Use these as templates when explaining issues during code review.

---

## Single Responsibility Principle (SRP)

> A class should have only one reason to change.

### Violation: Class with mixed responsibilities

**Before**:
```python
class Report:
    def __init__(self, data):
        self.data = data

    def calculate_totals(self):
        return sum(row.amount for row in self.data)

    def render_html(self):
        rows = "".join(f"<tr><td>{r.name}</td><td>{r.amount}</td></tr>" for r in self.data)
        return f"<table>{rows}</table>"

    def save_to_disk(self, path):
        with open(path, "w") as f:
            f.write(self.render_html())

    def email_to(self, recipient):
        smtp.send(recipient, subject="Report", body=self.render_html())
```

The `Report` class has **four reasons to change**: calculation logic, HTML format, file I/O, and email transport.

**After**:
```python
class Report:
    def __init__(self, data):
        self.data = data

    def total(self):
        return sum(row.amount for row in self.data)


class HtmlReportRenderer:
    def render(self, report: Report) -> str:
        rows = "".join(f"<tr><td>{r.name}</td><td>{r.amount}</td></tr>" for r in report.data)
        return f"<table>{rows}</table>"


class ReportFileWriter:
    def write(self, content: str, path: str) -> None:
        with open(path, "w") as f:
            f.write(content)


class ReportEmailer:
    def __init__(self, smtp_client):
        self._smtp = smtp_client

    def send(self, content: str, recipient: str) -> None:
        self._smtp.send(recipient, subject="Report", body=content)
```

**Why**: Each class has one reason to change. You can change the email format without touching file I/O.

---

## Open/Closed Principle (OCP)

> Entities should be open for extension, closed for modification.

### Violation: Adding a new payment type requires modifying existing code

**Before**:
```python
def charge(payment_type: str, amount: float, account: str):
    if payment_type == "credit_card":
        return stripe.charge(account, amount)
    elif payment_type == "paypal":
        return paypal.send_payment(account, amount)
    elif payment_type == "bank_transfer":
        return bank.transfer(account, amount)
    else:
        raise ValueError(f"Unknown payment type: {payment_type}")
```

Every new payment method forces editing this function.

**After**:
```python
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    @abstractmethod
    def charge(self, amount: float, account: str) -> Receipt: ...

class CreditCardPayment(PaymentMethod):
    def charge(self, amount, account):
        return stripe.charge(account, amount)

class PayPalPayment(PaymentMethod):
    def charge(self, amount, account):
        return paypal.send_payment(account, amount)

class BankTransferPayment(PaymentMethod):
    def charge(self, amount, account):
        return bank.transfer(account, amount)

def process_payment(method: PaymentMethod, amount: float, account: str) -> Receipt:
    return method.charge(amount, account)
```

**Why**: New payment types are added by *creating* a new class, not modifying existing code. Existing tests stay green.

> **Pythonic alternative**: A registry of callables works without subclassing.
> ```python
> PAYMENTS = {"credit_card": stripe.charge, "paypal": paypal.send_payment, ...}
> def charge(method, amount, account): return PAYMENTS[method](account, amount)
> ```

---

## Liskov Substitution Principle (LSP)

> Subclasses must be substitutable for their base classes without breaking correctness.

### Violation: Subclass strengthens preconditions / breaks invariants

**Before** (the classic Rectangle/Square problem):
```python
class Rectangle:
    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height

    def area(self) -> int:
        return self.width * self.height


class Square(Rectangle):
    def __init__(self, side: int):
        super().__init__(side, side)

    @Rectangle.width.setter
    def width(self, value):
        self._width = value
        self._height = value  # forces height to match — surprises callers
```

A function `def double_width(rect: Rectangle): rect.width *= 2` works for `Rectangle` but produces wrong area for `Square`.

**After**: Don't model "Square is-a Rectangle" with inheritance. Either use composition or define a common abstraction:
```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> float: ...

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    def area(self):
        return self.width * self.height

class Square(Shape):
    def __init__(self, side):
        self.side = side
    def area(self):
        return self.side * self.side
```

**Why**: Inheritance models behavioral substitutability — not vocabulary similarity. If a subclass would break callers' expectations, prefer a sibling type.

---

### Violation: Subclass narrows return types or throws unexpected exceptions

**Before**:
```python
class Repository:
    def find(self, id: int) -> Item: ...

class CachedRepository(Repository):
    def find(self, id: int) -> Item:
        if id not in self._cache:
            raise CacheMiss()  # parent never throws this
        return self._cache[id]
```

**Fix**: Either match the parent contract (fall back to source) or expose a different method (`find_cached`).

---

## Interface Segregation Principle (ISP)

> Clients should not be forced to depend on methods they do not use.

### Violation: Fat interface

**Before**:
```python
class Worker(ABC):
    @abstractmethod
    def work(self): ...
    @abstractmethod
    def eat(self): ...
    @abstractmethod
    def sleep(self): ...

class HumanWorker(Worker):
    def work(self): ...
    def eat(self): ...
    def sleep(self): ...

class RobotWorker(Worker):
    def work(self): ...
    def eat(self): raise NotImplementedError  # smell: Refused Bequest
    def sleep(self): raise NotImplementedError
```

**After** — split the interface:
```python
from typing import Protocol

class Workable(Protocol):
    def work(self) -> None: ...

class Eatable(Protocol):
    def eat(self) -> None: ...

class Sleepable(Protocol):
    def sleep(self) -> None: ...

class HumanWorker:
    def work(self): ...
    def eat(self): ...
    def sleep(self): ...

class RobotWorker:
    def work(self): ...
```

**Why**: `RobotWorker` no longer depends on `eat`/`sleep` it can't implement. Functions that need only `work` accept `Workable`.

> Python `Protocol` (PEP 544) gives **structural** typing — duck typing with type-checker support — and is often more idiomatic than `ABC` for ISP-style segregation.

---

## Dependency Inversion Principle (DIP)

> Depend on abstractions, not concretions. High-level modules should not depend on low-level modules.

### Violation: High-level logic depends on a concrete database driver

**Before**:
```python
import psycopg2

class OrderService:
    def __init__(self):
        self.conn = psycopg2.connect("...")

    def place_order(self, order):
        cursor = self.conn.cursor()
        cursor.execute("INSERT INTO orders ...", order)
        self.conn.commit()
```

`OrderService` is welded to PostgreSQL — can't unit test, can't swap to a different store.

**After**:
```python
from typing import Protocol

class OrderRepository(Protocol):
    def save(self, order: Order) -> None: ...

class PostgresOrderRepository:
    def __init__(self, conn):
        self._conn = conn
    def save(self, order):
        cursor = self._conn.cursor()
        cursor.execute("INSERT INTO orders ...", order)
        self._conn.commit()

class InMemoryOrderRepository:
    def __init__(self):
        self.orders = []
    def save(self, order):
        self.orders.append(order)

class OrderService:
    def __init__(self, repo: OrderRepository):
        self._repo = repo

    def place_order(self, order: Order) -> None:
        self._repo.save(order)
```

**Why**:
- `OrderService` now depends on the *abstraction* (`OrderRepository`).
- Production wires up `PostgresOrderRepository`; tests use `InMemoryOrderRepository`.
- Swapping storage doesn't touch business logic.

---

### Pythonic shortcut: callables as dependencies

For lightweight DIP, you can inject *functions* instead of objects:

**Before**:
```python
class ReportSender:
    def send(self, content):
        smtp.send("ops@example.com", "Report", content)
```

**After**:
```python
from typing import Callable

class ReportSender:
    def __init__(self, send_fn: Callable[[str, str, str], None]):
        self._send = send_fn

    def send(self, content: str) -> None:
        self._send("ops@example.com", "Report", content)
```

**Why**: A function reference is the lightest abstraction. In tests, pass a stub: `sender = ReportSender(send_fn=lambda *args: captured.append(args))`.

---

## SOLID Review Heuristics

When reviewing, look for these tell-tale signs:

| Signal | Likely Violation | Suggested Refactoring |
|---|---|---|
| Class has 4+ public methods touching different domains | SRP | Extract Class |
| `if/elif` ladder over a "kind" or "type" field | OCP | Strategy / Polymorphism |
| Subclass overrides parent method to raise `NotImplementedError` | LSP, ISP | Replace Inheritance with Delegation, split interface |
| Subclass changes pre/postconditions of parent method | LSP | Don't subclass; use sibling type |
| Class implements interface with several no-op methods | ISP | Split interface (`Protocol`s) |
| Class instantiates concrete dependency in `__init__` | DIP | Constructor injection |
| Hard-coded import of a third-party SDK in business logic | DIP | Wrap in adapter, inject |
| Test cannot run without DB/network/filesystem | DIP | Repository / Gateway pattern |

Always pair the violation with a concrete refactoring suggestion and explain *why* the change improves testability, maintainability, or extensibility.
