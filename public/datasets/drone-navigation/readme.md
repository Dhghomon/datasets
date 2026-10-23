# Drone navigation dataset

`schengen.surql` holds the data for the tutorial [Navigate a drone without GPS](https://surrealdb.com/docs/explore/tutorials/tutorials/navigate-a-drone-without-gps). A simulated drone finds its position from aerial photos with vector search, narrows each search with a geospatial condition, and plans its route with `geo::distance()`, `geo::bearing()` and `INTERSECTS`.

The area is a square of 6 × 6 km around the point where France, Germany and Luxembourg meet, on the Moselle near Schengen.

## Tables

| Table | Holds |
| --- | --- |
| `tile` | 6,962 squares of aerial imagery, each 200 × 200 m, with a centre every 100 m. There are two seasons: `current` and `old`, which includes a winter for Luxembourg. `embedding` holds 384 numbers from DINOv2 (small), and an HNSW index covers it. |
| `country` | `country:FR`, `country:DE` and `country:LU`, each with its border inside the area. The Moselle north of the meeting point is held jointly by Germany and Luxembourg, so it is in no polygon. |
| `zone` | `zone:no_fly`: Luxembourg's border moved outwards by 150 m. |
| `place` | `place:launch` in France, `place:waypoint` and `place:destination` in Germany. |
| `photo` | The 38 photos a simulated drone took on its flight, one every 10 seconds. `prior` is where dead reckoning put the drone when it took the photo, and `truth` is where it was. |

The photos come from imagery of a third date, which no tile uses, so a search never finds an identical image.

## Example queries

Find where `photo:12` was taken, searching only the tiles within 400 m of the drone's estimate:

```surql
SELECT id, centre, country, vector::distance::knn() AS dist FROM tile
	WHERE geo::distance(centre, photo:12.prior) < 400
	AND embedding <|3,100|> photo:12.embedding
	ORDER BY dist;
```

Find which country a point is in, or `'LU-DE'` on the shared stretch of the river:

```surql
(SELECT VALUE id.id() FROM country WHERE photo:12.truth INSIDE area)[0] ?? 'LU-DE';
```

Find the distance and the direction from the launch point to the destination:

```surql
{
	distance: geo::distance(place:launch.at, place:destination.at),
	bearing: geo::bearing(place:launch.at, place:destination.at),
};
```

## Sources

- **Aerial imagery:** IGN (France), LVGL Saarland (Germany) and ACT geoportail.lu (Luxembourg), from their open web map services.
- **Borders:** municipal boundaries from OpenStreetMap, © OpenStreetMap contributors, available under the [Open Database License](https://www.openstreetmap.org/copyright).
