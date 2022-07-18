# Adapted from xolotl project for use in tinnitus project.
# NB 6/3/22
# Only functional as written on macOS/Linux systems

import os
from glob import glob
from shutil import copyfile
from comment2docs import comment2docs

# Identify path to git root (i.e., `.../tinnitus-project`)
# Make sure initial glob begins at said root dir.
curr_dir = os.getcwd()

if curr_dir.endswith('tinnitus-project'):
    root_pth = '.'
else:
    split_dir = curr_dir.split('/')
    root_ind = [ind for ind, subdir in enumerate(split_dir) if subdir == 'tinnitus-project']
    root_pth = '/'.join(split_dir[:root_ind[0]+1])

for folder in sorted(glob(f"{root_pth}/code/*/")):
    for i, item in enumerate(sorted(glob(folder + "*.m") + glob(folder + "@*"), key = str.lower)):

        if item.find("@") > 0:
            classname = item.replace(f"{folder}@",'')
            header_file =  f"{root_pth}/docs/stimgen/{classname}-head.md"

            if not os.path.exists(header_file):
                print(f"[ABORT] Can't find header {header_file}, skipping...")
                continue
            
            # Extra loop for classes b/c MATLAB classes contained in separate folders.
            for j, file in enumerate(sorted(glob(f"{item}/*.m"))):

                first = False

                doc_file = f"{root_pth}/docs/stimgen/{classname}.md"

                if j == 0:
                    first = True
                    copyfile(header_file, doc_file)
                    print(f"[OK] Generating docs for class: {classname}")

                out_file = open(doc_file, "a+")

                filename = file.replace(f"{item}/",'')
                filename = filename.replace(".m",'')

                comment2docs(filename, file, out_file, first, root_pth)

        else:

            first = False

            foldername = os.path.basename(folder[:-1]) 
            header_file = f"{root_pth}/docs/{foldername}-head.md"

            if not os.path.exists(header_file):
                print(f"[ABORT] Can't find header for {foldername}, skipping...")
                continue


            doc_file = f"{root_pth}/docs/{foldername}.md"

            if i == 0:
                first = True
                copyfile(header_file, doc_file)
                print(f"[OK] Generating docs for folder: {foldername}")

            out_file = open(doc_file, "a+")

            filename = item.replace(f"{folder}",'')
            filename = filename.replace(".m",'')
            
            comment2docs(filename, item, out_file, first, root_pth)