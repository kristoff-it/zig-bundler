# zig-bundler

Compress and embed asset directories in your Zig executables.

## Usage
```
zig fetch --save git+https://github.com/kristoff-it/zig-bundler
```

In your `build.zig`:
```zig
const bundler = @import("bundler");

pub fn build(b: *std.Build) !void {
    //...
    const my_bundle = bundler.create(b, b.path("assets"));
    exe.root_module.addImport("my_bundle", my_bundle);
}
```

In your code:
```zig
const std = @import("std");
const my_bundle = @import("my_bundle");

pub fn main(init: std.process.Init) !void {
    const data = try my_bundle.extract(init.arena.allocator());
    std.debug.print(
        \\A: '{s}'
        \\B: '{s}'
        \\C: '{s}'
        \\
        \\compressed: {}
        \\extracted:  {}
        \\
    , .{
        my_bundle.files.@"A.txt".get(data),
        my_bundle.files.@"B.txt".get(data),
        my_bundle.files.@"C.txt".get(data),
        my_bundle.size_compressed,
        my_bundle.size_extracted,
    });
}
```

Bundler generates an ad-hoc Zig file during the build process, see `src/bundle_root_stub.zig`
to learn what's in a bundle (or use go to definition in your editor).


## Roadmap

- support for more compression algorithms and provide different trade-offs between size vs
  decompression speed

- ability to iterated the file tree at runtime

- ability to toggle things like alignment and null sentinels in each module


## Contributing

- Look for `contributor-friently` issues to get started.
- New features must be tested by modifying an existing snapshot test or adding a new one.
- No LLMs, thank you.


