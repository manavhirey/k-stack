# Design Pattern Examples (Python)

Idiomatic Python implementations of the most commonly recommended Gang of Four patterns. Use these as templates when suggesting a pattern in code review. For the full catalog and decision guidance, see [`../references/design-patterns.md`](../references/design-patterns.md).

> **Reviewer principle**: Apply patterns to solve problems already in the code — never preemptively. Many "patterns" are realized in Python with first-class functions, decorators, or generators rather than with classes.

---

## Factory Method

**Before** — `if/elif` ladder in constructor:
```python
class Notifier:
    def __init__(self, kind: str):
        if kind == "email":
            self.client = SmtpClient()
        elif kind == "sms":
            self.client = TwilioClient()
        elif kind == "push":
            self.client = ApnsClient()
        else:
            raise ValueError(kind)
```

**After** — factory method per subclass:
```python
from abc import ABC, abstractmethod

class Notifier(ABC):
    @abstractmethod
    def send(self, message: str) -> None: ...

class EmailNotifier(Notifier):
    def send(self, message): SmtpClient().send(message)

class SmsNotifier(Notifier):
    def send(self, message): TwilioClient().send(message)

class PushNotifier(Notifier):
    def send(self, message): ApnsClient().send(message)

NOTIFIERS = {
    "email": EmailNotifier,
    "sms": SmsNotifier,
    "push": PushNotifier,
}

def create_notifier(kind: str) -> Notifier:
    if kind not in NOTIFIERS:
        raise ValueError(f"Unknown notifier: {kind}")
    return NOTIFIERS[kind]()
```

---

## Builder

**Before** — telescoping constructor:
```python
class HttpRequest:
    def __init__(self, url, method="GET", headers=None, body=None,
                 timeout=30, retries=0, follow_redirects=True, auth=None):
        ...
```

**After** — fluent builder:
```python
class HttpRequestBuilder:
    def __init__(self, url: str):
        self._url = url
        self._method = "GET"
        self._headers: dict[str, str] = {}
        self._body: bytes | None = None
        self._timeout = 30
        self._retries = 0
        self._auth = None

    def method(self, method): self._method = method; return self
    def header(self, key, value): self._headers[key] = value; return self
    def body(self, body): self._body = body; return self
    def timeout(self, seconds): self._timeout = seconds; return self
    def retries(self, n): self._retries = n; return self
    def auth(self, auth): self._auth = auth; return self

    def build(self) -> HttpRequest:
        return HttpRequest(self._url, self._method, dict(self._headers),
                           self._body, self._timeout, self._retries, self._auth)

req = (HttpRequestBuilder("https://api.example.com/users")
       .method("POST")
       .header("Content-Type", "application/json")
       .body(b'{"name": "Alice"}')
       .timeout(60)
       .build())
```

> **Pythonic alternative**: `@dataclass` with field defaults often replaces simple builders.

---

## Singleton

**Pythonic preferred** — module-level singleton:
```python
class _Config:
    debug: bool = False
    db_url: str = ""

config = _Config()  # import this; modules are singletons
```

**When you must enforce at the class level**:
```python
class Database:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

> **Reviewer caution**: Singletons hide global state. Prefer dependency injection unless the singleton represents a true unique resource.

---

## Adapter

**Before** — third-party API doesn't match expected interface:
```python
class LegacyXmlPaymentClient:
    def make_payment(self, xml_payload: str) -> str: ...

def process(client, amount, account):
    if isinstance(client, LegacyXmlPaymentClient):
        xml = f"<payment><amount>{amount}</amount><account>{account}</account></payment>"
        return client.make_payment(xml)
    else:
        return client.charge(account, amount)  # different interface
```

**After** — adapter unifies the interface:
```python
class PaymentGateway(Protocol):
    def charge(self, account: str, amount: float) -> Receipt: ...

class LegacyXmlPaymentAdapter:
    def __init__(self, legacy: LegacyXmlPaymentClient):
        self._legacy = legacy

    def charge(self, account: str, amount: float) -> Receipt:
        xml = f"<payment><amount>{amount}</amount><account>{account}</account></payment>"
        response_xml = self._legacy.make_payment(xml)
        return parse_xml_receipt(response_xml)

def process(gateway: PaymentGateway, amount: float, account: str) -> Receipt:
    return gateway.charge(account, amount)
