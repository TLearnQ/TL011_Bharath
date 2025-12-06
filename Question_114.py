log = []

def fake_api():
    import random
    return random.choice(["FAIL", "OK"])

def call():
    for i in range(3):
        res = fake_api()
        log.append(f"Attempt {i+1}: {res}")

        if res == "OK":
            log.append("Completed")
            return "Success"

        log.append("Retrying...")

    log.append("Aborted")
    return "Failed"

print(call())
print(log)
