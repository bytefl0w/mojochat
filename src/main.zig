const std = @import("std");
const net = std.net;

pub fn handleConnection(conn: net.StreamServer.Connection, stdo: anytype) !void {
    var buf: [300]u8 = undefined;

    var bytes = try conn.stream.read(&buf);
    _ = try conn.stream.write("[+] Hello from server!");
    try stdo.print("[+] Received from client: {s}\n", .{buf[0..bytes]});

    defer conn.stream.close();
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[+] Hello from Mojochat!\n", .{});

    // StreamServer will allow the server to stream in
    // connections and read and write to and from a
    // client.
    var server = net.StreamServer.init(.{
        .reuse_port = true,
        .reuse_address = true,
    });
    defer {
        server.close();
        server.deinit();
    }

    // Start listening in on a specific address
    const address = try net.Address.resolveIp("0.0.0.0", 3000);
    try server.listen(address);
    try stdout.print("[+] Server listening on {}\n", .{server.listen_address});

    while (true) {
        const conn = try server.accept();
        _ = try std.Thread.spawn(.{}, handleConnection, .{ conn, stdout });
    }
}
