#!/bin/bash

# Check if input arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_video"
    exit 1
fi

input_video=$1
base_name=$(basename "$input_video")
output_dir=$(dirname "$input_video")

# Create necessary directories for frames and upscaled frames
mkdir -p frames
mkdir -p upscaled_frames

# Step 1: Extract frames from the input video
ffmpeg -i "$input_video" frames/frame_%04d.png

# Step 2: Process each frame with Real-ESRGAN
for frame in frames/*.png; do
    frame_base=$(basename "$frame" .png)  # Get base name without extension
    output_frame="upscaled_frames/${frame_base}_out.png"  # Match the naming convention of your upscaled files

    # Check if the upscaled frame already exists
    if [ -f "$output_frame" ]; then
        echo "Upscaled frame $output_frame already exists. Skipping."
    else
        echo "Processing $frame"
        # Process the frame and save the result as "frame_XXXX_out.png" to match your existing files
        python inference_realesrgan.py -n RealESRGAN_x4plus -i "$frame" --fp32 --denoise_strength 0.3 --suffix out -o "upscaled_frames/"
    fi
done

# Step 3: Generate timestamp
timestamp=$(date +%Y%m%d%H%M)

# Step 4: Rebuild the upscaled frames into a video using the original framerate
fps=$(ffmpeg -i "$input_video" 2>&1 | sed -n "s/.*, \(.*\) fps.*/\1/p" | head -n 1)
output_video="${output_dir}/${base_name%.*}_x2-${timestamp}.${base_name##*.}"

# Ensure the output matches the naming convention of upscaled frames
ffmpeg -framerate "$fps" -i upscaled_frames/frame_%04d_out.png -c:v libx264 -pix_fmt yuv420p "$output_video"

echo "Upscaled video saved as $output_video"
