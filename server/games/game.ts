// Abstract class methods for each game
export class Game {
    // How much time do you have after the game queue pops (seconds)?
    timeToAccept: number = 20;
    // How often should the screen be checked for updates (seconds)?
    updateInterval: number = 1;
    // Unique location and color of game window when nothing is happening
    NeutralState: GameState = new GameState(0, 0, "ffffff");
    // Unique location and color of game window when queue accept button is visible
    // This will often be the button itself
    ReadyState: GameState = new GameState(0, 0, "ffffff");
    // Unique location and color of the game window when queue has been joined
    // This will often be the game load screen
    SuccessState: GameState = new GameState(0, 0, "ffffff");

    acceptGame(): void { }
    declineGame(): void { }
    stopInterval(): void { }
};

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

export const ClientMessages = {
    ACCEPT_GAME: "ACCEPT_GAME",
    DECLINE_GAME: "DECLINE_GAME"
}

export const ServerMessages = {
    GAME_READY: "GAME_READY",
    QUEUE_FAILED: "QUEUE_FAILED",
    QUEUE_TIMEOUT: "QUEUE_TIMEOUT",
    QUEUE_WAIT: "QUEUE_WAIT",
    SUCCESS: "SUCCESS",
}
