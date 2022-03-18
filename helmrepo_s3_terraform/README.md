# Assessment - Terraform

This is a project to create an S3 bucket that serves as a Helm repo. It configures basic encryption and supports sharing the bucket across many accounts.

# Requirements

|      Name     |   Version   |
| ------------- | ------------|
| terraform     | >= 0.12.19  |
|               |             |
| aws           | >= 3.0.0    |

  
# Providers

|      Name     |   Version   |
| ------------- | ------------|
| aws           | >= 3.0.0    |


# Resources


|                                  Name                                  |       Type      |
| ---------------------------------------------------------------------- | --------------- |
| aws_s3_bucket.helmrepo_bucket                                          |    resource     |
|                                                                        |                 |
| aws_s3_bucket_policy.helmrepo_bucket                                   |    resource     |
|                                                                        |                 |
| aws_s3_bucket_public_access_block.helmrepo_bucket                      |    resource     |
|                                                                        |                 |
| aws_caller_identity.current                                            |   data source   |
|                                                                        |                 |
| aws_iam_policy_document.s3_permissions                                 |   data source   |
|                                                                        |                 |
| aws_region.region                                                      |   data source   |
|                                                                        |                 |
| aws_s3_bucket_public_access_block.no_public_log_access                 |    resource     |
|                                                                        |                 |
| aws_s3_bucket_server_side_encryption_configuration.bucket_encryption   |    resource     |
|                                                                        |                 |
| aws_s3_bucket.helmrepo_log_bucket                                      |    resource     |
|                                                                        |                 |
| aws_s3_bucket_acl.log_bucket_acl                                       |    resource     |
|                                                                        |                 |
| aws_s3_bucket_logging.bucket_logging                                   |    resource     |
|                                                                        |                 |
| aws_s3_bucket_public_access_block.no_public_access                     |    resource     |
|                                                                        |                 |
| aws_s3_bucket_versioning.bucket_versioning                             |    resource     |


# Inputs


|                   Name                          |                            Description                      |
| ----------------------------------------------- | ----------------------------------------------------------- |
| region                                          |    AWS Region to create the bucket in                       |
|                                                 |                                                             |
| allowed_account_ids                             |    List of AWS account IDs to grant read-only access        |
|                                                 |                                                             |
|  allowed_account_ids_write                      |    List of AWS account IDs to grant write access            |
|                                                 |                                                             |
| helmrepo_log_bucket_name                        |    S3 bucket name to log bucket access requests to          |
|                                                 |                                                             |
| Name                                            |    Bucket name for the helm repo.                           |
|                                                 |                                                             |
| Tags                                            |    Tags to add to supported resources                       |


# Outputs


|      Name     |         description        |
| ------------- | ---------------------------|
|   s3_bucket   |   Bucket name of the repo  |


