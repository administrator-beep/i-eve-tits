def test_crypto():
    from backend.app.crypto import encrypt, decrypt
    
    plaintext = "test_token_abc123"
    encrypted = encrypt(plaintext)
    decrypted = decrypt(encrypted)
    
    assert decrypted == plaintext
    assert encrypted != plaintext
