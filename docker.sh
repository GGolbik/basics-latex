#!/bin/bash

IMAGE_NAME=ggolbik/basics-latex
PDF_FILE_SRC=main.pdf
PDF_FILE_TARGET=Document_$(date +"%Y-%m-%d").pdf

echo "Start build script"

# Detect directory of the script to allow execution from all directories.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Build script directory: ${SCRIPT_DIR}"

# Command to build the document
/bin/bash -c "set -Eeuo pipefail \
  && cd ${SCRIPT_DIR} \
  && docker build \
  --target build \
  --tag ${IMAGE_NAME} \
  ./"

# Print build result (success or error)
EXIT_CODE=$?
if [[ ${EXIT_CODE} -eq 0 ]]; then
  echo "Build-Success"

  echo "Copy Output"
  mkdir -p ${SCRIPT_DIR}/build
  CONTAINER_ID=$(docker create ${IMAGE_NAME})
  docker cp ${CONTAINER_ID}:/basics/build/${PDF_FILE_SRC} ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}
  docker rm ${CONTAINER_ID}
  # Create hash values
  FILE_MD5=($(md5sum ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}))
  FILE_SHA1=($(sha1sum ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}))
  FILE_SHA256=($(sha256sum ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}))
  # Write hash values to file
  echo $FILE_MD5 ${PDF_FILE_TARGET} > ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}.md5
  echo $FILE_SHA1 ${PDF_FILE_TARGET} > ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}.sha1
  echo $FILE_SHA256 ${PDF_FILE_TARGET} > ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}.sha256

  echo "Output written to: ${SCRIPT_DIR}/build/${PDF_FILE_TARGET}"
else
  echo "Build-Error: ${EXIT_CODE}"
  exit ${EXIT_CODE}
fi
