// Utility helpers for building SQL queries safely

const buildSearch = (search, fields = []) => {
  if (!search || !fields.length) return { clause: '', params: [] };
  const like = `%${search}%`;
  return {
    clause: ' WHERE ' + fields.map((f) => `${f} LIKE ?`).join(' OR '),
    params: Array(fields.length).fill(like)
  };
};

const pickFields = (data, allowed) => {
  const entries = Object.entries(data || {}).filter(
    ([key, value]) => allowed.includes(key) && value !== undefined
  );
  return Object.fromEntries(entries);
};

const paginationParams = (page = 1, pageSize = 20, maxPageSize = 100) => {
  const p = Math.max(1, parseInt(page, 10) || 1);
  const ps = Math.min(maxPageSize, Math.max(1, parseInt(pageSize, 10) || 20));
  return { limit: ps, offset: (p - 1) * ps };
};

module.exports = { buildSearch, pickFields, paginationParams };
