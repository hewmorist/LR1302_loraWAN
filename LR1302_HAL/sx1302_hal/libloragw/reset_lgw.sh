#!/bin/bash

# This script is intended to be used on SX1302 CoreCell platform, it performs
# the following actions:
#       - control GPIO lines using gpiod
#       - reset the SX1302 chip and enable the LDOs
#       - reset the optional SX1261 radio used for LBT/Spectral Scan
#
# Usage examples:
#       ./reset_lgw.sh stop
#       ./reset_lgw.sh start

# GPIO mapping has to be adapted with HW
#

# GPIO mapping
SX1302_RESET_PIN=17     # SX1302 reset
SX1302_POWER_EN_PIN=18  # SX1302 power enable
SX1261_RESET_PIN=5      # SX1261 reset (LBT / Spectral Scan)
AD5338R_RESET_PIN=13    # AD5338R reset (full-duplex CN490 reference design)

CHIP="gpiochip0"        # Default GPIO chip (adjust if necessary)

WAIT_GPIO() {
    sleep 0.1
}

init() {
    echo "Initializing GPIOs..."
    gpioset "$CHIP" "$SX1302_RESET_PIN"=0
    gpioset "$CHIP" "$SX1302_POWER_EN_PIN"=0
    gpioset "$CHIP" "$SX1261_RESET_PIN"=0
    gpioset "$CHIP" "$AD5338R_RESET_PIN"=0
}

reset() {
    echo "Performing reset sequence..."
    gpioset "$CHIP" "$SX1302_POWER_EN_PIN"=1; WAIT_GPIO

    gpioset "$CHIP" "$SX1302_RESET_PIN"=1; WAIT_GPIO
    gpioset "$CHIP" "$SX1302_RESET_PIN"=0; WAIT_GPIO

    gpioset "$CHIP" "$SX1261_RESET_PIN"=0; WAIT_GPIO
    gpioset "$CHIP" "$SX1261_RESET_PIN"=1; WAIT_GPIO

    gpioset "$CHIP" "$AD5338R_RESET_PIN"=0; WAIT_GPIO
    gpioset "$CHIP" "$AD5338R_RESET_PIN"=1; WAIT_GPIO
}

term() {
    echo "Cleaning up GPIOs..."
    gpioset "$CHIP" "$SX1302_RESET_PIN"=0
    gpioset "$CHIP" "$SX1302_POWER_EN_PIN"=0
    gpioset "$CHIP" "$SX1261_RESET_PIN"=0
    gpioset "$CHIP" "$AD5338R_RESET_PIN"=0
}

case "$1" in
    start)
        term # Cleanup just in case
        init
        reset
        ;;
    stop)
        reset
        term
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac

exit 0
