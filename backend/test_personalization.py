import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.app.main import health_check, get_current_weather, rank_homepage_cards, UserProfileRequest

def test_health():
    res = health_check()
    assert res["status"] == "healthy"
    print("[PASS] Healthcheck passed:", res)

def test_weather():
    res = get_current_weather(location="Coimbatore, Tamil Nadu")
    assert res.location == "Coimbatore, Tamil Nadu"
    assert res.temp == 29.4
    assert "Mock" in res.source
    print(f"[PASS] Weather endpoint passed: {res.location} | Temp: {res.temp}C | Source: {res.source} | Quality: {res.data_quality}")

def test_personalization_general():
    profile = UserProfileRequest(user_type="general", interests=["Rain", "AQI"], location="Coimbatore")
    cards = rank_homepage_cards(profile)
    card_types = [c.type for c in cards]
    print("\n[General Persona Card Priority Order]:")
    for i, c in enumerate(cards, 1):
        print(f"  {i}. [Priority {c.priority_score}] {c.title} ({c.type}) -> {c.subtitle}")
    assert "heroCurrentWeather" in card_types

def test_personalization_farmer():
    profile = UserProfileRequest(user_type="farmer", interests=["Agriculture", "Soil"], location="Coimbatore", crop="")
    cards = rank_homepage_cards(profile)
    card_types = [c.type for c in cards]
    print("\n[Farmer Persona Card Priority Order]:")
    for i, c in enumerate(cards, 1):
        print(f"  {i}. [Priority {c.priority_score}] {c.title} ({c.type}) -> {c.subtitle}")
    assert cards[0].type == "agriWeatherSummary" or cards[1].type == "agriWeatherSummary"

def test_personalization_traveller():
    profile = UserProfileRequest(user_type="traveller", interests=["Travel", "Visibility"], location="Coimbatore")
    cards = rank_homepage_cards(profile)
    card_types = [c.type for c in cards]
    print("\n[Traveller Persona Card Priority Order]:")
    for i, c in enumerate(cards, 1):
        print(f"  {i}. [Priority {c.priority_score}] {c.title} ({c.type}) -> {c.subtitle}")
    assert cards[0].type == "travelDestinationSummary" or cards[1].type == "travelDestinationSummary"

if __name__ == "__main__":
    print("========================================================")
    print("  MAUSAM PERSONALIZATION ENGINE VERIFICATION")
    print("========================================================\n")
    test_health()
    test_weather()
    test_personalization_general()
    test_personalization_farmer()
    test_personalization_traveller()
    print("\n========================================================")
    print("  ALL VERIFICATION TESTS PASSED CLEANLY & EMPIRICALLY!")
    print("========================================================\n")
