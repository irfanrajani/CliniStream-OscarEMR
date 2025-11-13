const crypto = require('crypto');

/**
 * Encryption utilities for sensitive configuration values
 * Uses AES-256-GCM to match Python implementation
 */

class CryptoUtils {
  constructor() {
    // Get encryption key from environment (should match Python)
    const keyMaterial = process.env.ENCRYPTION_KEY || 'default-nextscript-key-CHANGE-ME-IN-PRODUCTION';

    if (keyMaterial === 'default-nextscript-key-CHANGE-ME-IN-PRODUCTION') {
      console.warn('⚠️  Using default encryption key! Set ENCRYPTION_KEY environment variable for production!');
    }

    // Derive 256-bit key using PBKDF2 (same as Python)
    const salt = Buffer.from('nextscript-oscar-emr-salt-v1');
    this.key = crypto.pbkdf2Sync(keyMaterial, salt, 100000, 32, 'sha256');
  }

  /**
   * Encrypt a string value
   * Returns base64-encoded ciphertext with nonce prepended
   */
  encrypt(plaintext) {
    if (!plaintext) return '';

    try {
      // Generate random 12-byte nonce for GCM
      const nonce = crypto.randomBytes(12);

      // Create cipher
      const cipher = crypto.createCipheriv('aes-256-gcm', this.key, nonce);

      // Encrypt
      let ciphertext = cipher.update(plaintext, 'utf8');
      ciphertext = Buffer.concat([ciphertext, cipher.final()]);

      // Get auth tag
      const authTag = cipher.getAuthTag();

      // Combine nonce + ciphertext + authTag
      const encrypted = Buffer.concat([nonce, ciphertext, authTag]);

      // Return base64 encoded
      return encrypted.toString('base64');

    } catch (error) {
      console.error('Encryption failed:', error);
      throw error;
    }
  }

  /**
   * Decrypt a base64-encoded encrypted value
   * Returns plaintext string
   */
  decrypt(encryptedValue) {
    if (!encryptedValue) return '';

    try {
      // Base64 decode
      const encrypted = Buffer.from(encryptedValue, 'base64');

      // Extract nonce (first 12 bytes), auth tag (last 16 bytes), and ciphertext
      const nonce = encrypted.slice(0, 12);
      const authTag = encrypted.slice(-16);
      const ciphertext = encrypted.slice(12, -16);

      // Create decipher
      const decipher = crypto.createDecipheriv('aes-256-gcm', this.key, nonce);
      decipher.setAuthTag(authTag);

      // Decrypt
      let plaintext = decipher.update(ciphertext);
      plaintext = Buffer.concat([plaintext, decipher.final()]);

      return plaintext.toString('utf8');

    } catch (error) {
      console.error('Decryption failed:', error);
      // If decryption fails, might be plaintext (migration scenario)
      console.warn('Returning value as-is (might be plaintext)');
      return encryptedValue;
    }
  }
}

// Export singleton instance
const cryptoInstance = new CryptoUtils();

module.exports = {
  encrypt: (value) => cryptoInstance.encrypt(value),
  decrypt: (value) => cryptoInstance.decrypt(value),
  CryptoUtils
};

// Test if run directly
if (require.main === module) {
  const secret = 'my-super-secret-password-123';
  const encrypted = cryptoInstance.encrypt(secret);
  const decrypted = cryptoInstance.decrypt(encrypted);

  console.log('Original: ', secret);
  console.log('Encrypted:', encrypted);
  console.log('Decrypted:', decrypted);
  console.log('Match:    ', secret === decrypted);
}
