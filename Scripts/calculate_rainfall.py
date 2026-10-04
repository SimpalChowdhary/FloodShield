import xarray as xr
import geopandas as gpd
import pandas as pd
import numpy as np
from pathlib import Path

# ============================================================
# FLOODSHIELD - 2025 IMD RAINFALL PROCESSING
# ============================================================

# ---------- FILE PATHS ----------
PROJECT = Path(r"D:\my projects\major project\FloodShield")

RAINFALL_FILE = PROJECT / "gis-data" / "raw" / "rainfall" / "RF25_ind2025_rfp25.nc"

ZONES_FILE = PROJECT / "gis-data" / "processed" / "zones.geojson.gpkg"

OUTPUT_DIR = PROJECT / "gis-data" / "processed"

CSV_OUTPUT = OUTPUT_DIR / "zone_rainfall_2025.csv"

GEOJSON_OUTPUT = OUTPUT_DIR / "zone_rainfall_2025.geojson"


# ---------- CREATE OUTPUT DIRECTORY ----------
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print("FloodShield rainfall processing started...")
print("Rainfall file:", RAINFALL_FILE)
print("Zones file:", ZONES_FILE)


# ============================================================
# 1. READ IMD NETCDF
# ============================================================

print("\nReading IMD NetCDF...")

ds = xr.open_dataset(RAINFALL_FILE)

print("\nNetCDF information:")
print(ds)


# ============================================================
# 2. FIND THE RAINFALL VARIABLE
# ============================================================

# Show variables available in the NetCDF
print("\nVariables found:")

for name in ds.data_vars:
    print(" -", name, ds[name].dims, ds[name].shape)


# Usually the rainfall variable is the main variable.
# We automatically select the variable having the largest
# number of dimensions/data values.

rainfall_variable = max(
    ds.data_vars,
    key=lambda name: ds[name].size
)

rainfall = ds[rainfall_variable]

print("\nUsing rainfall variable:", rainfall_variable)
print("Dimensions:", rainfall.dims)
print("Shape:", rainfall.shape)


# ============================================================
# 3. FIND THE TIME/BAND DIMENSION
# ============================================================

# The IMD file should contain 365 daily observations.
# Find the dimension with approximately 365 entries.

time_dim = None

for dim in rainfall.dims:
    if rainfall.sizes[dim] in range(360, 367):
        time_dim = dim
        break

if time_dim is None:
    raise ValueError(
        "Could not identify the 365-day dimension. "
        f"Dimensions found: {rainfall.dims}"
    )

print("Time dimension:", time_dim)
print("Number of daily bands:", rainfall.sizes[time_dim])


# ============================================================
# 4. CONVERT INVALID VALUES TO NaN
# ============================================================

rainfall = rainfall.astype("float32")

# IMD datasets sometimes use negative values such as -999
# for missing/no-data cells.

rainfall = rainfall.where(rainfall >= 0)


# ============================================================
# 5. SUM 365 DAILY BANDS
# ============================================================

print("\nCalculating 2025 annual rainfall...")

annual_rainfall = rainfall.sum(
    dim=time_dim,
    skipna=True
)

print("Annual rainfall calculated.")


# ============================================================
# 6. IDENTIFY LATITUDE AND LONGITUDE
# ============================================================

lat_name = None
lon_name = None

for name in annual_rainfall.coords:
    name_lower = name.lower()

    if name_lower in ["lat", "latitude"]:
        lat_name = name

    if name_lower in ["lon", "longitude"]:
        lon_name = name


if lat_name is None or lon_name is None:
    raise ValueError(
        "Could not identify latitude/longitude coordinates.\n"
        f"Coordinates found: {list(annual_rainfall.coords)}"
    )

print("Latitude:", lat_name)
print("Longitude:", lon_name)


# ============================================================
# 7. CONVERT RAINFALL GRID TO DATAFRAME
# ============================================================

print("\nConverting rainfall grid...")

rainfall_df = annual_rainfall.to_dataframe(
    name="annual_rainfall_mm"
).reset_index()

# Remove missing values
rainfall_df = rainfall_df.dropna(
    subset=["annual_rainfall_mm"]
)

print(
    "Rainfall grid points:",
    len(rainfall_df)
)


# ============================================================
# 8. LOAD HYDERABAD WARDS
# ============================================================

print("\nReading Hyderabad ward boundaries...")

zones = gpd.read_file(ZONES_FILE)

print("Number of wards:", len(zones))

print("Ward columns:")
print(list(zones.columns))


# ============================================================
# 9. MAKE SURE WARDS USE WGS84
# ============================================================

if zones.crs is None:
    print("Ward CRS missing. Assuming EPSG:4326.")
    zones = zones.set_crs("EPSG:4326")

else:
    zones = zones.to_crs("EPSG:4326")


# ============================================================
# 10. CREATE RAINFALL POINTS
# ============================================================

print("\nCreating rainfall grid points...")

rainfall_points = gpd.GeoDataFrame(
    rainfall_df,
    geometry=gpd.points_from_xy(
        rainfall_df[lon_name],
        rainfall_df[lat_name]
    ),
    crs="EPSG:4326"
)


# ============================================================
# 11. CALCULATE RAINFALL FOR EACH WARD
# ============================================================

print("\nCalculating rainfall for each ward...")

results = []

for index, ward in zones.iterrows():

    ward_geometry = ward.geometry

    # Find rainfall grid points inside/intersecting the ward
    points_inside = rainfall_points[
        rainfall_points.geometry.intersects(ward_geometry)
    ]

    if len(points_inside) == 0:

        # If no grid point falls inside a small ward,
        # use the nearest rainfall grid point.

        distances = rainfall_points.geometry.distance(
            ward_geometry.centroid
        )

        nearest_index = distances.idxmin()

        rainfall_value = rainfall_points.loc[
            nearest_index,
            "annual_rainfall_mm"
        ]

        method = "nearest_grid_point"

    else:

        rainfall_value = points_inside[
            "annual_rainfall_mm"
        ].mean()

        method = "grid_points_mean"


    results.append({
        "ward": ward.get("ward", index),
        "annual_rainfall_mm": float(rainfall_value),
        "rainfall_method": method
    })


rainfall_results = pd.DataFrame(results)


# ============================================================
# 12. JOIN RESULTS TO WARD POLYGONS
# ============================================================

print("\nJoining rainfall values to wards...")

zones["ward"] = zones["ward"].astype(str)
rainfall_results["ward"] = rainfall_results["ward"].astype(str)

zones_rainfall = zones.merge(
    rainfall_results,
    on="ward",
    how="left"
)


# ============================================================
# 13. SAVE CSV
# ============================================================

print("\nSaving CSV...")

rainfall_results.to_csv(
    CSV_OUTPUT,
    index=False
)

print("CSV saved:")
print(CSV_OUTPUT)


# ============================================================
# 14. SAVE GEOJSON
# ============================================================

print("\nSaving GeoJSON...")

zones_rainfall.to_file(
    GEOJSON_OUTPUT,
    driver="GeoJSON"
)

print("GeoJSON saved:")
print(GEOJSON_OUTPUT)


# ============================================================
# 15. SHOW SAMPLE RESULTS
# ============================================================

print("\n==========================================")
print("FLOODSHIELD RAINFALL PROCESSING COMPLETE")
print("==========================================")

print("\nSample results:")

print(
    rainfall_results.head(10).to_string(index=False)
)

print("\nFiles created:")

print(CSV_OUTPUT)
print(GEOJSON_OUTPUT)