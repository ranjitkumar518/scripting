#!/usr/bin/env bash

if [ $# -lt 3 ]; then
      echo "Usage: ./modify_rds_instance_class.sh <DB_IDENTIFIER> <AWS_PROFILE> <DB_CLASS>"
      echo "Required: DB_IDENTIFIER, AWS_PROFILE, DB_CLASS"
      echo "Example: ./modify_rds_instance_class.sh devdb preprod db.t2.micro"
      exit
fi

DB_IDENTIFIER=$1
AWS_PROFILE=$2
DB_CLASS=$3

# Identify datbase name with $DB_IDENTIFIER and modify the DB instance class
aws rds modify-db-instance --profile $AWS_PROFILE \
    --db-instance-identifier $DB_IDENTIFIER \
    --db-instance-class $DB_CLASS \
    --apply-immediately
