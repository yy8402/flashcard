#!/bin/bash
set -e

# Set build context
PROJECT_DIR="."
images=(
    "image-api"
    "translate-api"
    "tts-api"
    "web-app"
)

# Build each service
for image in "${images[@]}"; do
    echo "Building $image..."
    docker build --platform=linux/amd64 -t "flashcard/$image" "${PROJECT_DIR}/$image"
    docker save -o "${image}.tar" "flashcard/$image"
done

echo "All images built successfully!"
