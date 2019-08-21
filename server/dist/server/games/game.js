"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Abstract class methods for each game
class Game {
    constructor() {
        // How much time do you have after the game queue pops (seconds)?
        this.timeToAccept = 20;
        // How often should the screen be checked for updates (seconds)?
        this.updateInterval = 1;
        // Unique location and color of game window when nothing is happening
        this.NeutralState = new GameState(0, 0, "ffffff");
        // Unique location and color of game window when queue accept button is visible
        // This will often be the button itself
        this.ReadyState = new GameState(0, 0, "ffffff");
        // Unique location and color of the game window when queue has been joined
        // This will often be the game load screen
        this.SuccessState = new GameState(0, 0, "ffffff");
    }
    acceptGame() { }
    declineGame() { }
    stopInterval() { }
}
exports.Game = Game;
;
class GameState {
    constructor(x, y, color) {
        this.x = x;
        this.y = y;
        this.color = color;
    }
    ;
}
exports.GameState = GameState;
exports.ClientMessages = {
    ACCEPT_GAME: "ACCEPT_GAME",
    DECLINE_GAME: "DECLINE_GAME"
};
exports.ServerMessages = {
    GAME_READY: "GAME_READY",
    QUEUE_FAILED: "QUEUE_FAILED",
    QUEUE_TIMEOUT: "QUEUE_TIMEOUT",
    QUEUE_WAIT: "QUEUE_WAIT",
    SUCCESS: "SUCCESS",
};
//# sourceMappingURL=game.js.map