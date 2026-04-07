const std = @import("std");
const builtin = @import("builtin");
const linux = @import("../platform/linux.zig");

// OS 模块：返回系统发行版名称。
pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    return switch (builtin.os.tag) {
        // Linux 优先使用 PRETTY_NAME，失败时回退为 "Linux"。
        .linux => (try linux.readPrettyOsName(allocator)) orelse try allocator.dupe(u8, "Linux"),
        .macos => try allocator.dupe(u8, "macOS"),
        else => error.Unsupported,
    };
}
