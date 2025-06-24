# bluemap-webserver-docker

Run an external [BlueMap](https://github.com/BlueMap-Minecraft/BlueMap) web-server in Docker, using SQL as a storage.

Useful when wanting to serve BlueMap's content from a different host, e.g. an external VPS with more bandwidth than
your Minecraft server host.

To use, copy .env.example to .env and configure accordingly. Then, configure BlueMap to use the MariaDB server spawned by the
docker-compose stack.

`BLUEMAP_PROXY_TARGET` (the BlueMap's webserver) is used for live data and for serving `settings.json`.
