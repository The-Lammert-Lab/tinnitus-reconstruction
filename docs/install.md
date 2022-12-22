# Installation and setup guide

For most users, it is best to install the MATLAB toolbox from the latest [Release](https://github.com/alec-hoyland/tinnitus-project/releases#latest).
For development, clone the following projects:

* [mtools](https://github.com/sg-s/srinivas.gs_mtools)
* [tinnitus-project](https://github.com/alec-hoyland/tinnitus-project)
* [ReadYAML](https://github.com/llerussell/ReadYAML) (only for legacy use)
* [yaml](https://github.com/MartinKoch123/yaml)

Then add the functions to your path. The commands should look similar to this:

```matlab
addpath ~/code/yaml
addpath ~/code/srinivas.gs_mtools/src
savepath
```

Finally, in the `tinnitus-project/code` directory,
run `setup.m` as a MATLAB script.