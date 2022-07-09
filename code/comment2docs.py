# Adapted from the xolotl project for use in tinnitus project.
# Generates documentation based on the comments within each file. 
# Intended to be used in conjunction with build_docs.py

def comment2docs(filename, file, out_file, a = -1):

    lines = tuple(open(file, 'r'))

    z = -1
    lastcomment = -1
    z_range_min = 0
    abstract = False
    fn_names = []

    # Abstract classes need to be handled differently because of multiple functions within the file.
    if 'abstract' in filename.lower():

        # Get line number and name of all functions within abstract class
        lines_stripped = tuple(map(str.strip,lines))
        fns = [(ind, line) for ind, line in enumerate(lines_stripped) if line.find('function') == 0]

        # Find exact function name
        for i in range(0, len(fns)):
            curr_fn = fns[i][1].replace(' ','')
            name_start = curr_fn.find('=') + 1
            name_end = curr_fn.find('(')
            fn_names.append(curr_fn[name_start:name_end].lower())

        # Identify beginning of documentation. 
        # If function name is not in comment, no docs will be written.
        for i in range(a + 1, len(lines)):
            thisline = lines[i].replace('#', '')
            thisline = thisline.replace(' ', '')
            thisline = thisline.replace('%', '')
            thisline = thisline.strip()

            if thisline.lower() in fn_names:
                abstract = True
                a = i
                break

    # Non-abstract class files are slightly different. 
    # If filename is not in comment, no docs will be written. 
    else:
        for i in range(0, len(lines)):
            thisline = lines[i].replace('#', '')
            thisline = thisline.replace(' ', '')
            thisline = thisline.replace('%', '')
            thisline = thisline.strip()

            if thisline.lower() == filename.lower():
                a = i
                break

    # Find end of documentation.
    # Author must add 'end of documentation' before any code-specific comments within scripts. 
    if abstract:
        z_range_min = a
        
    for i in range(z_range_min, len(lines)):
        thisline = lines[i].strip().lower()

        # Using line of the last comment prevents capturing accidental newlines after description ends.
        if thisline.find('%') == 0 and thisline != '%' and 'end of documentation' not in thisline:
            lastcomment = i

        if (thisline.find('function') == 0 or 
            (thisline.find('%') != 0 and thisline) or 
            'end of documentation' in thisline 
            ):
            z = lastcomment + 1
            break

    if (a < 0 or z < 0) and not abstract:
        print(f"No documentation for {filename}. Skipping...")
        return

    # Write the documentation to out_file.
    if a > -1 and z > a:
        out_file.write('\n\n')
        out_file.write('-------\n\n')

        format_link = False

        for i in range(a, z):
            thisline = lines[i]
            thisline = thisline.replace('%}', '')
            thisline = thisline.strip('%')
            thisline = thisline.lstrip()
            thisline = thisline.replace('XXXX', '    ')

            if not thisline:
                out_file.write('\n')
                continue

            # make the "see also" into a nice box
            if thisline.lower().find('see also') != -1:
                out_file.write('\n\n')
                thisline = '!!! info "See Also"\n'
                format_link = True
                out_file.write(thisline)
                continue

            # insert hyperlinks to other methods
            if thisline.find('* [') != -1 and format_link:
                # pre-formatted link, just write it
                out_file.write('    ' + thisline)

            elif format_link:
                # ok, this is a class method
                words = thisline.split('.')
                link_class = words[0]
                link_method = words[1]

                out_file.write('    * [' + thisline.strip() + '](../' +
                            link_class + '/#' + link_method.strip().lower() + ')\n')
            else:
                out_file.write(thisline)

        out_file.write('\n\n\n')

    # Recursion for multiple functions within abstract classes.
    if abstract and a < fns[-1][0]:
        comment2docs(filename, file, out_file, a)

    out_file.close()

if __name__ == '__main__':
    comment2docs()