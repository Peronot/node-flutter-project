// Simple in-memory token revocation list keyed by JWT jti
// Not persistent; for production replace with Redis or DB
const revoked = new Map(); // jti -> exp (unix seconds)

const revoke = (jti, exp) => {
  if (!jti) return;
  revoked.set(jti, exp || 0);
};

const isRevoked = (jti) => {
  if (!jti) return false;
  const exp = revoked.get(jti);
  if (!exp) return false;
  const now = Math.floor(Date.now() / 1000);
  if (now > exp) {
    revoked.delete(jti); // cleanup expired
    return false;
  }
  return true;
};

module.exports = { revoke, isRevoked };
