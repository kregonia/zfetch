const std = @import("std");
const builtin = @import("builtin");
const linux = @import("../platform/linux.zig");

pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    return switch (builtin.os.tag) {
        .linux => (try linux.readPrettyOsName(allocator)) orelse try allocator.dupe(u8, "Linux"),
        .macos => try allocator.dupe(u8, "macOS"),
        else => error.Unsupported,
    };
}
