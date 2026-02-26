def compute_pi_output(planets: list, extractors: dict) -> dict:
    """Return a summary of PI outputs per day (stub)."""
    total = 0
    for p in planets:
        total += p.get('base_output', 0)
    return {'output_per_day': total, 'planet_count': len(planets)}
