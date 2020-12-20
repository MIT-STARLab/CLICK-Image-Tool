# Some debugging bash function
function fpga() { python ~/fpga/driver/fpgadriver.py -i 04b4:8613 -v 1d50:602b:0002 $@; }
function rd() { fpga --read $1; }
function wr() { fpga --write $1 $2; }
function temp() {
  local cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
  local cpuTemp1=$(($cpuTemp0/1000))
  local cpuTemp2=$(($cpuTemp0/100))
  local cpuTempM=$(($cpuTemp2 % $cpuTemp1))
  echo $cpuTemp1"."$cpuTempM
}
