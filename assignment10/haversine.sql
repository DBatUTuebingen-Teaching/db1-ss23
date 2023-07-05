CREATE OR REPLACE FUNCTION haversine(
  lat_p1 float,
  lon_p1 float,
  lat_p2 float,
  lon_p2 float
) RETURNS float AS $$
  SELECT 2 * 6371000 * asin(
    sqrt(
      sin(radians(lat_p2 - lat_p1) / 2) ^ 2 +
      cos(radians(lat_p1)) *
      cos(radians(lat_p2)) *
      sin(radians(lon_p2 - lon_p1) / 2) ^ 2
    )
  ) AS dist;
$$ LANGUAGE SQL IMMUTABLE;