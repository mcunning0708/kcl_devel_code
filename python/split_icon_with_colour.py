# -*- coding: utf-8 -*-
"""
Created on Thu Nov 13 10:11:45 2025

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
# Generate jagged vertical edge
jagged_points = []
step = height // 20
for y in range(0, height + step, step):
    x_offset = random.randint(-10, 10)
    jagged_points.append((width // 2 + x_offset, y))

# Create masks
mask_left = Image.new("L", (width, height), 0)
mask_right = Image.new("L", (width, height), 0)
draw_left = ImageDraw.Draw(mask_left)
draw_right = ImageDraw.Draw(mask_right)

left_polygon = [(0, 0)] + jagged_points + [(0, height)]
right_polygon = [(width, 0)] + jagged_points[::-1] + [(width, height)]
draw_left.polygon(left_polygon, fill=255)
draw_right.polygon(right_polygon, fill=255)

# Apply masks with coloured backgrounds
left_half = Image.new("RGB", (width, height), (255, 255, 0))      # Yellow
right_half = Image.new("RGB", (width, height), (173, 216, 230))  # Light Blue
left_half.paste(img, mask=mask_left)
right_half.paste(img, mask=mask_right)

# Crop to remove empty space
left_cropped = left_half.crop(mask_left.getbbox())
right_cropped = right_half.crop(mask_right.getbbox())

# Save as JPEG
left_cropped.save("laptop_left.jpg", "JPEG")
right_cropped.save("laptop_right.jpg", "JPEG")

print("Saved laptop_left.jpg (yellow background) and laptop_right.jpg (light blue background).")

#%%
# now combine the 2 images into a single with small gap between them 


# Open the two halves
left = Image.open("laptop_left.jpg")
right = Image.open("laptop_right.jpg")

# Define gap size (in pixels)
gap = 20

# Calculate combined dimensions
combined_width = left.width + right.width + gap
combined_height = max(left.height, right.height)

# Create a new blank image (white background)
combined = Image.new("RGB", (combined_width, combined_height), (255, 255, 255))

# Paste the halves with a gap
combined.paste(left, (0, 0))
combined.paste(right, (left.width + gap, 0))

# Save the combined image
combined.save("laptop_combined.jpg", "JPEG")

print("Combined image saved as laptop_combined.jpg with a gap of", gap, "pixels.")