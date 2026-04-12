"""Notifications router -- device subscription management.

Per D-05: Flutter sends updated watch list + FCM token on every change.
Backend stores the mapping so it knows which products to monitor per device.
"""
import json

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.database import get_db

router = APIRouter(prefix="/notifications", tags=["notifications"])


class SubscribeRequest(BaseModel):
    fcmToken: str
    productIds: list[str] = []
    discountIds: list[str] = []


@router.post("/subscribe")
def subscribe(request: SubscribeRequest, db: Session = Depends(get_db)):
    """Upsert device subscription: replace watched IDs for this FCM token.

    Per D-05: Called on every watch list change and on token refresh.
    """
    # Create table if not exists (idempotent, runs once)
    db.execute(text("""
        CREATE TABLE IF NOT EXISTS device_subscriptions (
            fcm_token TEXT PRIMARY KEY,
            product_ids TEXT NOT NULL DEFAULT '[]',
            discount_ids TEXT NOT NULL DEFAULT '[]',
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """))

    product_ids_json = json.dumps(request.productIds)
    discount_ids_json = json.dumps(request.discountIds)

    db.execute(text("""
        INSERT INTO device_subscriptions (fcm_token, product_ids, discount_ids, updated_at)
        VALUES (:token, :pids, :dids, CURRENT_TIMESTAMP)
        ON CONFLICT(fcm_token) DO UPDATE SET
            product_ids = excluded.product_ids,
            discount_ids = excluded.discount_ids,
            updated_at = CURRENT_TIMESTAMP
    """), {"token": request.fcmToken, "pids": product_ids_json, "dids": discount_ids_json})
    db.commit()

    return {
        "status": "subscribed",
        "productCount": len(request.productIds),
        "discountCount": len(request.discountIds),
    }
