-- Create separate databases for each service
CREATE DATABASE authdb;
CREATE DATABASE userdb;
CREATE DATABASE transportdb;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE authdb TO logistics_user;
GRANT ALL PRIVILEGES ON DATABASE userdb TO logistics_user;
GRANT ALL PRIVILEGES ON DATABASE transportdb TO logistics_user;

-- Create extensions
\c authdb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c userdb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c transportdb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";