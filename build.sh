#!/bin/bash

echo "Start build script"

# Detect directory of the script to allow execution from all directories.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Build script directory: ${SCRIPT_DIR}"

# xelatex | latexmk
BUILD_TYPE=latexmk

# Command to build the document
# ln: The failure with absolute paths is for security reasons. You can always use a local symlink pointing to the global directory though.
/bin/bash -c "set -Eeuo pipefail \
  && mkdir -p ${SCRIPT_DIR}/build \
  && ln -s ${SCRIPT_DIR}/build ${SCRIPT_DIR}/src/build \
  && cd ${SCRIPT_DIR}/src \
  && latexmk -pdflatex='xelatex %O %S' -pdf -jobname=build/main main.tex"

# Print build result (success or error)
EXIT_CODE=$?
if [[ ${EXIT_CODE} -eq 0 ]]; then
  echo "Build-Success"
else
  echo "Build-Error: ${EXIT_CODE}"
  exit ${EXIT_CODE}
fi
