"""Management commands for database operations."""

import asyncio

import typer
from rich.console import Console
from rich.table import Table
from sqlalchemy import func, select

from app.db.session import async_session_maker
from app.models.user import User

app = typer.Typer(help="Database management commands")
console = Console()


@app.command()
def count_users():
    """Show the total number of users in the database."""
    asyncio.run(async_count_users())


async def async_count_users():
    """Async implementation to count users."""
    async with async_session_maker() as session:
        result = await session.execute(select(func.count()).select_from(User))
        total = result.scalar()

        console.print(f"\n[bold green]Total Users:[/bold green] {total}\n")


@app.command()
def list_users(limit: int = typer.Option(10, help="Maximum number of users to show")):
    """List users from the database."""
    asyncio.run(async_list_users(limit))


async def async_list_users(limit: int):
    """Async implementation to list users."""
    async with async_session_maker() as session:
        result = await session.execute(select(User).limit(limit))
        users = result.scalars().all()

        if not users:
            console.print("[yellow]No users found in the database.[/yellow]")
            return

        table = Table(title=f"Users (showing up to {limit})")
        table.add_column("ID", style="cyan")
        table.add_column("Email", style="green")
        table.add_column("Active", style="magenta")
        table.add_column("Superuser", style="red")
        table.add_column("Verified", style="blue")

        for user in users:
            table.add_row(
                str(user.id),
                user.email,
                "✓" if user.is_active else "✗",
                "✓" if user.is_superuser else "✗",
                "✓" if user.is_verified else "✗",
            )

        console.print(table)
