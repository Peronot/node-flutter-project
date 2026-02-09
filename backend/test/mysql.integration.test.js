const { pool } = require('../src/config/db');

// Integration test hits real MySQL only when TEST_DB=1
const runIntegration = process.env.TEST_DB === '1';

(runIntegration ? describe : describe.skip)('mysql live integration', () => {
  it('connects and selects 1', async () => {
    const [rows] = await pool.query('SELECT 1 as ok');
    expect(rows[0].ok).toBe(1);
  });
});
