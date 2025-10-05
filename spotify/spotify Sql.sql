
--  View all data
SELECT * FROM spotify_liked_songs_data;

--  Remove duplicate songs based on name
DELETE FROM spotify_liked_songs_data a
USING spotify_liked_songs_data b
WHERE a."name" = b."name"
  AND a.ctid > b.ctid;

--  Count total tracks
SELECT COUNT(*) AS total_tracks
FROM spotify_liked_songs_data;

--  Top 10 most saved artists
SELECT artist, COUNT(*) AS track_count
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY track_count DESC
LIMIT 10;

--  Most frequent song names (duplicates across artists)
SELECT name, COUNT(*) AS occurrences
FROM spotify_liked_songs_data
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

--  Count unique artists
SELECT COUNT(DISTINCT artist) AS unique_artists
FROM spotify_liked_songs_data;

--  Artist with the most distinct tracks
SELECT artist, COUNT(DISTINCT name) AS unique_tracks
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY unique_tracks DESC
LIMIT 1;

--  Songs with multiple versions (same name, different artists)
SELECT name, STRING_AGG(artist, ', ') AS artists, COUNT(*) AS versions
FROM spotify_liked_songs_data
GROUP BY name
HAVING COUNT(DISTINCT artist) > 1
ORDER BY versions DESC;

--  Tracks without a valid Spotify URL
SELECT *
FROM spotify_liked_songs_data
WHERE url IS NULL OR url = '';

-- Artist share percentage
SELECT artist,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM spotify_liked_songs_data), 2) AS percent_share
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY percent_share DESC
LIMIT 10;

--  Longest track names
SELECT name, LENGTH(name) AS name_length
FROM spotify_liked_songs_data
ORDER BY name_length DESC
LIMIT 10;

--  Detect duplicate entries (same artist & song)
SELECT artist, name, COUNT(*) AS dup_count
FROM spotify_liked_songs_data
GROUP BY artist, name
HAVING COUNT(*) > 1
ORDER BY dup_count DESC;

--  Artists with only one liked track
SELECT artist
FROM spotify_liked_songs_data
GROUP BY artist
HAVING COUNT(*) = 1;

--  Top 5 artists by saved track percentage
SELECT artist,
       COUNT(*) AS track_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percent_of_total
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY percent_of_total DESC
LIMIT 5;

--  Song IDs not following Spotify format (should be 22-char base62)
SELECT id
FROM spotify_liked_songs_data
WHERE id !~ '^[a-zA-Z0-9]{22}$';

--  Find artists with “Remix” tracks
SELECT artist, name
FROM spotify_liked_songs_data
WHERE LOWER(name) LIKE '%remix%';

--  Tracks with artist names containing “man”
SELECT artist, name
FROM spotify_liked_songs_data
WHERE LOWER(name) LIKE '%man%';

--  Top 10 artists by number of liked songs
SELECT 
    artist,
    COUNT(*) AS liked_song_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS artist_rank
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY artist_rank
LIMIT 10;

--  Artists with more than 5 liked songs
WITH artist_song_counts AS (
    SELECT 
        artist,
        COUNT(*) AS liked_song_count
    FROM spotify_liked_songs_data
    GROUP BY artist
)
SELECT 
    artist,
    liked_song_count
FROM artist_song_counts
WHERE liked_song_count > 5
ORDER BY liked_song_count DESC;

--  Popularity tiers based on liked songs
SELECT 
    artist,
    COUNT(*) AS liked_song_count,
    CASE 
        WHEN COUNT(*) >= 10 THEN 'Very Popular'
        WHEN COUNT(*) BETWEEN 5 AND 9 THEN 'Popular'
        ELSE 'Emerging'
    END AS popularity_category
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY liked_song_count DESC;

--  Top 10 most liked albums
SELECT album_name, COUNT(*) AS track_count
FROM spotify_liked_songs_data
GROUP BY album_name
ORDER BY track_count DESC
LIMIT 10;

--  Average track duration per artist (in minutes)
SELECT artist, 
       ROUND(AVG(duration_ms)/60000.0, 2) AS avg_duration_min
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY avg_duration_min DESC
LIMIT 10;

--  Explicit vs non-explicit track counts
SELECT explicit, COUNT(*) AS track_count
FROM spotify_liked_songs_data
GROUP BY explicit;

--  Top 10 tracks by popularity
SELECT name, artist, popularity
FROM spotify_liked_songs_data
ORDER BY popularity DESC
LIMIT 10;

--  Year-wise liked song distribution
SELECT release_year, COUNT(*) AS song_count
FROM spotify_liked_songs_data
GROUP BY release_year
ORDER BY release_year;

--  Most popular artists by average song popularity
SELECT artist, ROUND(AVG(popularity), 2) AS avg_popularity, COUNT(*) AS total_songs
FROM spotify_liked_songs_data
GROUP BY artist
HAVING COUNT(*) >= 3
ORDER BY avg_popularity DESC
LIMIT 10;

--  Artists with the longest average song duration
SELECT artist, ROUND(AVG(duration_ms)/60000.0, 2) AS avg_duration_min
FROM spotify_liked_songs_data
GROUP BY artist
HAVING COUNT(*) > 2
ORDER BY avg_duration_min DESC
LIMIT 10;

--  Popularity distribution buckets
SELECT 
    CASE 
        WHEN popularity >= 80 THEN '🔥 Very Popular'
        WHEN popularity BETWEEN 60 AND 79 THEN '⭐ Popular'
        WHEN popularity BETWEEN 40 AND 59 THEN '🙂 Moderate'
        ELSE '💤 Less Known'
    END AS popularity_category,
    COUNT(*) AS track_count
FROM spotify_liked_songs_data
GROUP BY popularity_category
ORDER BY track_count DESC;

--  Average popularity per release year
SELECT release_year, ROUND(AVG(popularity), 2) AS avg_popularity
FROM spotify_liked_songs_data
GROUP BY release_year
ORDER BY release_year;

--  Explicit songs by artist (Top 10)
SELECT artist, COUNT(*) AS explicit_count
FROM spotify_liked_songs_data
WHERE explicit = TRUE
GROUP BY artist
ORDER BY explicit_count DESC
LIMIT 10;

--  Artists with most collaborations (multiple artists in field)
SELECT artist, COUNT(*) AS collab_count
FROM spotify_liked_songs_data
WHERE artist LIKE '%,%'
GROUP BY artist
ORDER BY collab_count DESC
LIMIT 10;

--  Total tracks per album (Albums with > 1 liked song)
SELECT album_name, COUNT(*) AS liked_song_count
FROM spotify_liked_songs_data
GROUP BY album_name
HAVING COUNT(*) > 1
ORDER BY liked_song_count DESC;

--  Average popularity difference between explicit and clean songs
SELECT 
    explicit,
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM spotify_liked_songs_data
GROUP BY explicit;

--  Artists dominating by percentage of total duration
SELECT 
    artist,
    ROUND(SUM(duration_ms) * 100.0 / (SELECT SUM(duration_ms) FROM spotify_liked_songs_data), 2) AS duration_share_percent
FROM spotify_liked_songs_data
GROUP BY artist
ORDER BY duration_share_percent DESC
LIMIT 10;

--  Songs released before 2000 still liked
SELECT name, artist, release_year
FROM spotify_liked_songs_data
WHERE release_year < 2000
ORDER BY popularity DESC
LIMIT 10;

