import * as express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import * as os from 'os';
import { Game, GameProfile } from "./game";

/**
 * Messages recieved from the client
 */
export const ClientMessages = {
    ACCEPT_GAME: "ACCEPT_GAME",
    DECLINE_GAME: "DECLINE_GAME"
}

/**
 * Messages that can be sent from the server
 */
export const ServerMessages = {
    CONNECT: "CONNECT",
    GAME_READY: "GAME_READY",
    QUEUE_FAILED: "QUEUE_FAILED",
    QUEUE_TIMEOUT: "QUEUE_TIMEOUT",
    QUEUE_WAIT: "QUEUE_WAIT",
    SUCCESS: "SUCCESS",
}

export class Server {
    app: any;
    server: http.Server;
    wss: WebSocket.Server;
    port: string;
    element: HTMLElement;
    game: Game;

    constructor(port: string) {
        this.port = port;
        this.app = express();
        this.server = http.createServer(this.app);
        this.wss = new WebSocket.Server({ server: this.server });
        this.game = new Game();

        this.wss.on('connection', (ws: WebSocket) => {
            console.log("PROFILE: " + this.game.profile.name);

            ws.send(JSON.stringify({ "message": ServerMessages.CONNECT, "body": this.game.profile.name }))
            this.game.setWS(ws);

            ws.on('message', (message: String) => {
                // Handle incoming messages
                switch (message) {
                    case ClientMessages.ACCEPT_GAME:
                        this.game.acceptGame();
                        break;
                    case ClientMessages.DECLINE_GAME:
                        this.game.declineGame();
                        break;
                    default:
                        break;
                }
            });
            ws.on('close', (code: number, reason: string) => {
                this.game.stopLoop();
                console.log(`Closed connection. Code: ${code}`);
            });
        });

        /**
         * Return the device's name
         */
        this.app.get('/poll', (req: express.Request, res: express.Response) => {
            res.send(os.hostname());
        });
    }

    startServer = () => {
        console.log("Starting Server");

        this.server.listen(this.port, () => {
            console.log(`Server started on port ${this.port}`)
        });
    }

    stopServer = () => {
        this.server.close();
        this.wss.close();
    }

    setGame = (game: GameProfile) => {
        this.game.setGame(game);
    }
}