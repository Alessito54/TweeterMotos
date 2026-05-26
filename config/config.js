require('dotenv').config();

const dbConfig = {
  use_env_variable: "DATABASE_URL",
  dialect: "postgres",
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  },
  logging: false
};

module.exports = {
  development: dbConfig,
  test: dbConfig,
  production: dbConfig
};
