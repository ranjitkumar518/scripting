## command to run cron job at the last day of the month
[ $(date +\%d -d tomorrow) = 01 ] && /root/audit_report.sh >> /var/log/audit_report.log 2>&1
