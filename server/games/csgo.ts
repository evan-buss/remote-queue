import * as robot from 'robotjs';
import * as WebSocket from 'ws';
import { Game, GameState, ServerMessages } from "./game";

export class CounterStrikeGlobalOffensive extends Game {
    private ws: WebSocket;
    private loopInterval: NodeJS.Timeout;
    private poppedTime: number = 0;
    // Delay to wait before checking for game load success
    private loadDelay: number = 2000;

    private userReacted: boolean = false;
    private isWaiting: boolean = false;

    constructor(ws: WebSocket) {
        super();
        this.NeutralState = new GameState(78, 264, "ffffff");
        this.ReadyState = new GameState(1053, 816, "53ad56");
        this.SuccessState = new GameState(1449, 256, "fffffd");

        this.timeToAccept = 10;
        this.updateInterval = 1;

        this.ws = ws;
        this.loopInterval = setInterval(this.loop, this.updateInterval * 1000);
    }

    stopLoop = (): void => {
        clearInterval(this.loopInterval);
    }

    /** 
     * Every [updateInterval] check if the given [readPos] is of color [readyColor]
     * if
    */
    loop = (): void => {
        // Wait until queue pops
        if (this.colorMatch(this.ReadyState.x, this.ReadyState.y, this.ReadyState.color)
            && !this.isWaiting) {

            this.ws.send(JSON.stringify({ "message": ServerMessages.GAME_READY, "body": this.timeToAccept }));
            this.poppedTime = Date.now();
            // Timeout the QUEUE if wait_time passes without user accepting
            setTimeout(() => {
                if (!this.userReacted) {
                    this.ws.send(JSON.stringify({ "message": ServerMessages.QUEUE_TIMEOUT }));
                    this.stopLoop();
                }
            }, this.timeToAccept * 1000);
        }
    }

    acceptGame = (): void => {

        this.userReacted = true;
        this.isWaiting = true;
        const remaining = (this.timeToAccept * 1000) - (Date.now() - this.poppedTime); // divide by 1000 for seconds

        console.log("REMAINING: " + remaining);

        // Wait until the wait time ends, check if color has changed
        setTimeout(() => {
            if (this.colorMatch(this.SuccessState.x, this.SuccessState.y, this.SuccessState.color)) {
                this.ws.send(JSON.stringify({ "message": ServerMessages.SUCCESS }));
            } else {
                this.ws.send(JSON.stringify({ "message": ServerMessages.QUEUE_FAILED }));

                // loop until neutral state is found
                while (this.colorMatch(this.ReadyState.x, this.ReadyState.y, this.ReadyState.color)) {
                    console.log("waiting for button to leave");
                }
                this.isWaiting = false;
            }
        }, remaining + this.loadDelay);

        // Click the Button
        robot.moveMouse(this.ReadyState.x, this.ReadyState.y);
        robot.mouseClick();

        this.ws.send(JSON.stringify({ "message": ServerMessages.QUEUE_WAIT }));
    }

    declineGame = (): void => {
        this.stopLoop();
        console.log("Declining game");
    }

    /**
     * Check if the color at a given [x], [y] matches the [targetColor]
     */
    colorMatch = (x: number, y: number, targetColor: string): boolean => {
        let currentColor: string = robot.getPixelColor(x, y);
        return targetColor == currentColor;
    }
}