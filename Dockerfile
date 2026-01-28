FROM steamcmd/steamcmd AS steamcmd
RUN steamcmd +force_install_dir /data +login anonymous +app_update 4020 validate +quit;

FROM ubuntu:25.04
RUN groupmod -n legendary "$(getent group 1000 | cut -d: -f1)" \
    && usermod -l legendary -d /home/legendary -m "$(getent passwd 1000 | cut -d: -f1)"
COPY --chown=legendary:legendary --from=steamcmd /data /data

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates lib32gcc-s1 libstdc++6:i386 \
       libtinfo6:i386 libcurl4:i386 libcurl4 libstdc++6 libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY --chown=legendary:legendary defaults/ /data/defaults/
USER legendary
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
