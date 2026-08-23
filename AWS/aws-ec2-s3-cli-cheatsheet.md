# AWS CLI Cheat Sheet — EC2 & S3

## EC2

### Instances
| Command | Purpose |
|---|---|
| `aws ec2 run-instances` | Launch new instance(s) |
| `aws ec2 describe-instances` | List/describe instances |
| `aws ec2 start-instances` | Start stopped instance(s) |
| `aws ec2 stop-instances` | Stop running instance(s) |
| `aws ec2 reboot-instances` | Reboot instance(s) |
| `aws ec2 terminate-instances` | Terminate instance(s) |
| `aws ec2 describe-instance-status` | Check instance/system status |
| `aws ec2 get-console-output` | Fetch console output |
| `aws ec2 get-console-screenshot` | Screenshot of instance console |
| `aws ec2 describe-instance-types` | List available instance types |
| `aws ec2 describe-instance-attribute` | Get an instance attribute |
| `aws ec2 modify-instance-attribute` | Change an instance attribute |
| `aws ec2 monitor-instances` / `unmonitor-instances` | Toggle detailed CloudWatch monitoring |

### AMIs (Images)
| Command | Purpose |
|---|---|
| `aws ec2 create-image` | Create AMI from instance |
| `aws ec2 deregister-image` | Deregister an AMI |
| `aws ec2 describe-images` | List/describe AMIs |
| `aws ec2 copy-image` | Copy AMI to another region |
| `aws ec2 modify-image-attribute` | Change AMI permissions/attrs |

### EBS Volumes & Snapshots
| Command | Purpose |
|---|---|
| `aws ec2 create-volume` | Create EBS volume |
| `aws ec2 delete-volume` | Delete EBS volume |
| `aws ec2 attach-volume` / `detach-volume` | Attach/detach volume to instance |
| `aws ec2 describe-volumes` | List volumes |
| `aws ec2 modify-volume` | Resize/change volume type |
| `aws ec2 create-snapshot` | Snapshot a volume |
| `aws ec2 delete-snapshot` | Delete a snapshot |
| `aws ec2 describe-snapshots` | List snapshots |
| `aws ec2 copy-snapshot` | Copy snapshot to another region |

### Security Groups
| Command | Purpose |
|---|---|
| `aws ec2 create-security-group` | Create a security group |
| `aws ec2 delete-security-group` | Delete a security group |
| `aws ec2 describe-security-groups` | List security groups |
| `aws ec2 authorize-security-group-ingress` | Allow inbound rule |
| `aws ec2 authorize-security-group-egress` | Allow outbound rule |
| `aws ec2 revoke-security-group-ingress` | Remove inbound rule |
| `aws ec2 revoke-security-group-egress` | Remove outbound rule |

### Key Pairs
| Command | Purpose |
|---|---|
| `aws ec2 create-key-pair` | Create new key pair |
| `aws ec2 delete-key-pair` | Delete key pair |
| `aws ec2 describe-key-pairs` | List key pairs |
| `aws ec2 import-key-pair` | Import your own public key |

### VPC / Networking
| Command | Purpose |
|---|---|
| `aws ec2 create-vpc` / `delete-vpc` / `describe-vpcs` | Manage VPCs |
| `aws ec2 create-subnet` / `delete-subnet` / `describe-subnets` | Manage subnets |
| `aws ec2 create-internet-gateway` / `attach-internet-gateway` | Manage IGWs |
| `aws ec2 create-route-table` / `create-route` / `describe-route-tables` | Manage routing |
| `aws ec2 allocate-address` | Allocate Elastic IP |
| `aws ec2 associate-address` / `release-address` | Attach/release Elastic IP |
| `aws ec2 describe-addresses` | List Elastic IPs |
| `aws ec2 create-nat-gateway` / `describe-nat-gateways` | Manage NAT gateways |

