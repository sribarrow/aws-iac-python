## Components
1. S3 bucket - Allows users uploads
2. lambda function - has access to S3. Uses boto3 to put files into S3
3. API gateway endpoint - Calls Lambda function
4. Another S3 bucket -  web hosting
5. CloudFront Distribution - content delivery

## Iac
    Terraform
    - terraform apply -var-file=variables/dev.tfvars -auto-approve # create resources
    - tf destroy -var-file variables/dev.tfvars # cleanup

## Design Diagram
    Coming soon.

## Upload frontend using CLI
    - aws s3 cp ../frontend/index.html s3://file-uploader-service-app-x6703/ 
    - aws s3 cp ../frontend/app.js s3://file-uploader-service-app-x6703/  
    - aws s3 cp ../frontend/style.css s3://file-uploader-service-app-x6703/   

## Outputs
File-Uploader-App-bucket = "file-uploader-service-app-x6703"
Source-S3-bucket = "user-content-bucket-x6702"
fileuploader-api-endpoint = "lk3ai0nat2" # update this to apiUrl id in app.js
fileuploader-app-url = "dhoepk1vheg2i.cloudfront.net" This is the frontend after upload of the files to bucket

## Reference
    - https://www.pulumi.com/ai/answers/6XmFUBbZJ8tG4Kh8yDa7GL/configuring-aws-cloudfront-with-terraform
    - https://towardsaws.com/implementing-a-file-storage-service-for-user-content-using-api-gateway-lambda-and-s3-part-1-2c5b2d1ae67c