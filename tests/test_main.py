from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_liveness():
    response = client.get("/live")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_shorten_url():
    response = client.post(
        "/shorten",
        json={"url": "https://example.com"},
    )

    assert response.status_code == 200

    data = response.json()

    assert "short_url" in data
    assert "code" in data


def test_redirect():
    response = client.post(
        "/shorten",
        json={"url": "https://example.com"},
    )

    assert response.status_code == 200

    code = response.json()["code"]

    response = client.get(
        f"/{code}",
        follow_redirects=False,
    )

    assert response.status_code == 302
    assert response.headers["location"] == "https://example.com/"