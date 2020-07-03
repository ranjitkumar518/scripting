#!/bin/bash
env=$1
bucket=$2
email_to=$3
echo "disabling publication by updating the bucket policy"
aws s3api put-bucket-policy --bucket $bucket --cli-input-json '{"Policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowAccess\",\"Effect\":\"Deny\",\"Principal\":{\"AWS\":\"arn:aws:iam::XXXXXXXXXXXX:role/publish-role\"},\"Action\":\"s3:PutObject*\",\"Resource\":[\"arn:aws:s3:::test-bucket-us-west-2\",\"arn:aws:s3:::test-bucket-prd-us-west-2/*\"]}]}"}'
if [ $? -ne 0 ]; then
    echo "Failed to update bucket policy. sending notification...."
    aws ses send-email --from $email_to --to $email_to  --subject "$env : update bucket policy failed" --text "update bucket policy on `hostname` against bucket: $bucket" --region=us-west-2
    exit 1;
fi

echo "Disabling ics publication is successful. sending notification...."
aws ses send-email --from $email_to --to $email_to  --subject "$env : update bucket policy is successful" --text "update bucket policy successful on `hostname` against bucket: $bucket" --region=us-west-2
