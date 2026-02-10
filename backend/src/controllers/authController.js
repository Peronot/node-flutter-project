const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { randomUUID } = require('crypto');
const userModel = require('../models/userModel');
const asyncHandler = require('../utils/asyncHandler');
const { revoke } = require('../utils/tokenBlacklist');

const signToken = (user) => {
  const role = user.role ?? user.role_id ?? 'user';
  const payload = { id: user.id, role, role_id: user.role_id, email: user.email };
  const secret = process.env.JWT_SECRET || 'dev_secret';
  const expiresIn = process.env.JWT_EXPIRES_IN || '7d';
  return jwt.sign(payload, secret, { expiresIn, jwtid: randomUUID() });
};

exports.register = asyncHandler(async (req, res) => {
  const { full_name, email, password, role, role_id } = req.validatedBody;
  const existing = await userModel.findByEmail(email);
  if (existing) return res.status(409).json({ message: 'Email already registered' });

  const hashed = await bcrypt.hash(password, 10);
  const normalizedRoleId = Number.isFinite(Number(role_id ?? role)) ? Number(role_id ?? role) : undefined;
  const created = await userModel.create({
    full_name,
    email,
    password: hashed,
    role_id: normalizedRoleId,
    created_at: new Date()
  });
  const token = signToken(created);
  res.status(201).json({ user: created, token });
});

exports.login = asyncHandler(async (req, res) => {
  const { username, password } = req.validatedBody;
  const user = await userModel.findWithPasswordByUsername(username);
  if (!user) return res.status(401).json({ message: 'Invalid credentials' });
  const ok = await bcrypt.compare(password, user.password);
  if (!ok) return res.status(401).json({ message: 'Invalid credentials' });
  const token = signToken(user);
  delete user.password;
  res.json({ user, token });
});

exports.logout = asyncHandler(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dev_secret');
      revoke(decoded.jti, decoded.exp);
    } catch (err) {
      // ignore invalid token
    }
  }
  res.status(204).end();
});

exports.changePassword = asyncHandler(async (req, res) => {
  const { current_password, new_password } = req.validatedBody;
  const user = await userModel.findWithPasswordById(req.user.id);
  if (!user) return res.status(404).json({ message: 'User not found' });
  const ok = await bcrypt.compare(current_password, user.password);
  if (!ok) return res.status(401).json({ message: 'Current password incorrect' });
  const hashed = await bcrypt.hash(new_password, 10);
  await userModel.update(req.user.id, { password: hashed });
  res.status(204).end();
});