```

---

## Decorator (structural)

**Before** — manual logging/caching mixed with business logic:
```python
class DataService:
    def fetch(self, key):
        print(f"Fetching {key}")
        result = expensive_call(key)
        print(f"Got {result}")
        return result
```

**After** — decorators stack independently:
```python
class DataServiceProtocol(Protocol):
    def fetch(self, key: str) -> Any: ...

class DataService:
    def fetch(self, key):
        return expensive_call(key)

class LoggingDataService:
    def __init__(self, wrapped: DataServiceProtocol, logger):
        self._wrapped = wrapped
        self._log = logger

    def fetch(self, key):
        self._log.info("fetching %s", key)
        result = self._wrapped.fetch(key)
        self._log.info("got %s for %s", result, key)
        return result

class CachingDataService:
    def __init__(self, wrapped: DataServiceProtocol):
        self._wrapped = wrapped
        self._cache = {}

    def fetch(self, key):
        if key not in self._cache:
            self._cache[key] = self._wrapped.fetch(key)
        return self._cache[key]

service = LoggingDataService(CachingDataService(DataService()), logger)
```

> **Pythonic alternative**: Function decorators (`@functools.lru_cache`, `@log_calls`) handle simple cross-cutting concerns elegantly.

---

## Strategy

**Before** — algorithm chosen via conditional:
```python
def sort_users(users, by):
    if by == "name":
        return sorted(users, key=lambda u: u.name)
    elif by == "age":
        return sorted(users, key=lambda u: u.age)
    elif by == "join_date":
        return sorted(users, key=lambda u: u.join_date)
```

**Pythonic strategy** — first-class functions:
```python
SORT_STRATEGIES = {
    "name": lambda u: u.name,
    "age": lambda u: u.age,
    "join_date": lambda u: u.join_date,
}

def sort_users(users, by: str):
    return sorted(users, key=SORT_STRATEGIES[by])
```

**Class-based strategy** (when strategies are stateful):
```python
class CompressionStrategy(Protocol):
    def compress(self, data: bytes) -> bytes: ...

class GzipStrategy:
    def compress(self, data): return gzip.compress(data)

class ZstdStrategy:
    def __init__(self, level: int = 3):
        self.level = level
    def compress(self, data):
        return zstandard.ZstdCompressor(level=self.level).compress(data)

class Archiver:
    def __init__(self, strategy: CompressionStrategy):
        self._strategy = strategy
    def archive(self, data: bytes) -> bytes:
        return self._strategy.compress(data)
```

---

## Observer

```python
from typing import Callable

class EventBus:
    def __init__(self):
        self._subscribers: dict[str, list[Callable]] = {}

    def subscribe(self, event: str, handler: Callable) -> None:
        self._subscribers.setdefault(event, []).append(handler)

    def unsubscribe(self, event: str, handler: Callable) -> None:
        self._subscribers.get(event, []).remove(handler)

    def publish(self, event: str, **payload) -> None:
        for handler in self._subscribers.get(event, []):
            handler(**payload)

bus = EventBus()
bus.subscribe("order_placed", lambda order: send_confirmation(order))
bus.subscribe("order_placed", lambda order: update_inventory(order))
bus.publish("order_placed", order=order)
```

> **Production**: `blinker`, framework signals (Django, Flask), or async event loops are typical.

---

## State

**Before** — `if` ladders on a state field across many methods:
```python
class Order:
    def __init__(self):
        self.state = "draft"

    def submit(self):
        if self.state == "draft":
            self.state = "submitted"
        elif self.state == "submitted":
            raise InvalidTransition()
        # ... etc

    def cancel(self):
        if self.state == "draft":
            self.state = "cancelled"
        elif self.state == "submitted":
            self.state = "cancelled"
        elif self.state == "shipped":
            raise InvalidTransition()
```

**After** — each state is a class:
```python
class OrderState(Protocol):
    def submit(self, order: "Order") -> None: ...
    def cancel(self, order: "Order") -> None: ...

class Draft:
    def submit(self, order): order._state = Submitted()
    def cancel(self, order): order._state = Cancelled()

class Submitted:
    def submit(self, order): raise InvalidTransition()
    def cancel(self, order): order._state = Cancelled()

