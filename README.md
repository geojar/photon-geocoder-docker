# Photon Geocoder Docker

This project provides a **Dockerized** version of **Photon Geocoder**. [Photon](https://github.com/komoot/photon) is a geocoder built by [Komoot](https://www.komoot.de/), designed to convert geographic coordinates (latitude and longitude) into meaningful place names (and vice versa). 

The image also contains a script to **download and extract pre-generated Photon DB data** provided by [GraphHopper](https://www.graphhopper.com/). It supports downloading either the **full planet dataset** or **country-specific extracts**, and uses `pbzip2` for fast parallel decompression during extraction.

You can either use the prebuilt Docker image or build it yourself. This project includes a Dockerfile and `docker-compose.yml` to simplify the setup process.

---

## Getting Started

The easiest way to get started is by using the prebuilt image hosted on Docker Hub. Follow these steps:

### 1. Download the Database

Before using the Photon Geocoder, you need to download the required database. You can either use the download script from within the docker image, or download or build the data yourself.

##### 🛠️ Arguments

| Argument         | Description                                    | Optional |
|------------------|------------------------------------------------|----------|
| `--country`      | ISO country code (e.g., `de`, `be`, `us`)      | ✅        |
| `--target-dir`   | Directory to extract the data into             | ✅ (default: `/data`) |
| `--log-dir`      | Directory to store logs (writes stdout/stderr) | ✅        |

#### 🌍 Download Full Planet DB

```bash
docker run --rm -v $(pwd)/data:/data --entrypoint /photon/download.sh geojar/photon-geocoder --target-dir /data
```

#### 🇧🇪 Download Country Only (Example: Belgium)

If you want to download only a country-specific extract instead of the full planet:

- Pass the country code as an argument (e.g. `be` for Belgium)
- The list of available country codes is in [`docker/country_codes.txt`](./docker/country_codes.txt)
- Note: GraphHopper might not export data for **all** countries listed — check the official directory if a download fails.

```bash
docker run --rm -v $(pwd)/data:/data --entrypoint /photon/download.sh geojar/photon-geocoder --country be --target-dir /data
```

#### 📂 Include Logging (optional)

```bash
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/logs:/logs \
  --entrypoint /photon/download.sh \
  geojar/photon-geocoder --country be --target-dir /data --log-dir /logs
```
### 2. Running Photon Server with Docker

The prebuilt Docker image `geojar/photon-geocoder` can be run using either Docker directly or with Docker Compose.

#### Using `docker run`:

```bash
docker run -d \
  -v ./data/photon_data:/data/photon_data \
  -e PHOTON_CORS_ANY=true \  # or PHOTON_CORS_ORIGIN="https://example.com,https://another.com" (only one of these can be set)
  -p 2322:2322 \
  --name photon-geocoder \
  geojar/photon-geocoder:latest
```

- **Explanation**:
  - `-v ./data/photon_data:/data/photon_data`: Mounts the local `data` directory (which contains the downloaded database) as a volume inside the container.
  - `-e PHOTON_CORS_ANY=true`: Sets the CORS option to allow all origins (only one of the CORS options can be set).
  - `-p 2322:2322`: Maps port 2322 inside the container to port 2322 on the host machine.

#### Using Docker Compose:

Alternatively, Docker Compose can be used to run the container. Here’s an example `docker-compose.yml` configuration:

```yaml
services:
  photon:
    container_name: photon-geocoder
    image: geojar/photon-geocoder:latest
    volumes:
      - ./data/photon_data:/data/photon_data
    ports:
      - "2322:2322"
    environment:
      PHOTON_CORS_ANY: "true"  # or PHOTON_CORS_ORIGIN="https://example.com,https://another.com" (only one of these can be set)
    restart: unless-stopped
```

To start the container with Docker Compose:

```bash
docker-compose up
```

This will start the Photon Geocoder service, and the API will be available at `http://localhost:2322`.

---

## Notes on CORS Settings

When running the container, users must set the CORS configuration directly via environment variables:

- **`PHOTON_CORS_ANY=true`**: Enable CORS for all origins.
- **`PHOTON_CORS_ORIGIN="https://example.com,https://another.com"`**: Enable CORS for specific origins (only one of these options can be set).

Make sure to set **only one** of the CORS options (either `PHOTON_CORS_ANY` or `PHOTON_CORS_ORIGIN`). If both are set, the container will not start.

---

## API Usage

Once the Photon Geocoder is running, users can interact with the API. For example, to query for the location of "Berlin":

```bash
curl "http://localhost:2322/api/?q=berlin&limit=1"
```

This will return a JSON response with geographic information about Berlin.

For full API documentation, check out the [Photon GitHub Repository](https://github.com/komoot/photon).

---

### 🤖 AI-Assisted Content

Some parts of this project, especially the README and other documentation, were created or refined with the help of AI tools (such as ChatGPT). These tools were used to improve clarity, structure, and consistency in presenting the information. All generated content was reviewed and edited as needed to ensure accuracy and alignment with the project’s goals.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.