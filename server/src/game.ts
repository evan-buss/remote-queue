import * as robot from 'robotjs';
import * as WebSocket from 'ws';
import { ServerMessages } from './server';


/** GameProfile stores info for each game type */
export interface GameProfile {
    name: string;
    queueDuration: number;
    queueState: GameState;
    successState: GameState;
}


export class GameState {
    x: number;
    y: number;
    color: string;

    constructor(x: number, y: number, color: string) {
        this.x = x;
        this.y = y;
        this.color = color;
    };
}

export class Game {
    ws: WebSocket;
    _loopInterval: NodeJS.Timeout;
    poppedTime: number = 0;
    loadDelay: number = 2000;
    userReacted: boolean = false;
    isWaiting: boolean = false;
    profile: GameProfile;
    queueDuration: number;
    updateInterval: number;
    timeRemaining: number;

    constructor() {
        this.queueDuration = 10;
        this.updateInterval = 1;

        this._loopInterval = setInterval(this.loop, this.updateInterval * 1000);
    }

    stopLoop = (): void => {
        clearInterval(this._loopInterval);
    }

    setGame = (game: GameProfile): void => {
        console.log("settings new profile");
        this.profile = game;
    }

    setWS = (ws: WebSocket): void => {
        this.ws = ws;
    }

    /** 
     * Every [updateInterval] check if the given [readPos] is of color [readyColor]
     * if
    */
    loop = (): void => {
        // Wait until queue pops
        if (!this.isWaiting && this.ws !== undefined && this.colorMatch(this.profile.queueState)) {
            console.log("looping");

            this.ws.send(JSON.stringify({ "message": ServerMessages.GAME_READY, "body": this.queueDuration.toString() }));
            this.poppedTime = Date.now();
            // Timeout the QUEUE if wait_time passes without user accepting
            setTimeout(() => {
                if (!this.userReacted) {
                    this.ws.send(JSON.stringify({ "message": ServerMessages.QUEUE_TIMEOUT }));
                    this.stopLoop();
                }
            }, this.queueDuration * 1000);
        }
    }

    acceptGame = (): void => {

        this.userReacted = true;
        this.isWaiting = true;
        this.timeRemaining = (this.queueDuration * 1000) - (Date.now() - this.poppedTime); // divide by 1000 for seconds

        console.log("REMAINING: " + this.timeRemaining);

        // Wait until the wait time ends, check if color has changed
        setTimeout(() => {
            if (this.colorMatch(this.profile.successState)) {
                this.ws.send(JSON.stringify({ "message": ServerMessages.SUCCESS }));
            } else {
                this.ws.send(JSON.stringify({ "message": ServerMessages.QUEUE_FAILED }));

                // loop until queue button goes away
                while (this.colorMatch(this.profile.queueState)) {
                    console.log("waiting for button to leave");
                }
                this.isWaiting = false;
            }
        }, this.timeRemaining + this.loadDelay);

        // Click the Button
        robot.moveMouse(this.profile.queueState.x, this.profile.queueState.y);
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
    colorMatch = (state: GameState): boolean => {
        let currentColor: string = robot.getPixelColor(state.x, state.y);
        console.log("SERVER: " + currentColor + " vs " + state.color);
        return state.color == currentColor;
    }
}