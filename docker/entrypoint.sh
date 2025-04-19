#!/bin/bash
set -e

INDEX_DIR="/data/photon_data/elasticsearch"
JAVA_ARGS=()

# Check for mutually exclusive CORS settings
if [ "$PHOTON_CORS_ANY" = "true" ] && [ -n "$PHOTON_CORS_ORIGIN" ]; then
    echo "Error: PHOTON_CORS_ANY and PHOTON_CORS_ORIGIN cannot be set at the same time."
    exit 1
fi

# Add CORS flags if env vars are set
if [ "$PHOTON_CORS_ANY" = "true" ]; then
    JAVA_ARGS+=("-cors-any")
elif [ -n "$PHOTON_CORS_ORIGIN" ]; then
    JAVA_ARGS+=("-cors-origin" "$PHOTON_CORS_ORIGIN")
fi

if [ ! -d "$INDEX_DIR" ]; then
    echo "Error: Elasticsearch index not found at $INDEX_DIR"
    exit 1
fi

# Start photon if elastic index exists
if [ -d "$INDEX_DIR" ]; then
    echo "Start photon"
    exec java -jar photon.jar -data-dir /data/ "${JAVA_ARGS[@]}" "$@"
else
    echo "Could not start photon, the search index could not be found"
    exit 1
fi
