# Adapted from xolotl project for use in tinnitus project.
# NB 6/3/22
# Made to work with the layout of the tinnitus-project repository.

import os
from glob import glob
from shutil import copyfile
from comment2docs import comment2docs

# build_docs.py intended to be stored in `code` directory.
for folder in sorted(glob("./*/")):
    for i, item in enumerate(sorted(glob(folder + "*.m") + glob(folder + "@*"))):

        if item.find("@") > 0:
            classname = item.replace(f"{folder}@",'')
            header_file =  f"../docs/stimgen/{classname}-head.md"

            if not os.path.exists(header_file):
                print(f"[ABORT] Can't find header {header_file}, skipping...")
                continue
            
            # Extra loop for classes b/c MATLAB classes contained in separate folders.
            for j, file in enumerate(sorted(glob(f"{item}/*.m"))):

                first = False

                doc_file = f"../docs/stimgen/{classname}.md"

                if j == 0:
                    first = True
                    copyfile(header_file, doc_file)
                    print(f"[OK] Generating docs for class: {classname}")

                out_file = open(doc_file, "a+")

                filename = file.replace(f"{item}/",'')
                filename = filename.replace(".m",'')

                comment2docs(filename, file, out_file, first)

        else:

            first = False

            foldername = folder[:-1].replace('./','')
            header_file =  f"../docs/{foldername}-head.md"

            if not os.path.exists(header_file):
                print(f"[ABORT] Can't find header {header_file}, skipping...")
                continue

            doc_file = f"../docs/{foldername}.md"

            if i == 0:
                first = True
                copyfile(header_file, doc_file)
                print(f"[OK] Generating docs for folder: {foldername}")

            out_file = open(doc_file, "a+")

            filename = item.replace(f"{folder}",'')
            filename = filename.replace(".m",'')
            
            comment2docs(filename, item, out_file, first)