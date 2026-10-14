--  .d8888b.                                             888 8888888b.  888888b.
-- d88P  Y88b                                            888 888  'Y88b 888  '88b
-- Y88b.                                                 888 888    888 888  .88P
--  'Y888b.   888  888 888d888 888d888  .d88b.   8888b.  888 888    888 8888888K.
--     'Y88b. 888  888 888P'   888P'   d8P  Y8b     '88b 888 888    888 888  'Y88b
--       '888 888  888 888     888     88888888 .d888888 888 888    888 888    888
-- Y88b  d88P Y88b 888 888     888     Y8b.     888  888 888 888  .d88P 888   d88P
--  'Y8888P'   'Y88888 888     888      'Y8888  'Y888888 888 8888888P'  8888888P'
--
-- Welcome to SurrealDB, a multi-model database combining document, graph,
-- relational, time-series and vector capabilities in one system, all powered
-- by SurrealQL. Use it to build AI agents, real-time and event-driven systems,
-- knowledge graphs, as a backend, a BaaS, or embed it directly into your apps.
-- One engine, every model.
--
-- Learn more at https://surrealdb.com/docs/surrealdb/introduction/start
--
-- *****************************************************************************

-- ------------------------------------------------------------
-- CRUD

CREATE user:martin CONTENT { name: "martin" };
CREATE user:ignacio CONTENT { name: "ignacio" };
CREATE user:tobie; user:jaime;

SELECT * FROM user;

UPDATE user:martin SET lastname = "schaer";

DELETE user:foo;

-- ------------------------------------------------------------
-- Relations through record links (simple, no metadata)
-- Create teams
CREATE team:green SET name = "Green";
CREATE team:red SET name = "Red";
UPDATE user:martin SET team = team:green;

SELECT id, name, team.name FROM user;
-- Show all properties inside team
SELECT id, name, team.* FROM user;

-- ------------------------------------------------------------
-- Relations through graph edges (can contain metadata)
RELATE user:martin->plays_for->team:green SET since = d'2025-10-23';
RELATE user:ignacio->plays_for->team:green;
RELATE user:tobie->plays_for->team:red;

SELECT *, ->plays_for->team as team FROM user;

// To learn more, go to SurrealDB University Fundamentals course:
// https://surrealdb.com/learn/fundamentals