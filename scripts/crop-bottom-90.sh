#!/bin/bash

# Usage information
if [ $# -ne 1 ]; then
  echo "Usage: $0 <input_folder>"
  exit 1
fi

input_path="$1"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed. Please install ffmpeg and try again."
  exit 1
fi

# Determine if input is a directory or a single file
if [ -d "$input_path" ]; then
  input_folder="$input_path"
  output_folder="$input_folder/cropped"
elif [ -f "$input_path" ]; then
  input_folder=$(dirname "$input_path")
  output_folder="$input_folder/cropped"
else
  echo "Error: Input path '$input_path' does not exist."
  exit 1
fi

# Create output folder if it does not exist
if [ ! -d "$output_folder" ]; then
  echo "Creating output folder at '$output_folder'."
  mkdir -p "$output_folder" || { echo "Failed to create output folder '$output_folder'."; exit 1; }
fi

# Iterate over all .mp4 files in the input folder if it's a folder
if [ -d "$input_folder" ]; then
  for video_file in "$input_folder"/*.mp4; do
    # Check if any .mp4 files exist
    if [ ! -e "$video_file" ]; then
      echo "No .mp4 files found in the folder '$input_folder'."
      exit 1
    fi

    base_name=$(basename "$video_file" .mp4)
    output_file="$output_folder/${base_name}-c.mp4"

    echo "Processing '$video_file' and saving to '$output_file'..."

    # Crop the video, keeping audio intact
    ffmpeg -i "$video_file" -vf "crop=in_w:in_h*0.9:0:0" -c:a copy "$output_file" -y

    if [ $? -ne 0 ]; then
      echo "Error: Failed to crop video '$video_file'."
    else
      echo "Successfully cropped '$video_file'."
    fi
  done
else
  # Handle single file input
  video_file="$input_path"
  base_name=$(basename "$video_file" .mp4)
  output_file="$output_folder/${base_name}-c.mp4"

  echo "Processing '$video_file' and saving to '$output_file'..."

  # Crop the video, keeping audio intact
  ffmpeg -i "$video_file" -vf "crop=in_w:in_h*0.9:0:0" -c:a copy "$output_file" -y

  if [ $? -ne 0 ]; then
    echo "Error: Failed to crop video '$video_file'."
  else
    echo "Successfully cropped '$video_file'."
  fi
fi

echo "All videos processed."
