# dns-pds-aws

Creates DNS records required to host the PDS on a subdomain of an existing
hosted zone in Route 53

These are (by default):
- `pds.yourdomain.com`
- `*.pds.yourdomain.com`

The `pds` prefix is configurable via the `subdomain` variable of the module
