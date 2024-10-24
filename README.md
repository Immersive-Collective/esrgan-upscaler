# ESRGAN Upscaler

This repository contains an implementation of Real-ESRGAN, a practical algorithm for super-resolution of images.

## Prerequisites

- Python 3.8+
- `pip` (Python package manager)
- Virtual environment (`venv`)

## Setup

1. **Clone the repository:**

   ```bash
   git clone git@github.com:Immersive-Collective/esrgan-upscaler.git
   cd esrgan-upscaler
   ```

2. **Create and activate a virtual environment:**

   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install the dependencies:**

   Install all required Python packages from `requirements.txt`:

   ```bash
   pip install -r requirements.txt
   ```

4. **Download the pre-trained model weights:**

   Download the model weights from [Real-ESRGAN releases](https://github.com/xinntao/Real-ESRGAN/releases) and place them in the `weights/` folder (make sure the folder exists):

   Example:

   ```bash
   mkdir weights
   wget -P weights/ https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.1/RealESRGAN_x2plus.pth
   ```

## Running the Example

To run the model on an example image:

```bash
python inference_realesrgan.py -n RealESRGAN_x2plus -i input/test/frame_0074.png --fp32 -o input/test/frame_0074-out.png
```

- `-n`: Specifies the model to use (`RealESRGAN_x2plus` in this case).
- `-i`: Input image path.
- `--fp32`: Use full precision (optional).
- `-o`: Output image path.

## Notes

- Ensure the model weights are placed correctly in the `weights/` folder.
- Modify the `-i` and `-o` parameters to use your own input/output paths.
```

