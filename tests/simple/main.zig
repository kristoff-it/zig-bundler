const std = @import("std");
const my_bundle = @import("my_bundle");
const other_bundle = @import("other_bundle");

pub fn main(init: std.process.Init) !void {
    const data = try my_bundle.extract(init.arena.allocator());
    const other_data = try other_bundle.extract(init.arena.allocator());

    std.debug.print(
        \\A: '{s}'
        \\B: '{s}'
        \\C: '{s}'
        \\
        \\({}) ({})
        \\
        \\
    , .{
        my_bundle.files.@"A.txt".get(data),
        my_bundle.files.@"B.txt".get(data),
        my_bundle.files.@"C.txt".get(data),
        my_bundle.size_compressed,
        my_bundle.size_extracted,
    });

    std.debug.print(
        \\A: '{s}'
        \\B: '{s}'
        \\C: '{s}'
        \\
        \\({}) ({})
        \\
        \\
    , .{
        other_bundle.files.@"A.txt".get(other_data),
        other_bundle.files.@"B.txt".get(other_data),
        other_bundle.files.@"C.txt".get(other_data),
        other_bundle.size_compressed,
        other_bundle.size_extracted,
    });
}
