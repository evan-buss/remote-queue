"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const robot = require("robotjs");
const game_1 = require("./game");
class CounterStrikeGlobalOffensive extends game_1.Game {
    constructor(ws) {
        super();
        this.poppedTime = 0;
        // Delay to wait before checking for game load success
        this.loadDelay = 2000;
        this.userReacted = false;
        this.isWaiting = false;
        this.stopLoop = () => {
            clearInterval(this.loopInterval);
        };
        /**
         * Every [updateInterval] check if the given [readPos] is of color [readyColor]
         * if
        */
        this.loop = () => {
            // Wait until queue pops
            if (this.colorMatch(this.ReadyState.x, this.ReadyState.y, this.ReadyState.color)
                && !this.isWaiting) {
                this.ws.send(JSON.stringify({ "message": game_1.ServerMessages.GAME_READY, "body": this.timeToAccept }));
                this.poppedTime = Date.now();
                // Timeout the QUEUE if wait_time passes without user accepting
                setTimeout(() => {
                    if (!this.userReacted) {
                        this.ws.send(JSON.stringify({ "message": game_1.ServerMessages.QUEUE_TIMEOUT }));
                        this.stopLoop();
                    }
                }, this.timeToAccept * 1000);
            }
        };
        this.acceptGame = () => {
            this.userReacted = true;
            this.isWaiting = true;
            const remaining = (this.timeToAccept * 1000) - (Date.now() - this.poppedTime); // divide by 1000 for seconds
            console.log("REMAINING: " + remaining);
            // Wait until the wait time ends, check if color has changed
            setTimeout(() => {
                if (this.colorMatch(this.SuccessState.x, this.SuccessState.y, this.SuccessState.color)) {
                    this.ws.send(JSON.stringify({ "message": game_1.ServerMessages.SUCCESS }));
                }
                else {
                    this.ws.send(JSON.stringify({ "message": game_1.ServerMessages.QUEUE_FAILED }));
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
            this.ws.send(JSON.stringify({ "message": game_1.ServerMessages.QUEUE_WAIT }));
        };
        this.declineGame = () => {
            this.stopLoop();
            console.log("Declining game");
        };
        /**
         * Check if the color at a given [x], [y] matches the [targetColor]
         */
        this.colorMatch = (x, y, targetColor) => {
            let currentColor = robot.getPixelColor(x, y);
            return targetColor == currentColor;
        };
        this.NeutralState = new game_1.GameState(78, 264, "ffffff");
        this.ReadyState = new game_1.GameState(1053, 816, "53ad56");
        this.SuccessState = new game_1.GameState(1449, 256, "fffffd");
        this.timeToAccept = 10;
        this.updateInterval = 1;
        this.ws = ws;
        this.loopInterval = setInterval(this.loop, this.updateInterval * 1000);
    }
}
exports.CounterStrikeGlobalOffensive = CounterStrikeGlobalOffensive;
//# sourceMappingURL=csgo.js.map