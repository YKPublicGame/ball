local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
local cjson = require "cjson"

local game
local id2player = {}
local wss = {}

local ws_port = ...

local H = {}

function H.on_open(ws)
    print(string.format("%d::open", ws.id))
    local playerid = skynet.call(game,"lua","enter",skynet.self(),ws.id,"test")
    id2player[ws.id] = playerid
    wss[ws.id] = ws
end

function H.on_message(ws, message)
    skynet.error("recv message")
    print(string.format("%d receive:%s", ws.id, message))
    local msg = cjson.decode(message)
    local playerid = id2player[ws.id]
    if msg then
        local retmsg = skynet.call(game,"lua","msg",playerid,msg.cmd,msg.data)
        if retmsg then
            ws:send_text(cjson.encode(retmsg))
        end
    end
    --    ws:close()
end

function H.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    if code then
        if header.upgrade == "websocket" then
            local ws = websocket.new(id, header, H)
            print("start")
            ws:start()
        end
    end
end

local CMD = {}

function CMD.send(fd,msg)
    local ws = wss[fd]
    if not ws then
        return
    end

    ws:send_text(cjson.encode(msg))
end

skynet.start(function()
    local address = "0.0.0.0:"..ws_port
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       handle_socket(id)
    end)

    skynet.dispatch("lua",function(session,source,cmd,...)
        local f = CMD[cmd]
        if session ~= 0 then
            skynet.ret(skynet.pack(f(...)))
        else
            f(...)
        end
    end)

    game = skynet.newservice("game")
end)
