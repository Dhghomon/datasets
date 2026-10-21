# SurrealDB Agent Memory showcase datasets

Each file here holds what the SurrealDB Agent Memory API returned for one of the demos in the [Agent Memory showcase](https://surrealdb.com/docs/agent-memory/cookbooks/showcase), so the records behind a demo can be queried directly.

| File | Demo |
| --- | --- |
| `robin-hood.surql` | [Robin Hood character graph](https://surrealdb.com/docs/agent-memory/cookbooks/showcase/robin-hood) |
| `pompeii.surql` | [Pompeii election notices](https://surrealdb.com/docs/agent-memory/cookbooks/showcase/pompeii) |
| `domesday.surql` | [Domesday: South Erpingham, 1086](https://surrealdb.com/docs/agent-memory/cookbooks/showcase/domesday) |
| `night-owls.surql` | [Night Owls: twenty years of forum memory](https://surrealdb.com/docs/agent-memory/cookbooks/showcase/night-owls) |
| `rome.surql` | [Rome, 753 BC to AD 1453](https://surrealdb.com/docs/agent-memory/cookbooks/showcase/rome) |

## What the files contain

The data is the API's response shape: the entities from `GET /entities`, and the attributes and relations from `GET /entities/{type}/{name}`. It is not the data Agent Memory holds internally, which also includes embeddings, source chunks, indexes and other internal tables.

| Table | Holds |
| --- | --- |
| `entity` | One record per entity, with the id the API uses, such as `entity:['person', 'caius_iulius_polybius']` |
| `attribute` | One record per current attribute value, linked to its entity through the `entity` field. `supersedes` holds the id of the value it replaced, which is not itself included, since the entity endpoint returns current values only |
| `relation` | One graph edge per relation, from subject to object, with its `label` |

`robin-hood.surql` also holds the values a later chapter replaced, from `GET /entities/{type}/{name}/history/{key}`, so a replaced value carries a `validUntil` and each attribute's history can be read in order. Its dates are the demo's narrative clock: chapter 1 is 1 January 2000 and each chapter is one day later. A `validUntil` in 2026 marks a value that was closed when the memory was written rather than at a chapter.

Relations are written as graph edges so they can be traversed with `->relation->`, which is the one change from the API's shape. Each attribute and relation keeps the title of the document it came from in `source`.

## Night Owls

`night-owls.surql` holds a whole simulated forum as well as what the API returned for it. Seven fictional members post in five threads about real events from 1999 to 2019, and each member is an agent with its own Agent Memory scope.

| Table | Holds |
| --- | --- |
| `member` | The seven members, such as `member:theyknow` |
| `thread` | One thread per event, from `thread:y2k` (1999) to `thread:endgame` (2019), with the question the members argue about |
| `news` | The real, dated news reports the board saw, each linked to its thread |
| `post` | Every post, with its author, its time, the author's private note, `recalled` (the items Agent Memory recall returned for it, read as of the post's own time) and `state` (the view read from that memory, scored 0 to 4 on the thread's question) |
| `entity`, `attribute`, `relation` | What the API returned, as for the other files, written under the run's scopes. Only relations extracted from what a member wrote are kept, and the members' attributes include their value history |

A recalled forum post, private note or news report links to its record in `from`, so a memory can be followed back to where it came from. A private note is on the post it was written with, in `note`. A recalled fact has no record of its own and keeps its `text`.

## Rome

`rome.surql` holds what the API returned for the Rome demo: the facts it wrote for every year from 753 BC to AD 1453, as entities, attributes and relations, plus the value histories the demo read from `GET /entities/{type}/{name}/history/{key}`. A ruler, controller or office that a later fact replaced is included with its `validUntil`, so a chain such as the tyrants of Syracuse can be read in order. Only the facts the demo wrote are kept; links that Agent Memory inferred in the background are left out.

Dates use the demo's own clock, because a timestamp cannot hold a year before AD 1: year 1 is 753 BC and year 754 is AD 1, so the AD year is the timestamp's year minus 753. Each fact also carries a label with the real year, such as `year=753 BC`. The facts were taken from Wikipedia's year pages, which are available under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Example queries

```surql
-- pompeii.surql: everything known about one person
SELECT key, value, source FROM attribute WHERE entity = entity:['person', 'caius_iulius_polybius'];

-- pompeii.surql: who backs whom
SELECT in.name AS supporter, out.name AS candidate FROM relation WHERE label = 'asks_voters_to_elect';

-- robin-hood.surql: how Robin Hood's temperament changed through the book
SELECT createdAt, value, validUntil, source FROM attribute
    WHERE entity = entity:['person', 'robin_hood'] AND key = 'temperament'
    ORDER BY createdAt;

-- night-owls.surql: how many 2019 posts by each member recalled a private note from 1999
SELECT author.username AS member, count() AS posts_in_2019 FROM post
    WHERE thread = thread:endgame AND recalled[WHERE kind = 'private' AND at < d'2000-01-07'] != []
    GROUP BY member;

-- night-owls.surql: the 1999 notes behind one of TheyKnow's 2019 posts
SELECT recalled[WHERE kind = 'private' AND at < d'2000-01-07'].from.note AS notes_from_1999
    FROM post:['endgame', 5];

-- rome.surql: the tyrants of Syracuse, each replacing the one before
SELECT string::replace(labels[0], 'year=', '') AS year, value AS tyrant FROM attribute
    WHERE entity = entity:['location', 'syracuse,_sicily'] AND key = 'tyrant'
    ORDER BY validFrom;

-- Any file: values that replaced an earlier one
SELECT entity.name AS name, key, value, supersedes FROM attribute WHERE supersedes != NONE;
```
