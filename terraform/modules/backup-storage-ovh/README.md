# backup-storage-ovh

Creates an S3 compatible OVH Object Storage bucket for PDS backups, along with a dedicated user
scoped to that bucket alone

The credentials are exported as sensitive outputs rather than written to the instance via cloud
init, to keep them out of the instance metadata service. See `docs/migration-do-to-ovh.md` for how
to install them on the PDS host.

Versioning is enabled so that a corrupt backup overwriting a good one is recoverable, and
overwritten versions expire after `retention_days`.

## Resources

- https://docs.ovhcloud.com/en/guides/storage-and-backup/object-storage/s3-location
- https://docs.ovh.com/gb/en/storage/s3/identity-and-access-management/
