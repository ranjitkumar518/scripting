## command to run cron job at the last day of the month
[ $(date +\%d -d tomorrow) = 01 ] && /root/run_report.sh >> /var/log/report.log 2>&1
