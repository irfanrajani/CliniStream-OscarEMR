"""
Encryption utilities for sensitive configuration values
Uses AES-256-GCM for encryption
"""

import os
import base64
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import logging

logger = logging.getLogger(__name__)

class CryptoUtils:
    """Handle encryption/decryption of sensitive configuration values"""

    def __init__(self):
        # Get encryption key from environment variable
        # In production, this should be a strong random key stored securely
        key_material = os.getenv('ENCRYPTION_KEY', 'default-nextscript-key-CHANGE-ME-IN-PRODUCTION')

        if key_material == 'default-nextscript-key-CHANGE-ME-IN-PRODUCTION':
            logger.warning("⚠️  Using default encryption key! Set ENCRYPTION_KEY environment variable for production!")

        # Derive a proper 256-bit key from the key material
        salt = b'nextscript-oscar-emr-salt-v1'  # Fixed salt for consistency
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,  # 256 bits
            salt=salt,
            iterations=100000
        )
        self.key = kdf.derive(key_material.encode())
        self.aesgcm = AESGCM(self.key)

    def encrypt(self, plaintext: str) -> str:
        """
        Encrypt a string value
        Returns base64-encoded ciphertext with nonce prepended
        """
        try:
            if not plaintext:
                return ''

            # Generate random nonce (12 bytes for GCM)
            nonce = os.urandom(12)

            # Encrypt
            ciphertext = self.aesgcm.encrypt(nonce, plaintext.encode(), None)

            # Combine nonce + ciphertext and base64 encode
            encrypted_data = nonce + ciphertext
            return base64.b64encode(encrypted_data).decode('utf-8')

        except Exception as e:
            logger.error(f"Encryption failed: {e}")
            raise

    def decrypt(self, encrypted_value: str) -> str:
        """
        Decrypt a base64-encoded encrypted value
        Returns plaintext string
        """
        try:
            if not encrypted_value:
                return ''

            # Base64 decode
            encrypted_data = base64.b64decode(encrypted_value)

            # Extract nonce (first 12 bytes) and ciphertext
            nonce = encrypted_data[:12]
            ciphertext = encrypted_data[12:]

            # Decrypt
            plaintext = self.aesgcm.decrypt(nonce, ciphertext, None)
            return plaintext.decode('utf-8')

        except Exception as e:
            logger.error(f"Decryption failed: {e}")
            # If decryption fails, might be plaintext (migration scenario)
            logger.warning("Returning value as-is (might be plaintext)")
            return encrypted_value

# Global instance
_crypto = None

def get_crypto():
    """Get global crypto instance (singleton)"""
    global _crypto
    if _crypto is None:
        _crypto = CryptoUtils()
    return _crypto

def encrypt_value(value: str) -> str:
    """Convenience function to encrypt a value"""
    return get_crypto().encrypt(value)

def decrypt_value(value: str) -> str:
    """Convenience function to decrypt a value"""
    return get_crypto().decrypt(value)


# Example usage:
if __name__ == '__main__':
    crypto = CryptoUtils()

    # Test encryption/decryption
    secret = "my-super-secret-password-123"
    encrypted = crypto.encrypt(secret)
    decrypted = crypto.decrypt(encrypted)

    print(f"Original:  {secret}")
    print(f"Encrypted: {encrypted}")
    print(f"Decrypted: {decrypted}")
    print(f"Match: {secret == decrypted}")
