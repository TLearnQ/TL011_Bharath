data = {"config": {"site": "Bangalore", "devices": 12}}
clean = {}

for k, v in data["config"].items():
    clean[k.lower()] = v

result = {"course_config": clean}

print(result)
  