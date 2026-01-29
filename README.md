# Garry's Mod Dedicated Server
A lean Garry's Mod dedicated server image built on top of SteamCMD and Ubuntu, designed to run as a non-root user by default. 
It ships with a simple entrypoint that starts `srcds_run` using sensible defaults, and will populate `server.cfg` from image 
defaults if the file is missing or empty.

## Quick start
Running game servers as root is gross. If you're bind mounting the cache directory and configuration files, ensure they are 
accessible by UID 1000 and GID 1000 or you may be greeted by permission errors. The workshop cache is persisted at 
`/data/garrysmod/cache` so addons don’t re-download every time you recreate the container.

### `docker-compose.yml`
```yaml
services:
  garrysmod-server:
    image: legendaryfire/gmod-server:latest
    container_name: garrysmod-server
    volumes:
      - ./games/garrysmod/cache:/data/garrysmod/cache  # Persistent Steam workshop downloads
      - ./games/garrysmod/server.cfg:/data/garrysmod/cfg/server.cfg  # Server configuration
      - ./games/garrysmod/users.txt:/data/garrysmod/settings/users.txt  # User configuration
    ports:
      - "27016:27016/udp"  # Game Server
      - "27016:27016/tcp"  # RCON
    environment:
      - PORT: "27016"
      - GAMEMODE: "terrortown"
      - GSLT: "MY_STEAM_GSLT_KEY_HERE"
      - ARGS: "+host_workshop_collection 282911546 +map ttt_minecraft_b5"
    stdin_open: true
    tty: true
    env_file: .env
    restart: unless-stopped
```
