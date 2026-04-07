// 程序入口：将执行流程交给 app.run()。
const app = @import("app.zig");

pub fn main() !void {
    try app.run();
}
