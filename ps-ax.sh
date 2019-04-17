#!/usr/bin/env bash


# Собрать все каталоги процессов.
var_proc=`ls -d -1 /proc/* | awk '{print substr($1,7,10)}' | sort -n`   

for i_file in $var_proc
do
  # Если папка число, тогда
  if [[ $i_file =~ ^[0-9]+$ ]] ; then


var_procdir="/proc/$i_file"
if ! [[ -d $var_procdir ]]; then
  continue;
fi

var_pid=`cat $var_procdir/stat | awk '{print $1}'`    #PID

# TTY
if [[ -e "$var_procdir/fd/0" ]]; then
  var_tty=`ls -l $var_procdir/fd/0 | awk '{print substr($11,6,5)}'`;
  
  # Когда socket
  if [[ $var_tty == *":"* ]]; then
    var_tty=null;
  fi
  var_command=`xargs -0 < $var_procdir/cmdline`;
  
else
  var_tty=null;
  var_command='['`cat $var_procdir/status | awk '/Name/{print $2}'`']';  # worker
fi

if [[ ${var_tty} = null ]]; then 
  var_tty='?'; 
fi

# STAT
  var_stat=`cat $var_procdir/stat | awk '{print $3}'`
  
# STAT-NICE - BSD Style
  var_nice_prn='';
  var_nice=`cat $var_procdir/stat | awk '{print $19}'`
  if [[ $var_nice -eq 0 ]]; then
    var_nice_prn='';
  elif [[ $var_nice -gt 0 ]]; then
    var_nice_prn='N';
  elif [[ $var_nice -lt 0 ]]; then
    var_nice_prn='<';
  fi

# STAT '+'; // in foreground process+
var_pgrp=`cat $var_procdir/stat | awk '{print $5}'`
var_tpgid=`cat $var_procdir/stat | awk '{print $8}'`
if [[ var_pgrp -eq var_tpgid ]]; then
  var_nice_prn="$var_nice_prn+";
fi 

# STAT 'l'; // multi-threaded
var_nlwp_prn=''
var_nlwp=`cat $var_procdir/stat | awk '{print $20}'`	
if [[ $var_nlwp -gt 1 ]]; then
  var_nlwp_prn='l';
fi

# STAT 's'; // session leader
var_leader_prn=''
var_session=`cat $var_procdir/stat | awk '{print $6}'`
var_tgid=`cat $var_procdir/status | awk '/Tgid/{print $2}'`
if [[ var_session -eq var_tgid ]]; then
  var_leader_prn='s'
fi

# STAT 'L'has pages locked into memory (for real-time and custom IO)
var_locked_prn=''
var_vmlock=`cat $var_procdir/status | awk '/VmLck/{print $2}'`
if [[ -z var_vmlock ]]; then
  var_leader_prn='L'
fi

# TIME - utime + stime
var_utime=`cat $var_procdir/stat | awk '{print $14}'`
var_stime=`cat $var_procdir/stat | awk '{print $15}'`
var_time=$((var_utime+var_stime))
var_time=$((var_time / 100))
var_time_prn=`date -u -d @${var_time} +"%M:%S"`

# Result string
printf "$var_pid\t$var_tty\t$var_stat$var_nice_prn$var_leader_prn$var_nlwp_prn\t$var_time_prn  $var_command \n"

  else
    continue;
  fi

done

