#!/usr/bin/env python
"""Management CLI for the application."""
import typer

from app.management.commands import app as db_commands

app = typer.Typer(
    name="manage",
    help="FastAPI Template Management CLI",
    add_completion=False,
)

# Add command groups
app.add_typer(db_commands, name="db", help="Database management commands")


if __name__ == "__main__":
    app()
