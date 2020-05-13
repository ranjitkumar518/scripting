#!/bin/bash

certs_path=(/etc/ssl/*.crt /etc/ssl/certs/*.crt /etc/rds_certs/rds-combined-ca-bundle.pem)

echo "certs path: $certs_path"
today_date=$( date +%s )

certs_status () {
  for crt in "${certs_path[@]}"; do
    echo "Checking status of certificate: $crt"
    cert_status=`openssl x509 -checkend $(( 24*3600*30 )) -in $crt`
    cert_expiry_date=`openssl x509 -enddate -noout -in $crt | cut -d "=" -f 2`
    expiry_day=$( date -d "$cert_expiry_date" +%s )
    expiry_days="$(( ($expiry_day - $today_date) / (3600 * 24) ))"
    if [ $expiry_days -le -1 ]; then
      echo "$crt Certificate was already expired $expiry_days days ago"
    elif [[ $expiry_days -le 30 ]]; then
      echo "$crt Certificate will expire in next $expiry_days days"
    else
      echo "$crt Certificate is valid for next $expiry_days days"
    fi
  done
}

certs_status
