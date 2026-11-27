# 91.3 Ayclt FM Discord Radio Bots

A station-specific Discord radio bot deployment for **91.3 Ayclt FM**. This repository uses the same multi-server radio bot application as the station-independent [Discord Radio Bots](https://github.com/913AycltFM/Discord-Radio-Bots) project, with a ready-made configuration template for the station's four services.

## Configured stations

The public `bots.json` template contains these four station entries:

- **91.3 Ayclt FM** — main station
- **91.3 Ayclt FM HD2**
- **91.3 Ayclt FM HD3**
- **91.3 Ayclt FM HD4**

Each entry requires its own Discord bot application and token. The stream and now-playing API URLs in the public template are examples for the station's AzuraCast services; the bot tokens are placeholders and must be replaced privately.

## Features

- Runs all four configured station bots from one application/service.
- Each station bot has its own Discord application, token, audio stream, and now-playing API.
- Plays direct AzuraCast HTTP audio streams through FFmpeg.
- Reads AzuraCast-compatible now-playing JSON and updates the bot's Listening activity.
- Updates voice-channel status when track metadata changes (requires **Manage Channels** permission).
- Allows each bot to serve multiple Discord servers at the same time, with independent voice connections and per-server playback controls.
- Automatically supervises voice connections and retries playback after disconnects or stream failures.
- Includes slash commands: `/join`, `/leave`, `/nowplaying`, `/status`, `/reconnect`, `/help`, `/play`, `/pause`, `/volume`, and `/ping`.
- Includes an interactive configuration manager and a one-command updater.
- Runs continuously under systemd and can start automatically after reboot.

## Requirements

- Ubuntu Server, Debian, or Raspberry Pi OS
- Python 3.10 or newer
- FFmpeg and the libopus runtime library
- Git and sudo access for installation
- A Discord server where you can invite the bots
- Four Discord bot applications (one for each configured station)
- The station stream and now-playing API URLs

## 1. Create the Discord bot applications

Create a separate Discord application and bot for each station:

1. Open the [Discord Developer Portal](https://discord.com/developers/applications).
2. Create an application and add a bot.
3. Open the **Bot** page and copy/reset its token. Keep the token private.
4. Under **OAuth2 → URL Generator**, select the `bot` and `applications.commands` scopes.
5. Grant these permissions:
   - View Channels
   - Connect
   - Speak
   - Manage Channels (only needed to update voice-channel status)
6. Use the generated invite URL to add that bot to the Discord server.

Repeat for the main station, HD2, HD3, and HD4. A bot must be invited to each server where you want that station available. Never publish bot tokens or include them in screenshots, issues, or public messages. If a token is exposed, reset it immediately in the Developer Portal.

## 2. Install the project

Run these commands as your normal Linux user, not as root:

```bash
sudo apt update
sudo apt install -y git

git clone https://github.com/913AycltFM/91.3-Ayclt-FM-Discord-Radio-Bots.git ~/discord-radio
cd ~/discord-radio
chmod +x install.sh
./install.sh
```

The installer installs FFmpeg, libopus, Python packages, creates the virtual environment, sets owner-only permissions on the local `bots.json`, and registers `discord-radio.service` with systemd.

**The installer does not start the service.** Configure the private bot tokens first so the example placeholder tokens are never used to log in.

## 3. Configure the station bots

Use the interactive configuration manager:

```bash
cd ~/discord-radio
./venv/bin/python configure.py
```

The manager lets you:

- Add a bot.
- Edit an existing bot.
- Remove a bot (at least one configured bot must remain).
- Save the configuration and exit.

Bot tokens are hidden while typing and are not displayed. When editing, press Enter to keep the current value. The manager validates HTTP and HTTPS URLs, backs up the existing configuration before its first managed save, and writes `bots.json` with owner-only permissions (`600`). It does not restart the service automatically.

The public `bots.json` contains four station entries with placeholder bot tokens. Replace each placeholder with the token for its matching Discord application. Keep the station names and matching stream/API URLs unless you intentionally need to change them.

You can edit the file manually instead:

```bash
nano bots.json
chmod 600 bots.json
```

Each bot entry uses these fields:

| Field | Purpose |
| --- | --- |
| `name` | Station name shown by the bot |
| `token` | Private Discord bot token |
| `stream_url` | Direct audio listener URL |
| `nowplaying_url` | AzuraCast-compatible now-playing API URL |
| `status_text` | Optional fallback status if no track metadata is available |
| `channel_id` | Optional default Discord voice-channel ID |

The `channel_id` property is optional. The public station template currently uses `null` for this field, which means no default channel is configured. You can also omit the property. If you want a bot to automatically join one default voice channel after startup, replace `null` with that channel's numeric ID. The channel must be a voice channel in a server where that bot is installed. Without a configured channel ID, the bot stays disconnected until a member joins a voice channel and runs `/join`.

Example of a valid optional channel setting:

```json
{
  "name": "91.3 Ayclt FM",
  "token": "YOUR_DISCORD_BOT_TOKEN",
  "channel_id": 123456789012345678,
  "stream_url": "https://radio.913aycltfm.com/listen/91.3_ayclt_fm/discord",
  "nowplaying_url": "https://radio.913aycltfm.com/api/nowplaying/91.3_ayclt_fm",
  "status_text": "La Marque Texas #1 Hit Music Station"
}
```

Keep all bot entries inside the surrounding JSON array. Each bot needs its own token. Do not copy one bot token into multiple entries.

### Protect your private configuration

The installer marks the tracked local `bots.json` as Git `skip-worktree` to reduce the chance of accidentally staging private edits. The updater temporarily clears that protection, backs up the private file, pulls the public template, restores your private configuration, and reapplies the protection. Keep `bots.json` and all its backups private. Never commit real tokens or private credentials.

## 4. Start and test the bots

After configuration is complete, enable and start the service:

```bash
sudo systemctl enable --now discord-radio.service
sudo systemctl status discord-radio.service --no-pager
```

Invite each bot to the Discord server(s) where it should play. Join the voice channel where you want a station to play, then run `/join` using that station's bot. Each bot can be used in multiple servers simultaneously; playback controls are independent in each server.

Available slash commands:

| Command | Description |
| --- | --- |
| `/join` | Join the voice channel you are currently in and start the station. |
| `/leave` | Leave the voice channel in this server. Requires **Manage Server**. |
| `/nowplaying` | Show the current track. |
| `/status` | Check this server's voice connection and playback status. |
| `/reconnect` | Reconnect to the last selected voice channel. Requires **Manage Server**. |
| `/help` | List the available radio commands. |
| `/play` | Start or resume playback in this server. |
| `/pause` | Pause playback without leaving the voice channel. |
| `/volume` | Set this server's volume from 0 to 100 percent. |
| `/ping` | Show the bot's Discord gateway latency. |

Only `/leave` and `/reconnect` have an application-level **Manage Server** permission check. The bot also needs **Manage Channels** if you want it to update the voice-channel status; audio playback does not require that permission.

## Update the bot software

When you publish changes to this GitHub repository, update the installed checkout by running:

```bash
cd ~/discord-radio
./update.sh
```

The updater:

1. Makes a private, permission-restricted temporary backup of your local `bots.json`.
2. Temporarily clears the Git `skip-worktree` protection on the tracked starter file, then restores the public template before pulling.
3. Pulls the latest `main` branch using `git pull --ff-only`; it will not create a merge commit.
4. Restores your private `bots.json`, sets its permissions to `600`, and reapplies Git's `skip-worktree` protection.
5. Installs the Python dependencies listed in `requirements.txt`.
6. Checks the syntax of `main.py` and `configure.py`.
7. Restarts `discord-radio.service` and displays its status.

Run this updater from the same project checkout used by the systemd service. It updates the project files in that checkout; it does not migrate the installation to another directory. If the fast-forward-only pull is blocked by local Git changes or a divergent branch, stop and review the Git status rather than forcing the update. Keep your own separate backups of `bots.json`; never commit real tokens or private stream URLs.

The updater is intended for the standard installation created by `install.sh`. It expects the virtual environment at `./venv` and the service name `discord-radio.service`.

## Service management

Check status:

```bash
sudo systemctl status discord-radio.service --no-pager
```

Follow live logs:

```bash
sudo journalctl -u discord-radio.service -f
```

Restart or stop the service:

```bash
sudo systemctl restart discord-radio.service
sudo systemctl stop discord-radio.service
```

Start it again:

```bash
sudo systemctl start discord-radio.service
```

## Troubleshooting

- **A bot does not log in:** confirm its token belongs to the correct Discord application and that the bot has been invited to the server.
- **A bot does not join voice:** without a `channel_id`, join a voice channel and run `/join`. If a default ID is configured, verify it is a voice-channel ID in a server where the bot is installed.
- **A bot joins but there is no audio:** check View Channel, Connect, and Speak permissions; confirm the stream URL is directly playable; and verify FFmpeg and libopus are installed.
- **Now-playing information does not update:** check that the API URL is reachable and returns an AzuraCast-compatible `now_playing.song` object.
- **Voice-channel status does not update:** grant the bot Manage Channels permission. Playback can work without this permission.
- **Slash commands are missing:** confirm the bot was invited with both `bot` and `applications.commands` scopes, then allow time for Discord to publish the synced commands.
- **`/leave` or `/reconnect` is denied:** the user running the command needs Manage Server permission.
- **The service will not start:** inspect its logs with `sudo journalctl -u discord-radio.service -n 100 --no-pager` and check that `bots.json` is valid JSON with four configured entries and real tokens.

## Security

- Never commit real Discord bot tokens, passwords, or other credentials.
- Keep the local `bots.json` and its backups private.
- Use `chmod 600 bots.json` to restrict local access.
- Do not post logs containing private URLs or credentials in public issues.
- If a bot token is exposed, reset it immediately in the Discord Developer Portal.

## Generic project

If you operate a different radio station and want a station-independent template, use [Discord Radio Bots](https://github.com/913AycltFM/Discord-Radio-Bots). It supports one or more bots without the 91.3 Ayclt FM station-specific template.

---

Created and maintained by [913AycltFM](https://github.com/913AycltFM).
