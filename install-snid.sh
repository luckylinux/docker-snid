#!/bin/bash

# Exit on Error
set -e

# Enable Verbose Output
# set -x

# Architecture
TARGETPLATFORM=${1-"linux/amd64"}

# Tag
SNID_TAG=${2-"latest"}

# Install Path
SNID_PATH="/opt/snid"

# Cache Path
SNID_CACHE_PATH="/var/lib/installer/snid"

# Repository
SNID_REPOSITORY="AGWA/snid"

# Architecture Mapping
if [ "${TARGETPLATFORM}" = "linux/amd64" ]
then
   ARCHITECTURE="amd64"
elif [ "${TARGETPLATFORM}" = "linux/arm64/v8" ]
then
   ARCHITECTURE="arm64";
else
   echo "Architecture ${TARGETPLATFORM} received"
fi

# Tag or Latest have different URL Structure
if [[ "${SNID_TAG}" == "latest" ]]
then
   # Define Base URL
   SNID_BASE_URL="https://github.com/${SNID_REPOSITORY}/releases/latest/download"

   # Retrieve what Version the "latest" tag Corresponds to
   SNID_VERSION=$(curl -H "Accept: application/vnd.github.v3+json" -sS  "https://api.github.com/repos/${SNID_REPOSITORY}/tags" | jq -r '.[0].name')
else
   # Define Base URL
   SNID_BASE_URL="https://github.com/${SNID_REPOSITORY}/releases/download/${SNID_TAG}"

   # Version is the same as the Tag
   SNID_VERSION=${SNID_TAG}
fi

# Echo
echo "Base URL Set to: ${SUPERCRONIC_BASE_URL}"


# snid Package Filename
SNID_PACKAGE_FILENAME="snid-${SNID_VERSION}-linux-${ARCHITECTURE}"

# snid Checksum Filename
# Unfortunately a separate file is not available
# SNID_CHECKSUM_FILENAME="checksums.txt"

# snid Package Download Link
SNID_PACKAGE_URL="${SNID_BASE_URL}/${SNID_PACKAGE_FILENAME}"

# snid Checksum Download Link
# Unfortunately a separate file is not available
# SNID_CHECKSUM_URL="${SNID_BASE_URL}/${SNID_CHECKSUM_FILENAME}"

# Echo
echo "Package URL Set to: ${SNID_PACKAGE_URL}"

# Unfortunately a separate file is not available
# echo "Checksum URL Set to: ${SNID_CHECKSUM_URL}"

# Create Directory for snid Executables (if it doesn't exist yet)
mkdir -p "${SNID_PATH}"

# Create a ${SNID_VERSION} subdirectory within ${SNID_CACHE_PATH}
mkdir -p "${SNID_CACHE_PATH}/${SNID_VERSION}"

# By default must download
SNID_PACKAGE_DOWNLOAD=1
SNID_CHECKSUM_DOWNLOAD=1



# Check if Checksum File exists in Cache
# Unfortunately a separate file is not available
#if [[ -f "${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_CHECKSUM_FILENAME}" ]]
#then
#    # Checksum File exists
#    SNID_CHECKSUM_DOWNLOAD=0
#else
#    # Download Checksum File
#    echo "Downloading Checksum File for snid from ${SNID_CHECKSUM_URL}"
#    curl -sS -L --output-dir "${SNID_CACHE_PATH}/${SNID_VERSION}" -o "${SNID_CHECKSUM_FILENAME}" --create-dirs "${SNID_CHECKSUM_URL}"
#fi




# Check if Package File exists in Cache
if [[ -f "${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_PACKAGE_FILENAME}" ]]
then
   # Package File exists
   SNID_PACKAGE_DOWNLOAD=0
fi

# Check if need to re-download Package
if [[ ${SNID_PACKAGE_DOWNLOAD} -ne 0 ]]
then
   # Download Package File
   echo "Downloading Package for snid from ${SNID_PACKAGE_URL}"
   curl -sS -L --output-dir "${SNID_CACHE_PATH}/${SNID_VERSION}" -o "${SNID_PACKAGE_FILENAME}" --create-dirs "${SNID_PACKAGE_URL}"
else
   # Echo
   echo "Using Cache for snid from ${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_PACKAGE_FILENAME}"
fi




# Expected File Checksum
# Unfortunately a separate file is not available
#SNID_PACKAGE_EXPECTED_CHECKSUM=$(cat "${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_CHECKSUM_FILENAME}" | grep "${SNID_PACKAGE_FILENAME}" | head -c 64 )

# Calculate Actual Checksum
SNID_PACKAGE_ACTUAL_CHECKSUM=$(sha256sum "${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_PACKAGE_FILENAME}" | head -c 64)

# Check if checksum is correct
# Unfortunately a separate file is not available
#SNID_PACKAGE_CHECK_CHECKSUM=$(echo "${SNID_PACKAGE_EXPECTED_CHECKSUM} ${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_PACKAGE_FILENAME}" | sha256sum -c --status)

# If Checksum is invalid, exit
# Unfortunately a separate file is not available
#if [[ ${SNID_PACKAGE_CHECK_CHECKSUM} -ne 0 ]]
#then
#   echo "Checksum of Package snid is Invalid: expected ${SNID_PACKAGE_EXPECTED_CHECKSUM} for File ${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_PACKAGE_FILENAME}, got ${SNID_PACKAGE_ACTUAL_CHECKSUM}"
#   exit 9
#fi


# Copy Files from Cache Folder to Destination Folder
cp "${SNID_CACHE_PATH}/${SNID_VERSION}/${SNID_PACKAGE_FILENAME}" "${SNID_PATH}/snid"


# Make Binary File(s) executable
chmod +x ${SNID_PATH}/*

# Also create a Configuration Folder in /etc/snid
#mkdir -p /etc/snid
