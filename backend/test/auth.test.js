jest.mock('../src/config/db', () => ({
  pingDb: jest.fn().mockResolvedValue(),
  pool: { query: jest.fn() }
}));

jest.mock('../src/models/userModel', () => ({
  findByEmail: jest.fn(),
  findWithPasswordByEmail: jest.fn(),
  findWithPasswordByIdentifier: jest.fn(),
  findWithPasswordByUsername: jest.fn(),
  create: jest.fn()
}));

const bcrypt = require('bcryptjs');
const request = require('supertest');
const app = require('../src/app');
const userModel = require('../src/models/userModel');

describe('auth routes', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('registers new user and returns token', async () => {
    userModel.findByEmail.mockResolvedValue(null);
    userModel.create.mockResolvedValue({ id: 1, full_name: 'Test', email: 't@example.com', role: 'user' });

    const res = await request(app)
      .post('/api/auth/register')
      .send({ full_name: 'Test', email: 't@example.com', password: 'secret123' });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('token');
    expect(userModel.create).toHaveBeenCalled();
  });

  it('rejects bad credentials on login', async () => {
    userModel.findWithPasswordByIdentifier.mockResolvedValue(null);
    userModel.findWithPasswordByUsername.mockResolvedValue(null);
    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'missing', password: 'bad' });
    expect(res.status).toBe(401);
  });

  it('logs in with correct credentials', async () => {
    const hash = await bcrypt.hash('secret123', 1);
    userModel.findWithPasswordByUsername.mockResolvedValue({
      id: 2, full_name: 'Ok', email: 'ok@example.com', role: 'admin', password: hash
    });

    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'Ok', password: 'secret123' });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('token');
  });

  it('logout revokes token', async () => {
    const hash = await bcrypt.hash('secret123', 1);
    userModel.findWithPasswordByUsername.mockResolvedValue({
      id: 3, full_name: 'Ok', email: 'ok@example.com', role: 'admin', password: hash
    });
    const login = await request(app)
      .post('/api/auth/login')
      .send({ username: 'Ok', password: 'secret123' });
    const token = login.body.token;
    const res = await request(app)
      .post('/api/auth/logout')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(204);
    const protectedCall = await request(app)
      .get('/api/patients')
      .set('Authorization', `Bearer ${token}`);
    expect(protectedCall.status).toBe(401);
  });
});
