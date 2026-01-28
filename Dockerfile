FROM steamcmd/steamcmd

RUN steamcmd +force_install_dir /data +login anonymous +app_update 4020 validate +quit;

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates lib32gcc-s1 libstdc++6:i386 \
       libtinfo6:i386 libcurl4:i386 libcurl4 libstdc++6 libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 27015/udp 27015/tcp

COPY entrypoint.sh /usr/local/bin

ENTRYPOINT ['/usr/local/bin/entrypoint.sh']
