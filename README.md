## Starting the container

Docker run

```shell
docker run --rm \
    --name radarr \
    -p 7878:7878 \
    -e PUID=1000 \
    -e PGID=1000 \
    -e UMASK=002 \
    -e TZ="Etc/UTC" \
    -v /<host_folder_config>:/config \
    -v /<host_folder_data>:/data \
    docker.io/tainrs/radarr
```

Docker compose:

```yaml
services:
    radarr:
    container_name: radarr
    image: docker.io/tainrs/radarr
    ports:
        - "7878:7878"
    environment:
        - PUID=1000
        - PGID=1000
        - UMASK=002
        - TZ=Etc/UTC
    volumes:
        - /<host_folder_config>:/config
        - /<host_folder_data>:/data
```
