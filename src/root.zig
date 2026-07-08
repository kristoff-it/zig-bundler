pub const Loc = struct {
    start: usize,
    end: usize,

    pub fn size(loc: Loc) usize {
        return loc.end - loc.start;
    }

    pub fn get(loc: Loc, extracted_data: [:0]u8) [:0]u8 {
        return extracted_data[loc.start..loc.end :0];
    }
};
