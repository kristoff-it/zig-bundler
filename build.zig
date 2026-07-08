const std = @import("std");
const LazyPath = std.Build.LazyPath;

// pub const Options = struct {
//     optimize: union(enum) {
//         /// Slower decompression but smallest size
//         size,
//         /// Fastest decompression but not smallest size
//         performance,
//         explicit: enum { deflate, lzma, brotli, zstd },
//     },
// };

pub fn create(project: *std.Build, dir: LazyPath) *std.Build.Module {
    const bundler_dep = project.dependencyFromBuildZig(@This(), .{
        .optimize = .ReleaseFast,
    });

    const bundler_exe = bundler_dep.artifact("bundler");
    const run_bundler = project.addRunArtifact(bundler_exe);
    const bundler_root_file = run_bundler.addOutputFileArg("bundler.zig");
    const compressed_data_file = run_bundler.addOutputFileArg("data.bin");
    run_bundler.addDirectoryArg(dir);

    const bundle_module = project.createModule(.{
        .root_source_file = bundler_root_file,
    });

    bundle_module.addImport("bundler", bundler_dep.module("bundler"));
    bundle_module.addImport("compressed_data", project.createModule(.{
        .root_source_file = compressed_data_file,
    }));

    return bundle_module;
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("bundler", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "bundler",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const test_step = b.step("test", "run tests");

    try setupSnapshotTests(b, test_step);
}

fn setupSnapshotTests(b: *std.Build, test_step: *std.Build.Step) !void {
    const diff = b.addSystemCommand(&.{
        "git",
        "diff",
        "--cached",
        "--exit-code",
    });
    diff.addDirectoryArg(b.path("tests/"));
    diff.setName("git diff tests/");
    test_step.dependOn(&diff.step);

    // We need to stage all of tests/ in order for untracked files to show up in
    // the diff. It's also not a bad automatism since it avoids the problem of
    // forgetting to stage new snapshot files.
    const git_add = b.addSystemCommand(&.{ "git", "add" });
    git_add.addDirectoryArg(b.path("tests/"));
    git_add.setName("git add tests/");
    diff.step.dependOn(&git_add.step);

    const tests_dir = try b.root.root_dir.handle.openDir(b.graph.io, "tests", .{ .iterate = true });
    var it = tests_dir.iterateAssumeFirstIteration();
    while (try it.next(b.graph.io)) |entry| {
        if (entry.kind != .directory) continue;

        const run_build = b.addSystemCommand(&.{ b.graph.zig_exe, "build", "run" });
        run_build.has_side_effects = true;
        run_build.setCwd(b.path("tests").path(b, entry.name));
        const out = run_build.captureStdErr(.{});
        const update_snap = b.addUpdateSourceFiles();
        update_snap.addCopyFileToSource(out, b.pathJoin(&.{
            b.root.root_dir.path.?,
            "tests",
            entry.name,
            "snapshot.txt",
        }));

        git_add.step.dependOn(&update_snap.step);
    }
}