### ENIs, Tags, Regions
| Command | Purpose |
|---|---|
| `aws ec2 create-network-interface` / `delete-network-interface` | Manage ENIs |
| `aws ec2 attach-network-interface` / `detach-network-interface` | Attach/detach ENIs |
| `aws ec2 create-tags` / `delete-tags` / `describe-tags` | Manage tags |
| `aws ec2 describe-regions` / `describe-availability-zones` | List regions/AZs |

### Auto Scaling (separate namespace)
| Command | Purpose |
|---|---|
| `aws autoscaling create-auto-scaling-group` | Create ASG |
| `aws autoscaling update-auto-scaling-group` | Update ASG |
| `aws autoscaling describe-auto-scaling-groups` | List ASGs |
| `aws autoscaling set-desired-capacity` | Change desired capacity |

---

## S3

Two command sets: `aws s3` (high-level, simplified) and `aws s3api` (low-level, full API control).

### `aws s3` — high-level
| Command | Purpose |
|---|---|
| `aws s3 ls` | List buckets or objects |
| `aws s3 cp` | Copy file(s) to/from S3 |
| `aws s3 mv` | Move file(s) |
| `aws s3 rm` | Delete file(s) |
| `aws s3 sync` | Sync a directory to/from a bucket |
| `aws s3 mb` | Make bucket |
| `aws s3 rb` | Remove bucket |
| `aws s3 presign` | Generate presigned URL |
| `aws s3 website` | Configure static website hosting (shortcut) |

**Examples**
```bash
aws s3 cp file.txt s3://my-bucket/
aws s3 sync ./localdir s3://my-bucket/remotedir
aws s3 rm s3://my-bucket/file.txt
aws s3 ls s3://my-bucket --recursive
```

### `aws s3api` — low-level

**Buckets**
| Command | Purpose |
|---|---|
| `create-bucket` | Create a bucket |
| `delete-bucket` | Delete a bucket |
| `list-buckets` | List all buckets |
| `head-bucket` | Check bucket exists/access |

**Objects**
| Command | Purpose |
|---|---|
| `put-object` | Upload an object |
| `get-object` | Download an object |
| `delete-object` | Delete an object |
| `delete-objects` | Batch delete objects |
| `copy-object` | Copy an object |
| `list-objects-v2` | List objects in a bucket |
| `head-object` | Get object metadata only |
| `list-object-versions` | List versions (versioned bucket) |
| `restore-object` | Restore from Glacier |
| `select-object-content` | Query CSV/JSON/Parquet in place (S3 Select) |

**Bucket Configuration**
| Command | Purpose |
|---|---|
| `put-bucket-policy` / `get-bucket-policy` / `delete-bucket-policy` | Manage bucket policy |
| `put-bucket-acl` / `get-bucket-acl` | Manage ACLs |
| `put-bucket-versioning` / `get-bucket-versioning` | Toggle versioning |
| `put-bucket-encryption` / `get-bucket-encryption` | Manage default encryption |
| `put-bucket-lifecycle-configuration` / `get-bucket-lifecycle-configuration` | Manage lifecycle rules |
| `put-bucket-cors` / `get-bucket-cors` | Manage CORS |
| `put-bucket-website` / `get-bucket-website` | Static website config |
| `put-bucket-tagging` / `get-bucket-tagging` | Manage bucket tags |

**Object Tagging**
| Command | Purpose |
|---|---|
| `put-object-tagging` / `get-object-tagging` | Manage object tags |

**Multipart Upload**
| Command | Purpose |
|---|---|
| `create-multipart-upload` | Start a multipart upload |
| `upload-part` | Upload a part |
| `complete-multipart-upload` | Finish upload |
| `abort-multipart-upload` | Cancel upload |
| `list-multipart-uploads` | List in-progress uploads |

---

## Quick Reference
```bash
aws ec2 help              # all EC2 commands
aws ec2 <command> help    # flags for a specific command
aws s3 help                # high-level S3 commands
aws s3api help             # low-level S3 commands
```
