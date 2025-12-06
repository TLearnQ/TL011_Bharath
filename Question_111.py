items = []
def router(req, data=None):
    try:
        m, p = req.split()

        if m == "POST" and p == "/items":
            if not data or "name" not in data:
                return "ERROR: Bad payload"
            items.append(data)
            return "Item added"

        elif m == "GET" and p == "/items":
            return items

        elif m == "GET" and p == "/stats":
            return {"count": len(items)}

        else:
            return "ERROR: Invalid route"

    except:
        return "ERROR: Invalid request format"

print(router("POST /items", {"name": "Python", "status": "in"}))
print(router("GET /items"))
print(router("GET /stats"))
    

