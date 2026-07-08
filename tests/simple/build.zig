const std = @import("std");
const bundler = @import("bundler");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const my_bundle = bundler.create(b, b.path("assets"));
    const other_bundle = bundler.create(b, b.path("other-assets"));

    const exe = b.addExecutable(.{
        .name = "compress",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addImport("my_bundle", my_bundle);
    exe.root_module.addImport("other_bundle", other_bundle);

    const run_step = b.step("run", "run");

    const run_exe = b.addRunArtifact(exe);
    run_step.dependOn(&run_exe.step);
}
