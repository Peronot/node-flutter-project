jest.mock('../src/config/db', () => ({
  pingDb: jest.fn().mockResolvedValue(),
  pool: { query: jest.fn() }
}));

const request = require('supertest');
const app = require('../src/app');

describe('health endpoint', () => {
  it('returns ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('status', 'ok');
  });

  it('requires auth on protected route', async () => {
    const res = await request(app).get('/api/patients');
    expect(res.status).toBe(401);
  });
});
