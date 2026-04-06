const std = @import("std");

pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    const shell = std.process.getEnvVarOwned(allocator, "SHELL") catch return error.Unavailable;
    return shell;
}

