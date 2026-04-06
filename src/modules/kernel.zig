const std = @import("std");
const builtin = @import("builtin");
const linux = @import("../platform/linux.zig");
const macos = @import("../platform/macos.zig");

pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    return switch (builtin.os.tag) {
        .linux => (try linux.readKernelVersion(allocator)) orelse error.Unavailable,
        .macos => (try macos.readKernelVersion(allocator)) orelse error.Unavailable,
        else => error.Unsupported,
    };
}
