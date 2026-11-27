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

Add the four station bots using the correct Discord tokens, stream listener URLs, and AzuraCast now-playing API URLs for your deployment. The checked-in `bots.json` shows the station names and example URL patterns only; its tokens and host are placeholders.

You can also edit `bots.json` manually. Keep it private:

```bash
chmod 600 bots.json
```

## Update the installation

From the project directory, run:

```bash
./update.sh
```

The updater fetches the latest `main` branch, installs the Python packages listed in `requirements.txt`, and checks the Python files for syntax errors. It preserves your private `bots.json`. It refuses to proceed if tracked local code changes are present. If the service was already running, it restarts it after a successful update; if it was stopped, it leaves it stopped.

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

Invite each bot to the intended Discord server. Join the voice channel where you want a station to play, then run `/join`. Each bot stays disconnected until a member uses `/join`. A bot can serve multiple Discord servers simultaneously, with independent playback controls per server.

Available slash commands include `/join`, `/leave`, `/nowplaying`, `/status`, `/reconnect`, `/play`, `/pause`, `/volume`, `/ping`, and `/help`.

## Generic project

For a station-independent version intended for other radio operators, see [Discord Radio Bots](https://github.com/913AycltFM/Discord-Radio-Bots).
