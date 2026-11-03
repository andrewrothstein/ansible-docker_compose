#!/usr/bin/env bash
set -e
DIR=~/Downloads
MIRROR=https://github.com/docker/compose/releases/download

# https://github.com/docker/compose/releases/download/v2.10.0/checksums.txt

dl()
{
    local lchecksums=$1
    local ver=$2
    local os=$3
    local arch=$4
    local dotexe=${5:-}
    local platform="${os}-${arch}"
    local exe=docker-compose-${platform}${dotexe}
    # https://github.com/docker/compose/releases/download/v2.10.0/docker-compose-linux-x86_64
    local url=$MIRROR/v$ver/$exe

    local sum
    sum=$(awk -v e="$exe" '$2==e || $2=="*"e {print $1}' "$lchecksums")
    if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'; then
        echo "no valid checksum for $exe in $lchecksums" >&2
        exit 1
    fi

    printf "    # %s\n" "$url"
    printf "    %s: sha256:%s\n" "$platform" "$sum"
}

dl_ver() {
    ver=$1
    printf "  '%s':\n" "$ver"
    local lchecksums="${DIR}/docker-compose-${ver}-checksums.txt"
    if [ ! -e "$lchecksums" ];
    then
        curl -fsSL --proto '=https' --tlsv1.2 -o "$lchecksums" "${MIRROR}/v${ver}/checksums.txt"
    fi

    dl "$lchecksums" "$ver" darwin aarch64
    dl "$lchecksums" "$ver" darwin x86_64
    dl "$lchecksums" "$ver" linux aarch64
    dl "$lchecksums" "$ver" linux armv6
    dl "$lchecksums" "$ver" linux armv7
    dl "$lchecksums" "$ver" linux ppc64le
    dl "$lchecksums" "$ver" linux riscv64
    dl "$lchecksums" "$ver" linux s390x
    dl "$lchecksums" "$ver" linux x86_64
    dl "$lchecksums" "$ver" windows aarch64 .exe
    dl "$lchecksums" "$ver" windows x86_64 .exe
}

for v in "${@:-5.7.0}"; do
    dl_ver "$v"
done
