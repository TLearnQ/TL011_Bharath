import requests
import json

class APIClientError(Exception):
    pass


class APIClient:
    def __init__(self, base_url="", default_timeout=10, headers=None):
        self.base_url = base_url.rstrip("/")
        self.default_timeout = default_timeout
        self.headers = headers or {}

    def _full_url(self, url):
        if url.startswith("http://") or url.startswith("https://"):
            return url
        return f"{self.base_url}/{url.lstrip('/')}"

    def request(self, method, url, **kwargs):
        full_url = self._full_url(url)
        timeout = kwargs.pop("timeout", self.default_timeout)
        headers = {**self.headers, **kwargs.pop("headers", {})}

        try:
            response = requests.request(
                method=method,
                url=full_url,
                timeout=timeout,
                headers=headers,
                **kwargs
            )

            response.raise_for_status()  # Raise error for 4xx/5xx

            # Try returning JSON
            try:
                return response.json()
            except ValueError:
                return response.text

        except requests.exceptions.RequestException as e:
            raise APIClientError(f"Request failed: {str(e)}") from e

if __name__ == "__main__":
    print("Running APIClient self-test...\n")

    client = APIClient()

    try:
        result = client.request("GET", "https://www.google.com")

        print("Self-test successful!")
        print("Type of response:", type(result))

        if isinstance(result, dict):
            print("JSON keys:", list(result.keys()))
        else:
            print("Received non-JSON response (HTML/text).")

    except APIClientError as e:
        print("APIClient test failed:", e)