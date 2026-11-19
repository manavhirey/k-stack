# Clean Code Examples (Python)

Concrete before/after examples illustrating Clean Code principles. Use these as templates when recommending refactorings during review.

---

## Naming

### Meaningful variable names

**Before**:
```python
def calc(d):
    r = []
    for i in d:
        if i[2] > 0:
            r.append(i)
    return r
```

**After**:
```python
def filter_positive_balances(transactions):
    return [tx for tx in transactions if tx.amount > 0]
```

**Why**: Names now reveal intent — the function's purpose, the data shape, and the filter criterion are obvious.

---

### Avoid mental mapping

**Before**:
```python
for u in users:
    for r in u.roles:
        if r.p:
            grant(u, r)
```

**After**:
```python
for user in users:
    for role in user.roles:
        if role.is_privileged:
            grant_access(user, role)
```

**Why**: Single-letter names force the reader to mentally translate; full words read like prose.

---

## Functions

### Single Responsibility

**Before** (function does too much):
```python
def process_order(order):
    total = 0
    for item in order.items:
        total += item.price * item.quantity
    if order.customer.is_premium:
        total *= 0.9
    print(f"Order total: {total}")
    db.save(order, total)
    send_email(order.customer.email, total)
    return total
```

**After**:
```python
def process_order(order):
    total = calculate_order_total(order)
    persist_order(order, total)
    notify_customer(order.customer, total)
    return total

def calculate_order_total(order):
    subtotal = sum(item.price * item.quantity for item in order.items)
    discount = PREMIUM_DISCOUNT if order.customer.is_premium else 1.0
    return subtotal * discount

def persist_order(order, total):
    db.save(order, total)

def notify_customer(customer, total):
    send_email(customer.email, f"Order total: {total}")
```

**Why**: Each function now has one reason to change. The orchestrator reads as a high-level summary.

---

### Replace nested conditionals with guard clauses

**Before**:
```python
def get_discount(customer):
    if customer is not None:
        if customer.is_active:
            if customer.years_loyal > 5:
                return 0.20
            else:
                return 0.10
        else:
            return 0.0
    else:
        return 0.0
```

**After**:
```python
def get_discount(customer):
    if customer is None or not customer.is_active:
        return 0.0
    if customer.years_loyal > 5:
        return LOYAL_CUSTOMER_DISCOUNT
    return STANDARD_DISCOUNT
```

**Why**: Guard clauses handle special cases up-front; the main path is unindented and clear.

---

## Magic Numbers

**Before**:
```python
def is_eligible(age, balance):
    return age >= 18 and balance >= 1000 and age < 65
```

**After**:
```python
MINIMUM_ELIGIBLE_AGE = 18
MAXIMUM_ELIGIBLE_AGE = 65
MINIMUM_BALANCE = 1000

def is_eligible(age, balance):
    return (MINIMUM_ELIGIBLE_AGE <= age < MAXIMUM_ELIGIBLE_AGE
            and balance >= MINIMUM_BALANCE)
```

**Why**: The numbers now have names that explain their meaning, and changes happen in one place.

---

## Comments

### Replace what-comments with self-documenting code

**Before**:
```python
x = a + b  # add a and b
y = x * 0.08  # calculate sales tax (8%)
total = x + y  # add tax to subtotal
```

**After**:
```python
SALES_TAX_RATE = 0.08

subtotal = a + b
tax = subtotal * SALES_TAX_RATE
total = subtotal + tax
```

**Why**: Names replace explanatory comments. Comments that explain *what* are usually a sign the code can be clearer.

---

### Keep comments that explain *why*

**Good**:
```python
# Stripe webhooks may retry within 5 minutes;
# dedupe by event_id to avoid double-processing payments.
if event.id in processed_events:
    return
```

**Why this is appropriate**: The reader can see *what* the code does; the comment explains the *non-obvious constraint* driving the design.

---

## Error Handling

### Specific exceptions with context

**Before**:
```python
def load_config(path):
    try:
        with open(path) as f:
            return json.load(f)
    except:
        return {}
```

**After**:
```python
class ConfigError(Exception):
    pass

def load_config(path: str) -> dict:
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError as e:
        raise ConfigError(f"Config file not found: {path}") from e
    except json.JSONDecodeError as e:
        raise ConfigError(f"Invalid JSON in {path}: {e.msg}") from e
```

**Why**: Specific exceptions enable callers to handle each case differently; bare `except` swallows bugs (e.g., `KeyboardInterrupt`).

---

## PEP 8 / Formatting

### Consistent style

**Before**:
```python
def foo( x,y, z=10 ):
    if(x>0):
       return x*y+z
    else: return 0
```

**After**:
```python
def foo(x, y, z=10):
    if x > 0:
        return x * y + z
    return 0
```

**Why**: PEP 8 spacing and `if/return` style make code consistent and tool-friendly. Run `ruff` or `black` to enforce automatically.

---

## Mutable Default Arguments (Python-specific)

**Before**:
```python
def add_item(item, items=[]):
    items.append(item)
    return items
```

**After**:
```python
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

**Why**: Default arguments are evaluated *once* at function definition. The mutable list is shared across calls, causing subtle bugs. Use `None` sentinel and create a fresh list inside.

---

## Type Hints on Public APIs

**Before**:
```python
def fetch_user(user_id):
    """Fetch a user from the database."""
    ...
```

**After**:
```python
from typing import Optional
from .models import User

def fetch_user(user_id: int) -> Optional[User]:
    """Fetch a user by ID; return None if not found."""
    ...
```

**Why**: Type hints document the contract, enable static analysis (`mypy`, `pyright`), and improve IDE support — without runtime cost.

---

## Replace Primitive with Object

**Before**:
```python
def send_email(to: str, subject: str, body: str):
    if "@" not in to:
        raise ValueError("invalid email")
    smtp.send(to, subject, body)
```

**After**:
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class EmailAddress:
    value: str

    def __post_init__(self):
        if "@" not in self.value:
            raise ValueError(f"Invalid email address: {self.value}")

def send_email(to: EmailAddress, subject: str, body: str):
    smtp.send(to.value, subject, body)
```

**Why**: `EmailAddress` validates once at construction; downstream code can trust the invariant. The type signature now communicates that an address — not just any string — is required.

---

## Quick-Win Checklist for Reviewers

When you see any of the following, suggest the corresponding fix immediately:

| Symptom | Fix |
|---|---|
| Single-letter variables outside iterators | Rename to descriptive name |
| Numbers in code (`200`, `0.08`, `60 * 60`) | Extract to module-level constant |
| Bare `except:` or `except Exception:` | Catch specific exceptions |
| `def f(x=[])` or `def f(x={})` | Use `None` sentinel |
| Functions >30 lines | Extract Method |
| `if/elif/elif/elif` on type | Polymorphism, `match`/`case`, or dict dispatch |
| Comments restating the code | Rename instead |
| Triple-nested `if` | Guard clauses |
| Repeated 3+ line block | Extract Method |
| Public function without type hints | Add type hints |
