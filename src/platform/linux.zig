const std = @import("std");

pub fn readPrettyOsName(allocator: std.mem.Allocator) !?[]const u8 {
    const data = readSmallFile(allocator, "/etc/os-release", 16 * 1024) catch return null;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (!std.mem.startsWith(u8, line, "PRETTY_NAME=")) continue;
        var value = line["PRETTY_NAME=".len..];
        value = std.mem.trim(u8, value, "\"");
        return try allocator.dupe(u8, value);
    }
    return null;
}

pub fn readKernelVersion(allocator: std.mem.Allocator) !?[]const u8 {
    const value = readSmallFile(allocator, "/proc/sys/kernel/osrelease", 1024) catch return null;
    return try allocator.dupe(u8, std.mem.trim(u8, value, " \t\r\n"));
}

pub fn readCpuModel(allocator: std.mem.Allocator) !?[]const u8 {
    const data = readSmallFile(allocator, "/proc/cpuinfo", 256 * 1024) catch return null;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (!std.mem.startsWith(u8, line, "model name")) continue;
        const idx = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const model = std.mem.trim(u8, line[idx + 1 ..], " \t");
        return try allocator.dupe(u8, model);
    }
    return null;
}

pub fn readMemTotalMiB(allocator: std.mem.Allocator) !?u64 {
    const data = readSmallFile(allocator, "/proc/meminfo", 16 * 1024) catch return null;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (!std.mem.startsWith(u8, line, "MemTotal:")) continue;
        var parts = std.mem.tokenizeAny(u8, line, " \t");
        _ = parts.next();
        const number_text = parts.next() orelse return null;
        const kib = std.fmt.parseInt(u64, number_text, 10) catch return null;
        return kib / 1024;
    }
    return null;
}

pub fn readUptimeSeconds(allocator: std.mem.Allocator) !?u64 {
    const data = readSmallFile(allocator, "/proc/uptime", 256) catch return null;
    var parts = std.mem.tokenizeScalar(u8, data, ' ');
    const first = parts.next() orelse return null;
    const dot = std.mem.indexOfScalar(u8, first, '.');
    const integer_part = if (dot) |idx| first[0..idx] else first;
    return std.fmt.parseInt(u64, integer_part, 10) catch null;
}

fn readSmallFile(allocator: std.mem.Allocator, path: []const u8, max_len: usize) ![]u8 {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    return try file.readToEndAlloc(allocator, max_len);
}
