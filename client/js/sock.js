// socket stuff.
function setupSocket() {
	ws = new WebSocket("ws://120.79.91.100:8002/ws")

	ws.onopen = function()
	{
        player = playerSettings;
        player.name = global.playerName;
        player.screenWidth = global.screenWidth;
        player.screenHeight = global.screenHeight;
        player.target = window.canvas.target;
        global.player = player;
        ws.emit('enter',{name:global.playerName});
	};

	ws.onmessage = function(evt)
	{
	  console.log(evt.data)
	  var o = JSON.parse(evt.data)
	  var f = ws.handlers.get(o.cmd)
	  f(o.data)
	};

	ws.onclose = function(evt)
	{
	  console.log("WebSocketClosed!");
	};

	ws.onerror = function(evt)
	{
	  console.log("WebSocketError!");
	};

	ws.handlers = new Map()
	
	ws.on = function(cmd,fun){
		ws.handlers.set(cmd,fun)
	}
	
	ws.emit = function(cmd,data){
		var o = {}
		o["cmd"] = cmd
		o["data"] = data
		ws.send(JSON.stringify(o))
	}
	
	// Handle ping.
    ws.on('pongcheck', function () {
        var latency = Date.now() - global.startPingTime;
        debug('Latency: ' + latency + 'ms');
        window.chat.addSystemLine('Ping: ' + latency + 'ms');
    });

    // Handle connection.
    ws.on('welcome', function (playerSettings) {
        
        global.gameStart = true;
        global.gameWidth = data.gameWidth;
        global.gameHeight = data.gameHeight;
		
		users = data.userList;
        foods = data.foodList;
        viruses = data.virusList;
        fireFood = data.massList;
        resize();

        debug('Game started at: ' + global.gameStart);
        window.chat.player = player;
        window.chat.addSystemLine('Connected to the game!');
        window.chat.addSystemLine('Type <b>-help</b> for a list of commands.');
        if (global.mobile) {
            document.getElementById('gameAreaWrapper').removeChild(document.getElementById('chatbox'));
        }
		c.focus();
    });

    ws.on('playerDied', function (data) {
        window.chat.addSystemLine('{GAME} - <b>' + (data.name.length < 1 ? 'An unnamed cell' : data.name) + '</b> was eaten.');
    });

    ws.on('playerDisconnect', function (data) {
        window.chat.addSystemLine('{GAME} - <b>' + (data.name.length < 1 ? 'An unnamed cell' : data.name) + '</b> disconnected.');
    });

    ws.on('playerJoin', function (data) {
        window.chat.addSystemLine('{GAME} - <b>' + (data.name.length < 1 ? 'An unnamed cell' : data.name) + '</b> joined.');
    });

    ws.on('leaderboard', function (data) {
        leaderboard = data;
        var status = '<span class="title">Leaderboard</span>';
        for (var i = 0; i < 10; i++) {
			if (typeof(leaderboard[i])=="undefined") {
				break
			}
            status += '<br/>';
			console.log(player)
            if (player != undefined && leaderboard[i].id == player.id){
                if(leaderboard[i].name.length !== 0)
                    status += '<span class="me">' + (i + 1) + '. ' + leaderboard[i].name + "</span>";
                else
                    status += '<span class="me">' + (i + 1) + ". An unnamed cell</span>";
            } else {
                if(leaderboard[i].name.length !== 0)
                    status += (i + 1) + '. ' + leaderboard[i].name;
                else
                    status += (i + 1) + '. An unnamed cell';
            }
        }
        //status += '<br />Players: ' + data.players;
        document.getElementById('status').innerHTML = status;
    });

    ws.on('serverMSG', function (data) {
        window.chat.addSystemLine(data);
    });

    // Chat.
    ws.on('serverSendPlayerChat', function (data) {
        window.chat.addChatLine(data.sender, data.message, false);
    });

    // Handle movement.
    ws.on('serverTellPlayerMove', function (userData) {
        var playerData;
        for(var i =0; i< userData.length; i++) {
            if(typeof(userData[i].id) == "undefined") {
                playerData = userData[i];
                i = userData.length;
            }
        }
        if(global.playerType == 'player') {
            var xoffset = player.x - playerData.x;
            var yoffset = player.y - playerData.y;

            player.x = playerData.x;
            player.y = playerData.y;
            player.hue = playerData.hue;
            player.massTotal = playerData.massTotal;
            player.cells = playerData.cells;
            player.xoffset = isNaN(xoffset) ? 0 : xoffset;
            player.yoffset = isNaN(yoffset) ? 0 : yoffset;
        }
        users = userData;
    });
	
    // Death.
    ws.on('RIP', function () {
        global.gameStart = false;
        global.died = true;
        window.setTimeout(function() {
            document.getElementById('gameAreaWrapper').style.opacity = 0;
            document.getElementById('startMenuWrapper').style.maxHeight = '1000px';
            global.died = false;
            if (global.animLoopHandle) {
                window.cancelAnimationFrame(global.animLoopHandle);
                global.animLoopHandle = undefined;
            }
        }, 2500);
    });

    ws.on('kick', function (data) {
        global.gameStart = false;
        reason = data;
        global.kicked = true;
        socket.close();
    });

    ws.on('virusSplit', function (virusCell) {
        socket.emit('2', virusCell);
        reenviar = false;
    });
}
