const std = @import("std");
const builtin = @import("builtin");
const linux = @import("../platform/linux.zig");
const macos = @import("../platform/macos.zig");

// Uptime 模块：返回系统连续运行时长。
pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    const seconds = switch (builtin.os.tag) {
        .linux => (try linux.readUptimeSeconds(allocator)) orelse return error.Unavailable,
        .macos => (try macos.readUptimeSeconds(allocator)) orelse return error.Unavailable,
        else => return error.Unsupported,
    };

    return formatDuration(allocator, seconds);
}

// 将秒数格式化为适合终端显示的短文本。
fn formatDuration(allocator: std.mem.Allocator, total_seconds: u64) ![]const u8 {
    const days = total_seconds / 86_400;
    const hours = (total_seconds % 86_400) / 3_600;
    const minutes = (total_seconds % 3_600) / 60;

    if (days > 0) return std.fmt.allocPrint(allocator, "{d}d {d}h {d}m", .{ days, hours, minutes });
    if (hours > 0) return std.fmt.allocPrint(allocator, "{d}h {d}m", .{ hours, minutes });
    return std.fmt.allocPrint(allocator, "{d}m", .{minutes});
}

test "format duration" {
    const allocator = std.testing.allocator;
    const text = try formatDuration(allocator, 9_061);
    defer allocator.free(text);
    try std.testing.expect(std.mem.eql(u8, text, "2h 31m"));
}
