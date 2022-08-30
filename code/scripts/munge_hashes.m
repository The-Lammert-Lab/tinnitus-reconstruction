config_files = dir("config*.yaml");

hashes = cell(length(config_files), 1);

for ii = 1:length(config_files)
    config_file = config_files(ii).name;
    hashes{ii} = get_hash(parse_config(config_file));
    corelib.verb(true, 'munge_hashes', ['config is: ', config_file])
    corelib.verb(true, 'munge_hashes', ['hash is: ', hashes{ii}])
end



