const std = @import("std");
const builtin = @import("builtin");
const linux = @import("../platform/linux.zig");
const macos = @import("../platform/macos.zig");

// CPU 模块：返回 CPU 型号名称。
pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    return switch (builtin.os.tag) {
        .linux => (try linux.readCpuModel(allocator)) orelse error.Unavailable,
        .macos => (try macos.readCpuModel(allocator)) orelse error.Unavailable,
        else => error.Unsupported,
    };
}
