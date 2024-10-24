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

# Step 2: Get the total number of frames
total_frames=$(ls frames/*.png | wc -l)

# Function to calculate estimated time of completion
estimate_time() {
    local elapsed_time=$1
    local current_frame=$2
    local total_frames=$3
    remaining_frames=$((total_frames - current_frame))
    remaining_time=$(echo "$elapsed_time * $remaining_frames" | bc)
    end_time=$(date -j -v "+${remaining_time}S" +"%H:%M:%S")
    echo "Estimated time of completion: $end_time"
}

# Step 3: Process each frame with Real-ESRGAN
start_time=$(date +%s)
for frame in frames/*.png; do
    current_frame=$(basename "$frame" | sed 's/[^0-9]*//g')
    echo "Processing $frame ($current_frame/$total_frames)"
    
    # Process the frame and measure the time taken for each frame
    frame_start=$(date +%s)
    python inference_realesrgan.py -n RealESRGAN_x2plus -i "$frame" --fp32 -o upscaled_frames/
    frame_end=$(date +%s)
    
    frame_elapsed_time=$((frame_end - frame_start))
    
    # Estimate time and show real-time updates
    elapsed_time=$((frame_end - start_time))
    estimate_time $frame_elapsed_time $current_frame $total_frames
done

# Step 4: Generate timestamp for output video
timestamp=$(date +%Y%m%d%H%M)

# Step 5: Rebuild the upscaled frames into a video using the original framerate
fps=$(ffmpeg -i "$input_video" 2>&1 | sed -n "s/.*, \(.*\) fps.*/\1/p" | head -n 1)
output_video="${output_dir}/${base_name%.*}_x2-${timestamp}.${base_name##*.}"

ffmpeg -framerate "$fps" -i upscaled_frames/frame_%04d.png -c:v libx264 -pix_fmt yuv420p "$output_video"

echo "Upscaled video saved as $output_video"