class Shipped:
    def submit(self, order): raise InvalidTransition()
    def cancel(self, order): raise InvalidTransition()

class Cancelled:
    def submit(self, order): raise InvalidTransition()
    def cancel(self, order): pass

class Order:
    def __init__(self):
        self._state: OrderState = Draft()

    def submit(self): self._state.submit(self)
    def cancel(self): self._state.cancel(self)
```

---

## Template Method

```python
from abc import ABC, abstractmethod

class DataPipeline(ABC):
    def run(self, source: str) -> None:
        raw = self._extract(source)
        processed = self._transform(raw)
        self._load(processed)

    @abstractmethod
    def _extract(self, source: str) -> Any: ...

    @abstractmethod
    def _transform(self, data: Any) -> Any: ...

    @abstractmethod
    def _load(self, data: Any) -> None: ...

class CsvToParquetPipeline(DataPipeline):
    def _extract(self, source): return pd.read_csv(source)
    def _transform(self, data): return data.dropna()
    def _load(self, data): data.to_parquet("output.parquet")
```

---

## Chain of Responsibility

```python
from typing import Protocol, Optional

class Handler(Protocol):
    def handle(self, request: dict) -> Optional[Response]: ...

class AuthHandler:
    def __init__(self, next_handler: Handler):
        self._next = next_handler

    def handle(self, request):
        if not request.get("token"):
            return Response(401, "Unauthorized")
        return self._next.handle(request)

class RateLimitHandler:
    def __init__(self, next_handler: Handler):
        self._next = next_handler

    def handle(self, request):
        if rate_limit_exceeded(request):
            return Response(429, "Too Many Requests")
        return self._next.handle(request)

class BusinessHandler:
    def handle(self, request):
        return Response(200, process(request))

pipeline = AuthHandler(RateLimitHandler(BusinessHandler()))
response = pipeline.handle({"token": "abc", ...})
```

> Frameworks (Django/Flask middleware, ASGI) realize this pattern natively.

---

## Command

```python
from abc import ABC, abstractmethod

class Command(ABC):
    @abstractmethod
    def execute(self) -> None: ...

    @abstractmethod
    def undo(self) -> None: ...

class AddItemCommand(Command):
    def __init__(self, cart, item):
        self._cart = cart
        self._item = item

    def execute(self): self._cart.add(self._item)
    def undo(self): self._cart.remove(self._item)

class CommandHistory:
    def __init__(self):
        self._history: list[Command] = []

    def execute(self, command: Command) -> None:
        command.execute()
        self._history.append(command)

    def undo_last(self) -> None:
        if self._history:
            self._history.pop().undo()
```

---

## Visitor (and the Pythonic alternative)

**Classic visitor**:
```python
class Node(ABC):
    @abstractmethod
    def accept(self, visitor: "Visitor"): ...

class NumberNode(Node):
    def __init__(self, value): self.value = value
    def accept(self, visitor): return visitor.visit_number(self)

class AddNode(Node):
    def __init__(self, left, right): self.left, self.right = left, right
    def accept(self, visitor): return visitor.visit_add(self)

class EvalVisitor:
    def visit_number(self, node): return node.value
    def visit_add(self, node): return node.left.accept(self) + node.right.accept(self)
```

**Pythonic alternative** — `functools.singledispatch`:
```python
from dataclasses import dataclass
from functools import singledispatch

@dataclass
class NumberNode: value: int

@dataclass
class AddNode: left: object; right: object

@singledispatch
def evaluate(node) -> int:
    raise NotImplementedError(type(node))

@evaluate.register
def _(node: NumberNode): return node.value

@evaluate.register
def _(node: AddNode): return evaluate(node.left) + evaluate(node.right)
```

> Modern Python (3.10+) `match`/`case` is often the cleanest option for AST-style traversal.

---

## Pattern Selection Guide for Reviewers

When recommending a pattern in review, accompany it with:

1. **The smell that motivates it** — e.g., "long `if/elif` on `kind` field"
2. **The pattern name and a one-line intent**
3. **A before/after example** referencing the user's own code
4. **A note on Pythonic alternatives** (functions, dataclasses, generators) that may be lighter

Avoid:
- Recommending Singleton without considering module-level state
- Adding `Visitor` when `singledispatch` or `match`/`case` suffices
- Heavy class hierarchies for behaviors that first-class functions handle naturally
