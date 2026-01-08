---
name: python-testing-patterns
displayName: "Python Testing Patterns"
category: python-development
tier: 3
model: model_2
triggers:
  - "pytest"
  - "python test"
  - "unittest"
  - "mock python"
  - "fixture"
---

# Python Testing Patterns

> Implement comprehensive testing with pytest.

## Project Structure

```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── users/
│       │   ├── service.py
│       │   └── repository.py
│       └── config.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Shared fixtures
│   ├── unit/
│   │   └── test_users.py
│   ├── integration/
│   │   └── test_api.py
│   └── e2e/
│       └── test_flows.py
├── pytest.ini
└── pyproject.toml
```

## pytest Configuration

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
python_classes = Test*
addopts = -v --tb=short --strict-markers
markers =
    slow: marks tests as slow
    integration: integration tests
    e2e: end-to-end tests
filterwarnings =
    ignore::DeprecationWarning
```

```toml
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"

[tool.coverage.run]
source = ["src"]
branch = true
omit = ["*/tests/*", "*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
fail_under = 80
```

## Basic Tests

```python
# tests/unit/test_users.py
import pytest
from myapp.users.service import UserService

class TestUserService:
    """Test suite for UserService."""

    def test_create_user_success(self):
        """Should create user with valid data."""
        # Arrange
        service = UserService()
        data = {"name": "John", "email": "john@example.com"}

        # Act
        user = service.create(data)

        # Assert
        assert user.name == "John"
        assert user.email == "john@example.com"
        assert user.id is not None

    def test_create_user_invalid_email(self):
        """Should raise error for invalid email."""
        service = UserService()
        data = {"name": "John", "email": "invalid"}

        with pytest.raises(ValueError, match="Invalid email"):
            service.create(data)

    @pytest.mark.parametrize("email,expected", [
        ("user@example.com", True),
        ("user@sub.example.com", True),
        ("invalid", False),
        ("", False),
        (None, False),
    ])
    def test_validate_email(self, email, expected):
        """Should validate email addresses correctly."""
        service = UserService()
        assert service.is_valid_email(email) == expected
```

## Fixtures

```python
# tests/conftest.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from myapp.models import Base
from myapp.users.repository import UserRepository

@pytest.fixture(scope="session")
def engine():
    """Create test database engine."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()

@pytest.fixture
def db_session(engine):
    """Create database session for each test."""
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def user_repository(db_session):
    """Create UserRepository with test session."""
    return UserRepository(db_session)

@pytest.fixture
def sample_user():
    """Create sample user data."""
    return {
        "name": "Test User",
        "email": "test@example.com",
        "password": "password123"
    }

# Fixture with factory pattern
@pytest.fixture
def user_factory(db_session):
    """Factory to create users with custom attributes."""
    def _create_user(**kwargs):
        defaults = {
            "name": "Default User",
            "email": f"user_{id(kwargs)}@example.com",
        }
        defaults.update(kwargs)
        user = User(**defaults)
        db_session.add(user)
        db_session.commit()
        return user
    return _create_user
```

## Mocking

```python
from unittest.mock import Mock, patch, AsyncMock
import pytest

class TestUserService:

    def test_send_welcome_email(self, mocker):
        """Should send welcome email on user creation."""
        # Mock email service
        mock_email = mocker.patch("myapp.users.service.EmailService")
        mock_email.return_value.send.return_value = True

        service = UserService()
        user = service.create({"name": "John", "email": "john@test.com"})

        mock_email.return_value.send.assert_called_once_with(
            to="john@test.com",
            subject="Welcome!",
            body=mocker.ANY
        )

    def test_external_api_call(self, mocker):
        """Should handle external API response."""
        mock_response = Mock()
        mock_response.json.return_value = {"id": "123", "status": "active"}
        mock_response.status_code = 200

        mocker.patch("requests.get", return_value=mock_response)

        service = UserService()
        result = service.get_external_status("user_123")

        assert result["status"] == "active"

    @pytest.mark.asyncio
    async def test_async_operation(self, mocker):
        """Should handle async operations."""
        mock_fetch = AsyncMock(return_value={"data": "value"})
        mocker.patch("myapp.users.service.fetch_data", mock_fetch)

        service = UserService()
        result = await service.async_get_data()

        assert result["data"] == "value"
        mock_fetch.assert_awaited_once()
```

## Testing Exceptions

```python
def test_raises_not_found():
    """Should raise NotFoundError for missing user."""
    service = UserService()

    with pytest.raises(NotFoundError) as exc_info:
        service.get_by_id("nonexistent")

    assert exc_info.value.resource == "User"
    assert "nonexistent" in str(exc_info.value)

def test_raises_validation_error():
    """Should raise ValidationError with details."""
    service = UserService()

    with pytest.raises(ValidationError) as exc_info:
        service.create({"name": "", "email": "invalid"})

    errors = exc_info.value.errors
    assert len(errors) == 2
    assert any(e["field"] == "name" for e in errors)
    assert any(e["field"] == "email" for e in errors)
```

## API Testing (FastAPI)

```python
from fastapi.testclient import TestClient
from myapp.main import app

@pytest.fixture
def client():
    return TestClient(app)

class TestUsersAPI:

    def test_create_user(self, client, db_session):
        response = client.post("/users", json={
            "name": "John",
            "email": "john@example.com"
        })

        assert response.status_code == 201
        data = response.json()
        assert data["name"] == "John"
        assert "id" in data

    def test_get_user_not_found(self, client):
        response = client.get("/users/nonexistent")

        assert response.status_code == 404
        assert response.json()["detail"] == "User not found"

    def test_list_users_paginated(self, client, user_factory):
        # Create 15 users
        for i in range(15):
            user_factory(name=f"User {i}")

        response = client.get("/users?page=1&limit=10")

        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 10
        assert data["total"] == 15
        assert data["page"] == 1
```

## Async Testing

```python
import pytest
from httpx import AsyncClient
from myapp.main import app

@pytest.mark.asyncio
async def test_async_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/async-data")

    assert response.status_code == 200
```

## Markers & Skipping

```python
@pytest.mark.slow
def test_slow_operation():
    """This test takes a long time."""
    pass

@pytest.mark.integration
def test_database_connection():
    """Requires database."""
    pass

@pytest.mark.skipif(
    os.getenv("CI") == "true",
    reason="Skip in CI environment"
)
def test_local_only():
    pass

@pytest.mark.xfail(reason="Known bug #123")
def test_known_failure():
    pass
```

## Commands

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific markers
pytest -m "not slow"
pytest -m integration

# Run in parallel
pytest -n auto

# Verbose with print output
pytest -v -s

# Stop on first failure
pytest -x

# Run specific test
pytest tests/unit/test_users.py::TestUserService::test_create_user
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **AAA pattern** | Arrange, Act, Assert |
| **One assertion** | Focus each test |
| **Descriptive names** | test_should_X_when_Y |
| **Use fixtures** | DRY test setup |
| **Isolate tests** | No test interdependence |
| **Mock external** | APIs, databases, time |
| **Parametrize** | Test multiple inputs |
| **Coverage thresholds** | Enforce minimum coverage |
