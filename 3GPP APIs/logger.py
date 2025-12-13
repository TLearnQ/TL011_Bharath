import logging
import json

logging.basicConfig(
    filename="parsig.log",
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    force=True
)

def log_event(event, data):
    logging.info(json.dumps({"event": event, "data": data}))

log_event("TEST_EVENT", {"status": "ok"})
