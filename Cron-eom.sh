[ $(date +\%d -d tomorrow) = 01 ] && /intuit/commerce/audit_report.sh >> /var/log/audit_report.log 2>&1
