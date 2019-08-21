import * as express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import * as os from 'os';
import { CounterStrikeGlobalOffensive } from './games/csgo';
import { Game, ClientMessages, ServerMessages } from "./games/game";

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

wss.on('connection', (ws: WebSocket) => {
    const game: Game = new CounterStrikeGlobalOffensive(ws);

    ws.on('message', (message: String) => {
        // Handle incoming messages
        switch (message) {
            case ClientMessages.ACCEPT_GAME:
                game.acceptGame();
                break;
            case ClientMessages.DECLINE_GAME:
                game.declineGame();
                break;
            default:
                break;
        }
    });
    ws.on('close', (code: number, reason: string) => {
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
    console.log(`Server started on port 1337`)
});