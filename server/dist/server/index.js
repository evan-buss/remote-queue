"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const os = require("os");
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });
wss.on('connection', (ws) => {
    ws.on('message', (message) => {
        // Handle incoming messages
        router(message, ws);
        // Broadcast to all clients
        // wss.clients.forEach((client: WebSocket) => {
        //     if (client !== ws && client.readyState === WebSocket.OPEN) {
        //         client.send(message);
        //     }
        // });
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
function router(message, ws) {
    switch (message.toLowerCase()) {
        case "test":
            console.log("recieved" + message);
            break;
        default:
            break;
    }
}
// Type "Hello World" then press enter.
// var robot = require("robotjs");
// setTimeout(() => {
//     // Type "Hello World".
//     // robot.typeString("Hello World");
//     // // Press enter.
//     // robot.keyTap("enter");
//     robot.moveMouse(150, 100);
//     robot.mouseToggle("down");
//     // robot.dragMouse(1000, 1000);
//     robot.moveMouseSmooth(1000, 1000);
//     robot.mouseToggle("up");
// }, 3000);
//# sourceMappingURL=index.js.map