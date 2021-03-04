# Some debugging bash functions
function rd() { ~/test/test_fpga_ipc.py $1; }
function wr() { ~/test/test_fpga_ipc.py $1 $2; }
function edfa() { ~/test/test_fpga_ipc.py $@; }

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
    read_journal.sh $1
  fi
}
