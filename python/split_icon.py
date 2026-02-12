# -*- coding: utf-8 -*-
"""
Created on Thu Nov 13 09:27:12 2025

@author: k2585744
"""

#%%
from PIL import Image, ImageDraw
import random
import os

#%%
# Replace with your uploaded image file name
folder_path = r'\\wsl.localhost\ubuntu\home\k2585744\projects_wsl\python'
# input_image_path = r'\\wsl.localhost\ubuntu\home\k2585744\projects_wsl\python\ICON_laptop.jpg'
os.chdir(folder_path)
# List all files and directories in the folder
files = os.listdir(folder_path)

input_image_path = "ICON_laptop.jpg"
img = Image.open(input_image_path)
width, height = img.size

#%%
# Generate a jagged vertical edge
jagged_points = []
step = height // 20  # number of jagged segments
for y in range(0, height + step, step):
    x_offset = random.randint(-10, 10)
    jagged_points.append((width // 2 + x_offset, y))

# Create masks for left and right halves
mask_left = Image.new("L", (width, height), 0)
mask_right = Image.new("L", (width, height), 0)
draw_left = ImageDraw.Draw(mask_left)
draw_right = ImageDraw.Draw(mask_right)

# Draw polygons for left and right halves using jagged edge
left_polygon = [(0, 0)] + jagged_points + [(0, height)]
right_polygon = [(width, 0)] + jagged_points[::-1] + [(width, height)]
draw_left.polygon(left_polygon, fill=255)
draw_right.polygon(right_polygon, fill=255)

# Apply masks to original image
left_half = Image.new("RGB", (width, height))
right_half = Image.new("RGB", (width, height))
left_half.paste(img, mask=mask_left)
right_half.paste(img, mask=mask_right)

# Crop each half to remove empty space
left_bbox = mask_left.getbbox()
right_bbox = mask_right.getbbox()
left_cropped = left_half.crop(left_bbox)
right_cropped = right_half.crop(right_bbox)

#%%
# Save the two halves as separate .jpg files
left_cropped.save("laptop_left.jpg", "JPEG")
right_cropped.save("laptop_right.jpg", "JPEG")

print("Image split into two halves with jagged edge and saved as laptop_left.jpg and laptop_right.jpg.")
