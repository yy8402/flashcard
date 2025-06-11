from fastapi import FastAPI
from pydantic import BaseModel
from diffusers import StableDiffusionPipeline
import torch
import logging
import os
from fastapi.responses import FileResponse
import re

pipe = StableDiffusionPipeline.from_pretrained("/model", torch_dtype=torch.float16)
pipe.to("cuda")

app = FastAPI()

num_steps = 20
dir_path = "/app/output"
if not os.path.exists(dir_path):
    os.makedirs(dir_path)

class Request(BaseModel):
    prompt: str

def callback(step: int, timestep: int, latents, logger, num_steps):
    logger.info(f"Step {step+1}/{num_steps}, Timestep: {timestep}")
    _ = latents  # Access latents to avoid unused variable warning

@app.post("/generate")
def generate(req: Request):

    # Set up logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    pipe.scheduler.set_timesteps(num_steps)
    width = getattr(req, "width", 512)
    height = getattr(req, "height", 512)

    image = pipe(
        req.prompt,
        num_inference_steps=num_steps,
        width=width,
        height=height,
        callback=lambda step, timestep, latents: callback(step, timestep, latents, logger, num_steps),
        callback_steps=1
    ).images[0]

    image_id = re.sub(r'\W+', '_', req.prompt)
    image_path = f"{dir_path}/{image_id}.png"
    image.save(image_path)
    return {"image_id": image_id}

@app.get("/image")
def get_image(id: str):
    image_path = f"{dir_path}/{id}.png"
    if os.path.exists(image_path):
        return FileResponse(image_path, media_type="image/png", filename=os.path.basename(image_path))
    else:
        return {"error": "Image not found."}