# -*- coding: utf-8 -*-
"""
Created on Thu Nov 13 09:35:40 2025

@author: k2585744
"""

import os

# Set the path to your folder
folder_path = '/path/to/your/folder'

# List all files and directories in the folder
files = os.listdir(folder_path)

# Print each file
for file in files:
    print(file)