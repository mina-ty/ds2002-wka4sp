#!/usr/local/bin/python3

import boto3
import requests
import argparse

s3 = boto3.client('s3', region_name='us-east-1')

# Use the argparse library to customize command-line arguments with a Python script
# Source: https://stackoverflow.com/questions/67730981/very-basic-example-of-argparse
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--link")
parser.add_argument("-n", "--name")
parser.add_argument("-b", "--bucket")

args = parser.parse_args()
file_link = args.link
file_name = args.name
bucket_name = args.bucket

# Fetch and save a file from the internet using requests
response = requests.get(file_link, stream=True)
response.raise_for_status()
with open(file_name, 'wb') as file:
    for chunk in response.iter_content(chunk_size=8192):
        file.write(chunk)
print(f"File downloaded to {file_name}.")

# Upload the file to a bucket in S3
with open(file_name, 'rb') as file:
    resp = s3.put_object(
        Body=file,
        Bucket=bucket_name,
        Key=file_name
    )
print(f"File uploaded to {bucket_name} S3 bucket.")

# Presign the file with an expiration time
response = s3.generate_presigned_url(
    'get_object',
    Params={'Bucket': bucket_name, 'Key': file_name},
    ExpiresIn=30
)

# Output the presigned URL
print(f"View {file_name} in S3 at {response}. Note that this link will expire in 30 seconds.")