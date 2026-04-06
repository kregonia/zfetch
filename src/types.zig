const std = @import("std");

pub const OutputMode = enum {
    text,
    json,
};

pub const ModuleStatus = enum {
    ok,
    unavailable,
    unsupported,
};

pub const ModuleResult = struct {
    name: []const u8,
    value: []const u8,
    status: ModuleStatus,
};

pub const Config = struct {
    output_mode: OutputMode = .text,
    color: bool = true,
    selected_modules: ?[][]const u8 = null,

    pub fn wantsModule(self: Config, name: []const u8) bool {
        if (self.selected_modules) |selected| {
            for (selected) |item| {
                if (std.mem.eql(u8, item, name)) return true;
            }
            return false;
        }
        return true;
    }
};

