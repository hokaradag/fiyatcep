"""Firebase Admin SDK initialization and FCM notification sender.

Implements NOTIF-03: send push notification when a tracked product's price drops.

Firebase Admin SDK uses GOOGLE_APPLICATION_CREDENTIALS env var to locate
the service account JSON file. If the env var is not set or the file is
missing, Firebase features are disabled gracefully (no crash).
"""
import json
import logging
import os

from sqlalchemy import text
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)

# Firebase Admin SDK — lazy init, graceful degradation if not configured
_firebase_initialized = False


def init_firebase_admin() -> bool:
    """Initialize Firebase Admin SDK. Returns True if successful.

    Uses GOOGLE_APPLICATION_CREDENTIALS env var. If not set, logs a warning
    and returns False — the backend continues to work without push notifications.
    """
    global _firebase_initialized
    if _firebase_initialized:
        return True

    creds_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not creds_path:
        logger.warning(
            "GOOGLE_APPLICATION_CREDENTIALS not set — FCM push notifications disabled. "
            "Set it to the path of your Firebase service account JSON file."
        )
        return False

    try:
        import firebase_admin
        from firebase_admin import credentials

        cred = credentials.Certificate(creds_path)
        firebase_admin.initialize_app(cred)
        _firebase_initialized = True
        logger.info("Firebase Admin SDK initialized successfully")
        return True
    except Exception as exc:
        logger.error("Firebase Admin SDK init failed: %s", exc)
        return False


def send_price_drop_notification(
    fcm_token: str,
    product_name: str,
    market_product_id: str,
    old_price: float,
    new_price: float,
) -> bool:
    """Send a single FCM push notification for a price drop.

    Args:
        fcm_token: Device FCM registration token.
        product_name: Human-readable product name for notification body.
        market_product_id: MarketProduct.id — sent as data['productId']
            so the Flutter app can navigate to the product detail page (per D-03).
        old_price: Previous price before the drop.
        new_price: New (lower) price.

    Returns:
        True if sent successfully, False otherwise.
    """
    if not _firebase_initialized:
        return False

    try:
        from firebase_admin import messaging

        message = messaging.Message(
            notification=messaging.Notification(
                title="Fiyat Dustu!",
                body=f"{product_name}: {old_price:.2f} TL -> {new_price:.2f} TL",
            ),
            data={
                "productId": market_product_id,
                "oldPrice": str(old_price),
                "newPrice": str(new_price),
            },
            token=fcm_token,
        )
        messaging.send(message)
        logger.info(
            "FCM notification sent: product=%s, token=%s...%s",
            market_product_id,
            fcm_token[:8],
            fcm_token[-4:],
        )
        return True
    except Exception as exc:
        logger.error("FCM send failed for token %s...: %s", fcm_token[:8], exc)
        return False


def detect_and_notify_price_drops(db: Session) -> int:
    """Check for price drops after a scrape cycle and notify subscribed devices.

    Strategy:
    1. Query device_subscriptions to get all watched product IDs per device.
    2. For each watched market_product_id, compare current_price with
       the most recent price_history entry (the previous price before this scrape).
    3. If current_price < previous price, send FCM notification to that device.

    This function is called from runner.py AFTER db.commit() (prices are
    already persisted). It reads committed data, so it runs in its own
    read-only context.

    Args:
        db: SQLAlchemy session.

    Returns:
        Number of notifications sent.
    """
    if not _firebase_initialized:
        logger.debug("Firebase not initialized — skipping price-drop detection")
        return 0

    sent_count = 0

    try:
        # Check if device_subscriptions table exists
        result = db.execute(text(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='device_subscriptions'"
        ))
        if result.fetchone() is None:
            return 0  # No subscriptions yet

        # Get all subscriptions
        rows = db.execute(text(
            "SELECT fcm_token, product_ids FROM device_subscriptions"
        )).fetchall()

        for row in rows:
            fcm_token = row[0]
            product_ids = json.loads(row[1]) if row[1] else []

            for mp_id in product_ids:
                # Get current price and product name
                mp_row = db.execute(text("""
                    SELECT mp.current_price, p.name, mp.id
                    FROM market_products mp
                    JOIN products p ON mp.product_id = p.id
                    WHERE mp.id = :mp_id
                """), {"mp_id": mp_id}).fetchone()

                if mp_row is None:
                    continue

                current_price = mp_row[0]
                product_name = mp_row[1]

                # Get the SECOND most recent price (the one before this scrape)
                # The most recent is the current scrape's price; we want the previous one
                prev_row = db.execute(text("""
                    SELECT price FROM price_history
                    WHERE market_product_id = :mp_id
                    ORDER BY recorded_at DESC
                    LIMIT 1 OFFSET 1
                """), {"mp_id": mp_id}).fetchone()

                if prev_row is None:
                    continue  # No previous price to compare

                previous_price = prev_row[0]

                if current_price < previous_price:
                    if send_price_drop_notification(
                        fcm_token=fcm_token,
                        product_name=product_name,
                        market_product_id=mp_id,
                        old_price=previous_price,
                        new_price=current_price,
                    ):
                        sent_count += 1

    except Exception as exc:
        logger.error("Price-drop detection failed: %s", exc)

    logger.info("Price-drop notifications sent: %d", sent_count)
    return sent_count
