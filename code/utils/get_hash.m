function h = get_hash(obj)
    h = DataHash(obj);
    h = h(1:8);
end