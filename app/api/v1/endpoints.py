from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect

from app.core.security import current_active_user
from app.models.user import User

router = APIRouter()


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


@router.get("/protected")
async def protected_route(user: User = Depends(current_active_user)):
    """Example protected route"""
    return {"message": f"Hello {user.email}!"}


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time communication"""
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            await websocket.send_text(f"Message received: {data}")
    except WebSocketDisconnect:
        print("Client disconnected")
