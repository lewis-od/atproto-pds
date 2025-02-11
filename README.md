# AT Proto PDS

Terraform for hosting an [AT Proto PDS] using:
- [DigitalOcean] for compute
- AWS [Route 53] for DNS
- [Resend] for email

[AT Proto PDS]: https://github.com/bluesky-social/pds
[DigitalOcean]: https://www.digitalocean.com/
[Route 53]: https://aws.amazon.com/route53/
[Resend]: https://resend.com/

## Pre-reqs

1. Ensure you have a Hosted Zone setup in Route 53 for the domain you wish to use
2. Create the domain `pds.<your root domain>` in Resend
3. Create a project in DigitalOcean and create an API Key
4. Add an SSH key to your Digital Ocean account
5. Find the ID of the SSH key you added by running
    ```shell
    curl -X GET \                     
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
      "https://api.digitalocean.com/v2/account/keys"
    ```

## Deploying

From the `./terraform` directory

1. Create a `.auto.tfvars` file containing values for the variables specified in `terraform/variables.tfvars`
2. Run `terraform init` followed by `terraform apply`
3. SSH onto the instance (see Scripts section below) then follow the instructions [here](https://github.com/bluesky-social/pds/tree/main?tab=readme-ov-file#installer-on-ubuntu-20042204-and-debian-1112)

## Scripts

Copy the `scripts/.env.example` file to `scripts/.env` and fill in your domain name

- `./scripts/connect.sh` will open an SSH session with your PDS instance
- `./scripts/update.sh` will run `sudo pdsadmin update` on your PDS
- `./scripts/pdsadmin.sh <args>` will run `sudo pdsadmin <args>` on your PDS
