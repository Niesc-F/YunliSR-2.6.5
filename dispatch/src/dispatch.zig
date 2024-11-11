const std = @import("std");
const httpz = @import("httpz");
const protocol = @import("protocol");
const Base64Encoder = @import("std").base64.standard.Encoder;

pub fn onQueryDispatch(_: *httpz.Request, res: *httpz.Response) !void {
    std.log.debug("onQueryDispatch", .{});

    var proto = protocol.DispatchRegionData.init(res.arena);

    proto.retcode = 0;
    try proto.region_list.append(.{
        .name = .{ .Const = "YunliSR-2.6.5" },
        .display_name = .{ .Const = "YunliSR-2.6.5" },
        .env_type = .{ .Const = "2" },
        .title = .{ .Const = "YunliSR-2.6.5" },
        .dispatch_url = .{ .Const = "http://127.0.0.1:21000/query_gateway" },
    });

    const data = try proto.encode(res.arena);
    const size = Base64Encoder.calcSize(data.len);
    const output = try res.arena.alloc(u8, size);
    _ = Base64Encoder.encode(output, data);

    res.body = output;
}

pub fn onQueryGateway(_: *httpz.Request, res: *httpz.Response) !void {
    std.log.debug("onQueryGateway", .{});

    var proto = protocol.Gateserver.init(res.arena);

    proto.retcode = 0;
    proto.port = 23301;
    proto.ip = .{ .Const = "127.0.0.1" };
    //proto.ifix_version = .{ .Const = "0" };
    proto.lua_version = .{ .Const = "8373879" };
    proto.lua_url = .{ .Const = "https://autopatchcn.bhsr.com/lua/BetaLive/output_8373879_2195928a1876" };
    proto.asset_bundle_url = .{ .Const = "https://autopatchcn.bhsr.com/asb/BetaLive/output_8373375_fe8534d45033" };
    proto.ex_resource_url = .{ .Const = "https://autopatchcn.bhsr.com/design_data/BetaLive/output_8397887_2bec65c08d76" };
    
    proto.unk1 = true;
    proto.unk2 = true;
    proto.unk3 = true;
    proto.unk4 = true;
    proto.unk5 = true;
    proto.unk6 = true;
    proto.unk7 = true;
    proto.unk8 = true;
    proto.unk10 = true;
    proto.DEPJHGIBFIE = true;
    proto.LKKCKCCEEMJ = true;
    proto.NHEHAJGMJNJ = true;
    proto.BDKOGPCLHIN = true;
    proto.MKEHGPIEPGF = true;
    proto.IOPMOLBOHKL = true;


    const data = try proto.encode(res.arena);
    const size = Base64Encoder.calcSize(data.len);
    const output = try res.arena.alloc(u8, size);
    _ = Base64Encoder.encode(output, data);

    res.body = output;
}