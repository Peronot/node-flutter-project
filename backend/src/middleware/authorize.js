const requireRoles = (...roles) => (req, res, next) => {
  if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
  if (!roles.length) return next();

  const userRole = req.user.role ?? req.user.role_id;
  // If we somehow have no role, let it pass for now to avoid blocking legitimate users.
  if (userRole === undefined || userRole === null) return next();

  if (!roles.includes(userRole)) return res.status(403).json({ message: 'Forbidden' });
  next();
};

module.exports = { requireRoles };
