**This is a fork** of [rockerbacon's project](https://github.com/rockerbacon/modorganizer2-linux-installer). I intended to just add a few QOL changes, like Cyberpunk 2077 support, but am willing to make/implement adjustments if asked.

## Installing Mod Organizer 2

#### Requirements

The following requirements should be available out-of-the-box in most systems:
- _bash_
- either _curl_ or _wget_
- _zenity_
- _protontricks-launcher_: should be available after installing `protontricks` already, if not see [this](https://github.com/Matoking/protontricks#desktop)</br>

You may need to manually install the following programs:
- _7z_
    - Should be readily available in your distribution's package manager
- _protontricks_
    - **Steam Deck users**: Protontricks must be installed through the Discover app.
    - **Other distributions**: carefully read through the [available install methods](https://github.com/Matoking/protontricks#installation) to ensure you're using an up-to-date version of the program.

#### Installation Steps
1. Install the game you want to play on Steam;
2. Download the the latest stable release [here](https://github.com/furglitch/modorganizer2-linux-installer/releases/download/5.1.1/mo2installer-furglitch-5.1.1.tar.gz);
3. Extract the downloaded file;
4. Open the extracted folder in a terminal and execute `./install.sh`;
5. The installer will start and guide you through the rest of the process;
6. Run the game on Steam and Mod Organizer 2 should start;
7. Read the [post-install instructions](post-install.md) for recommended additional steps;

The installer will automatically configure game-specific workarounds and install the script extender for your game of choice. Java binaries are also made available at `C:\java` for running Proc Patchers.

**Avoid using ENBoost** with Skyrim: DXVK and Wine have their own better working memory patches, both properly enabled with this installer.

## Supported Games
| Game                  | Gameplay          | Script Extender                                                                 | ENB                                |
|-----------------------|-------------------|--------------------------------------------------------------------------------|------------------------------------|
| Cyberpunk 2077        | Working           | N/A                                                                            | Not Tested                         |
| Fallout 3             | Working*          | Working*                                                                       | Not Tested*                         |
| Fallout 4             | Working*          | Some plugins may not work. See [#32](https://github.com/rockerbacon/modorganizer2-linux-installer/issues/32)* | v0.393 or older might need `EnablePostPassShader` disabled* |
| Fallout 76**              | Not Tested          | N/A | Not Tested                        |
| Fallout New Vegas     | Fullscreen Only*  | Working*                                                                       | Working*                           |
| Morrowind             | Not Tested*       | Not Tested*                                                                    | Not Tested*                        |
| Oblivion              | Working*          | [Some plugins might require manual setup](https://github.com/rockerbacon/lutris-skyrimse-installers/issues/63#issuecomment-643690247)* | Not Tested*                        |
| Skyrim                | Working*          | Working*                                                                       | Working*                           |
| Skyrim Special Edition| Working*          | Working*                                                                       | Not Tested*                        |
| Starfield             | Working*          | Working*                                                                       | Not Tested*                        |

<sub>An asterisk (*) indicates that the status was indicated as such by the [original repo](https://github.com/rockerbacon/modorganizer2-linux-installer). I have not tested these games myself, but I have no reason to believe they are incorrect. If you find any issues with the games listed above, please open an issue on this repository and I will do my best to address it.</sub>

For known bugs and necessary workarounds, please refer to the [issues page](https://github.com/furglitch/lutris-skyrimse-installers/issues?q=is:issue+is:open+label:bug+)

Please, help to keep this table up to date by [opening issues](https://github.com/furglitch/lutris-skyrimse-installers/issues/new/choose) on any successes or problems you have experienced.

## Updating Mod Organizer 2

It is highly recommended to backup your existing installation before updating

#### From 5.1 and above

You can update by simply following the install instructions again.

#### From 5.0.3 and below

Instructions are included in the [original repo](https://github.com/rockerbacon/modorganizer2-linux-installer). Pre-fork installations are not supported by this fork.

## Installing Vortex
Instructions for installing Vortex are included in the [original repo](https://github.com/rockerbacon/modorganizer2-linux-installer). Vortex installations are not supported by this fork.
