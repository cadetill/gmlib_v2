# GMLib VCL Rectangle Lab

Demo for testing TGMRectangle support in GMLib v2.

## Features

- Activate Map with Google Maps API
- Add Rectangle overlays with configurable bounds (North, South, East, West)
- Clear all rectangles
- Zoom to rectangle

## Usage

1. Compile the project
2. Run the executable
3. Click "Activate Map" to load Google Maps
4. Click "Apply Rectangle" to add a sample rectangle
5. The rectangle will appear centered around coordinates:
   - North: 33.685
   - South: 33.671
   - East: -116.234
   - West: -116.251
6. Click "Zoom to rectangle" to fit the viewport to the sample bounds

## API Key

Set the `GOOGLE_MAPS_API_KEY` environment variable to your Google Maps API key before running.
