const std = @import("std");
const builtin = @import("builtin");
const linux = @import("../platform/linux.zig");
const macos = @import("../platform/macos.zig");

// Memory 模块：返回物理内存总量（MiB）。
pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    const mib = switch (builtin.os.tag) {
        .linux => (try linux.readMemTotalMiB(allocator)) orelse return error.Unavailable,
        .macos => (try macos.readMemTotalMiB(allocator)) orelse return error.Unavailable,
        else => return error.Unsupported,
    };
    return std.fmt.allocPrint(allocator, "{d} MiB", .{mib});
}
