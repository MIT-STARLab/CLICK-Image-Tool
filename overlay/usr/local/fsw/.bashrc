# Some debugging bash functions
function fpga() { python ~/fpga/fpgadriver.py -i 04b4:8613 -v 1d50:602b:0002 $@; }
function rd() { fpga --read $1; }
function wr() { fpga --write $1 $2; }

function temp() {
  local cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
  local cpuTemp1=$(($cpuTemp0/1000))
  local cpuTemp2=$(($cpuTemp0/100))
  local cpuTempM=$(($cpuTemp2 % $cpuTemp1))
  echo $cpuTemp1"."$cpuTempM
}

function log() {
  if [[ -z $1 || $1 -lt 1 ]]; then
    journalctl -b $1
  else
    offset=$1
    readarray -t ids < /mnt/journal/id.txt
    len=${#ids[@]}
    requested=$((len-offset-1))
    journalctl --file /mnt/journal/${ids[$requested]}/system.journal
  fi
}
