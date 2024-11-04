#!/bin/bash

set -e
set -x

ARTIFACTS=${ARTIFACTS:-"artifacts"}
DESTINATION=${DESTIONATION:-"release"}
TYPE=${TYPE:-"gdupnp"}

mkdir -p ${DESTINATION}
ls -R ${DESTINATION}
ls -R ${ARTIFACTS}

DESTDIR="${DESTINATION}/addons/gdupnp"

mkdir -p ${DESTDIR}/lib

find "${ARTIFACTS}" -maxdepth 4 -wholename "*/gdupnp/lib/*" | xargs cp -r -t "${DESTDIR}/lib/"
find "${ARTIFACTS}" -wholename "*/LICENSE*" | xargs cp -t "${DESTDIR}/"
find "${ARTIFACTS}" -wholename "*/gdupnp/gdupnp.gdextension" | head -n 1 | xargs cp -t "${DESTDIR}/"

ls -R ${DESTINATION}
