#!/usr/bin/env bash
NC='\033[0m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'

export SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

echo -e "
${LIGHTGREEN}
░██████╗░██████╗░███████╗██╗░░██╗ 
██╔════╝░██╔══██╗██╔════╝╚██╗██╔╝
██║░░██╗░██████╔╝█████╗░░░╚███╔╝░
██║░░╚██╗██╔══██╗██╔══╝░░░██╔██╗░
╚██████╔╝██║░░██║███████╗██╔╝╚██╗
░╚═════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
${NC}
"

###### Initial Setup
CHANNELS=2048
export DADA_SAMPLES=200000
export KEY=b0ba
export FPGA_ADDR="192.168.0.3"

echo -e "${LIGHTRED}SETTING UP SNAP${NC}"
snap_bringup "$SCRIPT_DIR"/../t0/gateware/grex_gateware.fpg ${FPGA_ADDR} --gain=1

echo -e "${LIGHTRED}SETTING UP PSRDADA BUFFERS${NC}"
# Data is float32s all around, so 4 bytes per pixel
dada_db -k ${KEY} -b $((CHANNELS*DADA_SAMPLES*4)) -l -p

echo -e "${LIGHTRED}STARTING PIPELINE${NC}"
parallel -u ::: "${SCRIPT_DIR}/./tasks/t0.sh 1" "${SCRIPT_DIR}/./tasks/t1.sh 2"

echo -e "${LIGHTRED}CLEANING UP${NC}"
dada_db -k ${KEY} -d
