const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

const compressed_data = @embedFile("compressed_data");

pub fn extract(gpa: Allocator) Allocator.Error![:0]u8 {
    var reader = Io.Reader.fixed(compressed_data);

    var decompressor_buf: [std.compress.flate.max_window_len]u8 = undefined;
    var decompressor = std.compress.flate.Decompress.init(&reader, .raw, &decompressor_buf);

    return decompressor.reader.allocRemainingAlignedSentinel(
        gpa,
        .unlimited,
        .@"64",
        0,
    ) catch return error.OutOfMemory;
}

// Everyting below this line is generated programmatically.
// Example:
//
// pub const size_compressed = 10;
// pub const size_extracted = 100;
// pub const files = struct {
//     pub const "sound.mp3": Loc = .{ .start = 0, .end = 90 };
//     pub const dirA = struct {
//         pub const "photo.jpg": Loc = .{ .start = 90, .end = 100 };
//     };
// };
