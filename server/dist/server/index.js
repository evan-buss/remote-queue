"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const os = require("os");
const csgo_1 = require("./games/csgo");
const game_1 = require("./games/game");
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });
wss.on('connection', (ws) => {
    const game = new csgo_1.CounterStrikeGlobalOffensive(ws);
    ws.on('message', (message) => {
        // Handle incoming messages
        switch (message) {
            case game_1.ClientMessages.ACCEPT_GAME:
                game.acceptGame();
                break;
            case game_1.ClientMessages.DECLINE_GAME:
                game.declineGame();
                break;
            default:
                break;
        }
    });
    ws.on('close', (code, reason) => {
        game.stopInterval();
        console.log(`Closed connection. Code: ${code}`);
    });
});
/**
 * Return the device's name
 */
app.get('/poll', (req, res) => {
    res.send(os.hostname());
});
server.listen(process.env.PORT || 1337, () => {
    console.log(`Server started on port 1337`);
});
//# sourceMappingURL=index.js.map