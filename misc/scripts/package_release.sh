#!/bin/bash

set -e
set -x

ARTIFACTS=${ARTIFACTS:-"artifacts"}
DESTINATION=${DESTIONATION:-"release"}
TYPE=${TYPE:-"gdupnp"}

mkdir -p ${DESTINATION}
ls -R ${DESTINATION}
ls -R ${ARTIFACTS}

DESTDIR="${DESTINATION}/${TYPE}"

mkdir -p ${DESTDIR}/lib

find "${ARTIFACTS}" -maxdepth 5 -wholename "*/${TYPE}/lib/*" | xargs cp -r -t "${DESTDIR}/lib/"
find "${ARTIFACTS}" -wholename "*/LICENSE*" | xargs cp -t "${DESTDIR}/"
find "${ARTIFACTS}" -wholename "*/${TYPE}/${TYPE}.gdextension" | head -n 1 | xargs cp -t "${DESTDIR}/"

CURDIR=$(pwd)
cd "${DESTINATION}"
zip -r ../godot-${TYPE}.zip ${TYPE}
cd "$CURDIR"

ls -R ${DESTINATION}
