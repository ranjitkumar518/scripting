## command to run cron job at the end of the month
[ $(date +\%d -d tomorrow) = 01 ] && /intuit/commerce/audit_report.sh >> /var/log/audit_report.log 2>&1
