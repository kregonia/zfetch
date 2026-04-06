const std = @import("std");

pub fn readKernelVersion(allocator: std.mem.Allocator) !?[]const u8 {
    return runAndTrim(allocator, &.{ "uname", "-r" });
}

pub fn readCpuModel(allocator: std.mem.Allocator) !?[]const u8 {
    return runAndTrim(allocator, &.{ "sysctl", "-n", "machdep.cpu.brand_string" });
}

pub fn readMemTotalMiB(allocator: std.mem.Allocator) !?u64 {
    const bytes_text = runAndTrim(allocator, &.{ "sysctl", "-n", "hw.memsize" }) orelse return null;
    const bytes = std.fmt.parseInt(u64, bytes_text, 10) catch return null;
    return bytes / (1024 * 1024);
}

pub fn readUptimeSeconds(allocator: std.mem.Allocator) !?u64 {
    const output = runAndTrim(allocator, &.{ "sysctl", "-n", "kern.boottime" }) orelse return null;
    const sec_tag = "sec = ";
    const sec_index = std.mem.indexOf(u8, output, sec_tag) orelse return null;
    const rest = output[sec_index + sec_tag.len ..];
    const comma = std.mem.indexOfScalar(u8, rest, ',') orelse return null;
    const boot_seconds = std.fmt.parseInt(i64, std.mem.trim(u8, rest[0..comma], " "), 10) catch return null;
    const now_seconds = std.time.timestamp();
    if (now_seconds < boot_seconds) return null;
    return @intCast(now_seconds - boot_seconds);
}

fn runAndTrim(allocator: std.mem.Allocator, argv: []const []const u8) ?[]const u8 {
    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
        .max_output_bytes = 128 * 1024,
    }) catch return null;

    if (result.term != .Exited or result.term.Exited != 0) return null;
    return std.mem.trim(u8, result.stdout, " \t\r\n");
}

