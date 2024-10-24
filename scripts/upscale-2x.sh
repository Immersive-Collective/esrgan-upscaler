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
    echo "Processing $frame"
    python inference_realesrgan.py -n RealESRGAN_x4plus -i "$frame" --fp32 --denoise_strength 0.1 -o upscaled_frames/
done

# Step 3: Generate timestamp
timestamp=$(date +%Y%m%d%H%M)

# Step 4: Rebuild the upscaled frames into a video using the original framerate
fps=$(ffmpeg -i "$input_video" 2>&1 | sed -n "s/.*, \(.*\) fps.*/\1/p" | head -n 1)
output_video="${output_dir}/${base_name%.*}_x2-${timestamp}.${base_name##*.}"

ffmpeg -framerate "$fps" -i upscaled_frames/frame_%04d.png -c:v libx264 -pix_fmt yuv420p "$output_video"

echo "Upscaled video saved as $output_video"
