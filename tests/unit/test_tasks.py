import pytest

from app.tasks.tasks import example_task


@pytest.mark.unit
def test_example_task():
    """Test the example Celery task"""
    result = example_task(2, 3)
    assert result == 5
