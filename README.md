# 91.3 Ayclt FM Discord Radio Bots

Station-specific Discord radio bot deployment for **91.3 Ayclt FM**.

This repository contains the bot application used by the station's Discord radio bots. It is based on the station-independent [Discord Radio Bots](https://github.com/913AycltFM/Discord-Radio-Bots) project, with a configuration template for the 91.3 Ayclt FM services.

## Configured stations

- 91.3 Ayclt FM
- 91.3 Ayclt FM HD2
- 91.3 Ayclt FM HD3
- 91.3 Ayclt FM HD4

Each station uses its own Discord bot application/token and its own stream and now-playing API URLs.

## Security

**Never commit real Discord bot tokens, private stream URLs, passwords, or other credentials.** The committed `bots.json` is a template only. Replace the example values on the server, keep the local file private, and do not push the edited file to GitHub.

The repository's `.gitignore` excludes local `bots.json` edits. If a token is ever exposed, reset it immediately in the Discord Developer Portal.

## Requirements

- Ubuntu Server, Debian, or Raspberry Pi OS
- Python 3.10+
- FFmpeg and libopus
- Discord bot applications with the `bot` and `applications.commands` OAuth scopes
- View Channel, Connect, and Speak permissions; Manage Channels is optional for voice-channel status updates

## Install

Clone the repository on the radio bot host:

```bash
git clone https://github.com/913AycltFM/91.3-Ayclt-FM-Discord-Radio-Bots.git ~/discord-radio
cd ~/discord-radio
chmod +x install.sh
./install.sh
```

The installer installs dependencies and registers the systemd service. It does not start the service automatically.

## Configure

Run the interactive wizard. It hides bot tokens while typing and saves the local configuration with owner-only permissions:

```bash
./venv/bin/python configure.py
```

Add the four station bots using the correct Discord tokens, stream listener URLs, and AzuraCast now-playing API URLs for your deployment. The checked-in `bots.json` shows the station names and example URL patterns only; its tokens and host are placeholders. The optional `channel_id` property is intentionally omitted from the public template. Add it to your private configuration only if you want a bot to automatically join a default voice channel.

You can also edit `bots.json` manually. Keep it private:

```bash
chmod 600 bots.json
```

### Optional default voice channel

You can optionally add a `channel_id` to a bot entry in your private `bots.json`:

```json
{
  "name": "91.3 Ayclt FM",
  "token": "YOUR_DISCORD_BOT_TOKEN",
  "channel_id": 123456789012345678
  "stream_url": "https://radio.913aycltfm.com/listen/91.3_ayclt_fm/discord",
  "nowplaying_url": "https://radio.913aycltfm.com/api/nowplaying/91.3_ayclt_fm",
  "status_text": "La Marque Texas #1 Hit Music Station"
}
```

Replace the example number with the ID of a voice channel the bot can access. When set, the bot automatically joins that channel after startup. This setting is optional, so the public `bots.json` template does not include the property. Add it only to your private `bots.json` if you want automatic joining. If you omit it or leave the wizard prompt blank, the bot stays disconnected until someone joins a voice channel and runs `/join`. The configured channel must belong to a server where the bot is installed.

## Start and manage

```bash
sudo systemctl enable --now discord-radio.service
sudo systemctl status discord-radio.service --no-pager
```

Follow logs:

```bash
sudo journalctl -u discord-radio.service -f
```

Restart or stop the bots:

```bash
sudo systemctl restart discord-radio.service
sudo systemctl stop discord-radio.service
```

## Discord usage

Invite each bot to the intended Discord server. By default, each bot stays disconnected until a member joins a voice channel and runs `/join`. If you add an optional `channel_id` to that bot's private configuration, it automatically joins that default voice channel after startup. A bot can serve multiple Discord servers simultaneously, with independent playback controls per server.

Available slash commands include `/join`, `/leave`, `/nowplaying`, `/status`, `/reconnect`, `/play`, `/pause`, `/volume`, `/ping`, and `/help`.

## Generic project

For a station-independent version intended for other radio operators, see [Discord Radio Bots](https://github.com/913AycltFM/Discord-Radio-Bots).
