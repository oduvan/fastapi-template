import logging

from celery import shared_task

logger = logging.getLogger(__name__)


@shared_task
def example_task(x: int, y: int) -> int:
    """Example Celery task that adds two numbers"""
    return x + y


@shared_task
def send_email_task(email: str, subject: str, body: str) -> dict:
    """Example task for sending emails"""
    # Implement your email sending logic here
    logger.info(f"Sending email to {email}")
    logger.debug(f"Subject: {subject}")
    logger.debug(f"Body: {body}")
    return {"status": "sent", "email": email}


@shared_task
def process_data_task(data: dict) -> dict:
    """Example task for processing data"""
    # Implement your data processing logic here
    logger.info(f"Processing data: {data}")
    return {"status": "processed", "result": data}
