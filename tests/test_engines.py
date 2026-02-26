def test_mining_yield():
    from backend.app.engines.mining import compute_mining_yield
    
    result = compute_mining_yield(
        skills={'mining': 5},
        ship={'base_yield': 100},
        boosts={'fleet_bonus': 0.1}
    )
    
    assert 'yield_per_hour' in result
    assert result['yield_per_hour'] > 0

def test_pi_output():
    from backend.app.engines.pi import compute_pi_output
    
    result = compute_pi_output(
        planets=[{'base_output': 10}, {'base_output': 20}],
        extractors={}
    )
    
    assert result['output_per_day'] == 30
    assert result['planet_count'] == 2

def test_reaction():
    from backend.app.engines.reaction import plan_reaction
    
    result = plan_reaction(
        inputs={'goo': 100, 'catalyst': 50},
        structure_bonus=0.05
    )
    
    assert 'estimated_output' in result
    assert result['estimated_output'] > 0
