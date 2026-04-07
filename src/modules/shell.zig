const std = @import("std");

// Shell 模块：读取当前 SHELL 环境变量。
pub fn collect(allocator: std.mem.Allocator) ![]const u8 {
    const shell = std.process.getEnvVarOwned(allocator, "SHELL") catch return error.Unavailable;
    return shell;
}
