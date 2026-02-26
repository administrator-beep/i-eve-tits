def compute_mining_yield(skills: dict, ship: dict, boosts: dict) -> dict:
    """Return an estimated mining yield summary (stub).
    skills, ship, and boosts are dictionaries describing character and equipment.
    """
    # Placeholder algorithm
    base_yield = ship.get('base_yield', 100)
    skill_bonus = 1.0 + (skills.get('mining', 0) * 0.02)
    boost_bonus = 1.0 + boosts.get('fleet_bonus', 0)
    result = {
        'yield_per_hour': base_yield * skill_bonus * boost_bonus,
        'details': {
            'base_yield': base_yield,
            'skill_bonus': skill_bonus,
            'boost_bonus': boost_bonus
        }
    }
    return result
