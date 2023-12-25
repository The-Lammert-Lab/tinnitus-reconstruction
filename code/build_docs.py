# Adapted from xolotl project for use in tinnitus project.
# NB 6/3/22

import os
from pathlib import Path
from glob import glob
from shutil import copyfile
from comment2docs import comment2docs

# Identify path to git root (i.e., `.../tinnitus-project`)
# Make sure initial glob begins at said root dir.
curr_dir = os.getcwd()

# Repo used to be tinnitus-project, now tinnitus-reconstruction.
if curr_dir.endswith('tinnitus-project') or curr_dir.endswith('tinnitus-reconstruction'):
    root_pth = '.'
else:
    split_dir = curr_dir.split('/')
    root_ind = [ind for ind, subdir in enumerate(split_dir) if subdir == 'tinnitus-project' or subdir == 'tinnitus-reconstruction']
    root_pth = '/'.join(split_dir[:root_ind[0]+1])

# Set vars as None initially
foldername = None
prev_foldername = None

# Loop through every folder and every file within each folder
for i, file in enumerate(sorted(glob(f"{root_pth}/code/**/*.m", recursive=True), key = str.lower)):

    if foldername is not None:
        prev_foldername = foldername

    # Check if file is a class
    if file.find("@") > 0:
        foldername = os.path.basename(os.path.dirname(file))[1:]
        header_file =  f"{root_pth}/docs/stimgen/{foldername}-head.md"
        doc_file = f"{root_pth}/docs/stimgen/{foldername}.md"
    else:
        foldername = os.path.basename(os.path.dirname(file))
        header_file = f"{root_pth}/docs/{foldername}-head.md"
        doc_file = f"{root_pth}/docs/{foldername}.md"

    # Only write documentation if header file exists (is pre-written)
    if not os.path.exists(header_file):
        print(f"[ABORT] Can't find header {header_file}, skipping...")
        continue
        
    # Write header file at top of current docs
    if prev_foldername is not None and prev_foldername != foldername:
        first = True
        copyfile(header_file, doc_file)
        print(f"[OK] Generating docs for: {foldername}")
    else:
        first = False

    out_file = open(doc_file, "a+")
    comment2docs(Path(file).stem, file, out_file, first, root_pth)
