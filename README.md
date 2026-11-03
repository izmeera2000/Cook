# Godot 3D Multiplayer Template

Godot 4.7 starter project for building a 3D multiplayer game with player movement, sessions, inventory, equipment, chat, and dedicated-server support.

> This template is also available on the [Godot Asset Library](https://godotengine.org/asset-library/asset/3377) and [Godot Asset Store](https://store.godotengine.org/asset/devmoreir4/godot-3d-multiplayer-template/).

## Key Features

- **Multiplayer Sessions:** Host, join, test multiple local instances, or run a headless dedicated server with support for up to 10 players.
- **Cooking Controls:** The host chooses Advanced timed cooking or Simple automatic cooking for everyone in the session.
- **Character Controller:** Camera-relative movement, sprinting, double jumping, synchronized animations, and switchable first- and third-person views.
- **Player Profiles:** Four selectable character skins and in-world name tags for every player.
- **Chat and Player List:** Communicate with connected players and view the current session members.
- **Server-Authoritative Inventory:** 16 base slots, 4 backpack slots, stacking, drag and drop, context actions, and server-validated changes.
- **Synchronized Equipment:** Hats, weapons, and backpacks are visible on every player's character.
- **World Items:** Drop, push, and collect physics-based items.
- **Kitchen Stations:** Grill a visible 3D patty, shake rice in a wok, chop vegetables at the prep station, or use the oven's cooking challenge.
- **Integrated Interfaces:** Inventory, chat, player list, and pause menu coordinate gameplay input and mouse capture.

## Project Structure

- `assets/`: Imported models, textures, icons, fonts, and third-party asset attribution files.
- `scenes/items/`: World-drop scenes organized into backpacks, hats, miscellaneous items, and weapons.
- `scenes/level/`: Main level, arena, and multiplayer player scenes.
- `scenes/ui/`: Inventory, menus, chat, online-player-list, gameplay HUD, power-card, and cooking station scenes.
- `resources/powers/`: Editable power-card definitions.
- `scripts/autoload/`: Global `Network` and `ItemDatabase` singletons.
- `scripts/inventory/`: Item data, inventory slots, and player inventory state.
- `scripts/items/`: World-item behavior.
- `scripts/level/`: Level and multiplayer session coordination, kitchen stations, and cooking visuals.
- `scripts/powers/`: Power-card data and HUD.
- `scripts/player/`: Player controller, character model, and camera support.
- `scripts/ui/`: Gameplay HUD, cooking station interfaces, and other user-interface behavior.

## How to Run the Project

Follow these simple steps to get the template up and running:

1. **Clone or Download:** Obtain the repository by cloning it via Git or downloading the ZIP file.
2. **Open in Godot Engine:** Load the project in [Godot Engine 4.7](https://godotengine.org).
3. **Execute:** Press <kbd>F5</kbd> or click `Run Project` in the Godot editor.

For local multiplayer testing, open `Debug > Customize Run Instances`, enable `Enable Multiple Instances`, choose the desired number of instances, and run the project.

## Dedicated Server

From the project directory, start a headless server with:

```bash
godot --headless --path .
```

Then start another project instance, choose `Join`, and connect to `127.0.0.1`. The server listens on UDP port `8080`. Press <kbd>Ctrl</kbd>+<kbd>C</kbd> in the server terminal to stop it.

On Linux or macOS, the provided wrapper can also locate the Godot executable and handle shutdown:

```bash
./run_headless_server.sh
```

Ensure the script has execution permissions (`chmod +x run_headless_server.sh`) and that the `godot` binary is in your system `PATH`. If Godot is installed under another command or path, set `GODOT_BIN` when starting the server:

```bash
GODOT_BIN=/path/to/godot ./run_headless_server.sh
```

## Controls

- <kbd>W</kbd> <kbd>A</kbd> <kbd>S</kbd> <kbd>D</kbd> to move.
- <kbd>Shift</kbd> to run.
- <kbd>Space</kbd> to jump or double jump.
- Left mouse button to play the attack animation (visual only, without damage).
- <kbd>E</kbd> to collect a nearby item or use a kitchen station.
- At the grill, press <kbd>E</kbd> or left-click to flip the 3D patty, then plate it when the second side is seared. Use **Leave Grill** to exit early.
- <kbd>Esc</kbd> to open or close the pause menu.
- <kbd>T</kbd> to hide/show chat.
- <kbd>I</kbd> to toggle inventory.
- Hold <kbd>Tab</kbd> to show the online player list.
- <kbd>V</kbd> to switch between first-person and third-person views.
- On phones and tablets, use the on-screen joystick to move and the **INTERACT** button to use stations or pick up items.
- When hosting, choose **Simple** to start autonomous cooking, move freely, and start other stations while bars above counters fill; interact with a finished counter to collect its food. **Advanced** keeps timed cooking and gesture controls. The host's choice applies to everyone.
- Click **Orders** to view the current cooking order; **Hide** collapses the order bar.
- Click **Powers** to view and activate cards, or press <kbd>1</kbd>–<kbd>4</kbd>; Quickstep boosts movement, Heat Rush speeds cooking, and Overclock boosts movement, jumping, and cooking.
- At the wok, shake your phone on mobile or swipe the mouse side-to-side on desktop to toss and cook the rice; Heat Rush and Overclock reduce the shakes needed.
- At vegetable prep, press <kbd>E</kbd> or left-click to chop the vegetables; cooking-speed powers speed up preparation.
- The order list currently includes a sample Classic Cheeseburger order with bun, patty, cheese, lettuce, and tomato.
- <kbd>F1</kbd> to add a random test item (debug builds, host only).
- <kbd>F2</kbd> to print the local inventory (debug).

## Contributing

If you want to contribute to this project, please refer to our [Contributing Guidelines](CONTRIBUTING.md).

## Credits

- 3D Godot Robot Platformer Character, by AGChow, licensed under CC0. See [`assets/characters/player/ATTRIBUTIONS.md`](assets/characters/player/ATTRIBUTIONS.md).
- Item models and icons by Poly by Google and Quaternius. See [`assets/items/ATTRIBUTIONS.md`](assets/items/ATTRIBUTIONS.md).
- Prototype environment textures by Kenney, licensed under CC0. See [`assets/environment/ATTRIBUTIONS.md`](assets/environment/ATTRIBUTIONS.md).

## License

The project source code is available under the [MIT License](LICENSE). Third-party assets are excluded from that license and remain available under the terms documented in their respective attribution files.
