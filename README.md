# AT Proto PDS

Terraform for hosting an [AT Proto PDS] using:
- [OVHcloud] Public Cloud for compute and backup storage
- AWS [Route 53] for DNS
- [Resend] for email

Currently mid-migration from [DigitalOcean] to OVHcloud. See
[docs/migration-do-to-ovh.md](docs/migration-do-to-ovh.md).

[AT Proto PDS]: https://github.com/bluesky-social/pds
[OVHcloud]: https://www.ovhcloud.com/en-gb/public-cloud/
[DigitalOcean]: https://www.digitalocean.com/
[Route 53]: https://aws.amazon.com/route53/
[Resend]: https://resend.com/

## Pre-reqs

1. Ensure you have a Hosted Zone setup in Route 53 for the domain you wish to use
2. Create the domain `pds.<your root domain>` in Resend
3. Create an OVHcloud Public Cloud project and note its ID
4. Create OVH API credentials at <https://api.ovh.com/createToken/>, with the rights listed in
   [docs/migration-do-to-ovh.md](docs/migration-do-to-ovh.md#before-you-start)
5. Create an OpenStack user under **Public Cloud > Users & Roles** with the `compute_operator` and
   `network_security_operator` roles, then generate a password for it from its **...** menu

## Deploying

From the `./terraform` directory

1. Create a `.auto.tfvars` file containing values for the variables specified in `terraform/variables.tfvars`
2. Run `terraform init` followed by `terraform apply`
3. SSH onto the instance (see Scripts section below) then follow the instructions [here](https://github.com/bluesky-social/pds/tree/main#installing-on-ubuntu-200422042404-and-debian-111213)
4. Set up backups to OVH Object Storage, as described in
   [docs/migration-do-to-ovh.md](docs/migration-do-to-ovh.md#backups)

## Scripts

Copy the `scripts/.env.example` file to `scripts/.env` and fill in your domain name and the SSH
user for your host (`ubuntu` on OVH, `root` on DigitalOcean)

- `./scripts/connect.sh` will open an SSH session with your PDS instance
- `./scripts/update.sh` will run `sudo pdsadmin update` on your PDS
- `./scripts/pdsadmin.sh <args>` will run `sudo pdsadmin <args>` on your PDS

## Migrating your account

If you created an account on Bluesky and would like to migrate it to your self-hosted PDS, follow
the instructions [here](https://whtwnd.com/bnewbold.net/3l5ii332pf32u)
