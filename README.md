# Turnip-MV

Experimental Mesa Turnip builds for the **POCO F6**, Snapdragon 8s Gen 3 and Adreno 735.

## Important

The first artifact is a clean baseline, not yet an "optimized" driver. It is intended to validate the cloud build, ZIP format and compatibility with Winlator before any code-level changes are introduced.

## Build in GitHub Actions

1. Open the **Actions** tab.
2. Choose **Build Turnip MV**.
3. Press **Run workflow**.
4. Keep `mesa_ref` as `mesa-26.1.0` for the first run.
5. Wait for the build to finish.
6. Open the completed run and download `Turnip-MV-Baseline-R1` under **Artifacts**.
7. Extract the downloaded artifact once. Inside is the installable driver ZIP.

## Test protocol

Compare against the current known-good driver using the same:

- game and save/scene;
- resolution;
- DXVK version;
- Box64 preset;
- CPU affinity;
- frame-rate cap;
- test duration and ambient conditions.

Record average/minimum FPS, temperature after 10 and 20 minutes, visual errors, crashes and shader stutter.

## Safety

This project does not replace the Android system driver. Install only through a compatible Winlator/AdrenoTools driver selector. Keep a known-good driver available and delete the experimental package if Winlator crashes or rendering is corrupted.

## License

Project scripts: MIT. Mesa itself retains its upstream licenses.
