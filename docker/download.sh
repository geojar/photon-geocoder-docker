#!/bin/bash

set -e

COUNTRY=""
TARGET_DIR="/data"
LOG_DIR=""
COUNTRY_CODES_FILE="/photon/country_codes.txt"
URL_BASE="https://download1.graphhopper.com/public"

# Logging
log() {
  if [[ -n "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_DIR/photon_download.log"
  else
    echo "$@"
  fi
}

# Usage
usage() {
  echo "Usage: $0 [--country <code>] [--target-dir <path>] [--log-dir <path>]"
  exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --country)
      COUNTRY="$2"
      shift
      ;;
    --target-dir)
      TARGET_DIR="$2"
      shift
      ;;
    --log-dir)
      LOG_DIR="$2"
      shift
      ;;
    *)
      echo "Unknown parameter passed: $1"
      usage
      ;;
  esac
  shift
done

# Validate country code if set
if [[ -n "$COUNTRY" ]]; then
  if ! grep -qw "$COUNTRY" "$COUNTRY_CODES_FILE"; then
    echo "Invalid country code: $COUNTRY"
    echo "Valid codes are: $(cat $COUNTRY_CODES_FILE)"
    exit 1
  fi
  URL="$URL_BASE/extracts/by-country-code/$COUNTRY/photon-db-${COUNTRY}-latest.tar.bz2"
else
  URL="$URL_BASE/photon-db-latest.tar.bz2"
fi

log "Starting download from: $URL"
mkdir -p "$TARGET_DIR"

# Execute download and extraction
if wget -qO- "$URL" | pbzip2 -cd | tar -x -C "$TARGET_DIR"; then
  log "Download and extraction completed successfully."
else
  log "Failed to download or extract."
  exit 1
fi
