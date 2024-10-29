#!/bin/bash

# Path to the HTML file
HTML_FILE="$1"

# Check if file exists
if [ ! -f "$HTML_FILE" ]; then
  echo "File not found: $HTML_FILE"
  exit 1
fi

# Extract image URLs
IMAGE_URLS=$(grep -oP '(https://db.butterflies.ai/storage/v1/object/public/ai-ig/images/sd/resized/[^"]+|https://img.butterflies.ai/f/[^"]+)' "$HTML_FILE")

# Check if any URLs were found
if [ -z "$IMAGE_URLS" ]; then
  echo "No image URLs found."
  exit 1
fi

# Print the found URLs for debugging
echo "Found image URLs:"
echo "$IMAGE_URLS"

# Loop through the URLs and download the images
while IFS= read -r IMG_URL; do
  if [[ $IMG_URL == *resized* ]]; then
    # Convert the URL to the new format
    NEW_URL="${IMG_URL//resized\//}"
    NEW_URL="${NEW_URL//_640.jpg/.png}/1280"
    EXT=".png"
  else
    # Use the original URL for direct download
    NEW_URL=$IMG_URL
    EXT=".webp"
  fi

  # Extract the unique identifier and filename from the URL
  UNIQUE_ID=$(echo "$IMG_URL" | grep -oP '([^/]+)(?=_[0-9]+\.jpg|_[0-9]+\.webp)' || echo $(basename "$IMG_URL" | cut -d. -f1))
  FILENAME="${UNIQUE_ID}${EXT}"

  # Download the image
  echo "Downloading $NEW_URL..."
  if curl -s -o "$FILENAME" "$NEW_URL"; then
    echo "Downloaded $FILENAME successfully."
  else
    echo "Error downloading $NEW_URL"
  fi
done <<< "$IMAGE_URLS"
