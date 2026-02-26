import os
import base64
from cryptography.fernet import Fernet

# Use env var ESI_TOKEN_KEY (base64 urlsafe) or derive one from SECRET_KEY
_key = os.getenv('ESI_TOKEN_KEY')
if not _key:
    # attempt to create from generic SECRET_KEY if present
    sk = os.getenv('SECRET_KEY')
    if sk:
        k = base64.urlsafe_b64encode(sk.encode('utf-8').ljust(32, b'0'))
        _key = k.decode('utf-8')
    else:
        # generate an ephemeral key (not suitable for production)
        _key = Fernet.generate_key().decode('utf-8')

fernet = Fernet(_key)

def encrypt(value: str) -> str:
    if value is None:
        return None
    if isinstance(value, str):
        value = value.encode('utf-8')
    return fernet.encrypt(value).decode('utf-8')


def decrypt(token: str) -> str:
    if token is None:
        return None
    return fernet.decrypt(token.encode('utf-8')).decode('utf-8')
