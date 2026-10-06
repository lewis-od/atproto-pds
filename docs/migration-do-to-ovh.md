# Migrating the PDS from DigitalOcean to OVH

Moves the PDS from a DigitalOcean Droplet in `lon1` to an OVH Public Cloud `d2-2` instance in
`UK1`, with no data loss and around ten minutes of downtime.

## Approach

This is a lift and shift of the `/pds` directory, not an AT Protocol account migration.

Everything the PDS owns lives under `/pds`: `pds.env` (which holds the JWT secret, the admin
password and the PLC rotation key), `account.sqlite`, `sequencer.sqlite`, `did_cache.sqlite`, the
per-actor SQLite repos under `actors/`, the blobstore under `blocks/`, and the Caddy TLS
certificates under `caddy/`.

Copy that directory byte for byte onto a new host serving the same hostname and the DID document
never changes. No PLC operation is needed, the handle stays resolvable, and the firehose sequence
continues from where it left off. The only thing that changes is the IP address behind
`pds.<your root domain>`.

Carrying `caddy/` across also carries the existing certificates, so Caddy does not need to complete
an ACME challenge at the moment of cutover.

```mermaid
flowchart LR
  A["DigitalOcean Droplet<br/>lon1"] -->|"2. warm copy of /pds"| B["OVH instance<br/>UK1, d2-2"]
  A -->|"3. stop PDS, copy delta"| B
  C["Route 53<br/>pds + *.pds A records"] -->|"4. cutover_dns_to_ovh = true"| B
  B -->|"5. verify"| D["health, repo, login"]
  A -->|"7. destroy after a week"| E(("decommissioned"))
```

## Before you start

1. Create an OVH Public Cloud project, and note its ID. This is also the OpenStack tenant ID.
2. Create OVH API credentials at <https://api.ovh.com/createToken/>. The `ovh` provider only
   manages the backup bucket and the backup user, so grant only the rights below, substituting your
   project ID and, if you changed `ovh_storage_region`, your storage region:

   ```text
   GET     /auth/details
   GET     /cloud/project/<project-id>
   GET     /cloud/project/<project-id>/role
   GET     /cloud/project/<project-id>/user
   POST    /cloud/project/<project-id>/user
   GET     /cloud/project/<project-id>/user/*
   POST    /cloud/project/<project-id>/user/*
   PUT     /cloud/project/<project-id>/user/*
   DELETE  /cloud/project/<project-id>/user/*
   GET     /cloud/project/<project-id>/region/UK/storage
   POST    /cloud/project/<project-id>/region/UK/storage
   GET     /cloud/project/<project-id>/region/UK/storage/*
   PUT     /cloud/project/<project-id>/region/UK/storage/*
   DELETE  /cloud/project/<project-id>/region/UK/storage/*
   ```

   `GET /auth/details` is not optional. The provider validates its credentials with that call before
   it does anything else, so without it every apply fails at provider configuration.

   This gives you an application key, application secret and consumer key.
3. In the OVH control panel under **Public Cloud > Users & Roles**, create a user with the
   `compute_operator` and `network_security_operator` roles. Terraform uses this user only for the
   instance, its keypair and its security group, so it does not need `administrator`.

   The user has no password when it is created. Get one from the user's **...** menu, under
   **Generate a password**. It is shown once and cannot be retrieved later, so put it straight into
   `.auto.tfvars`; if you lose it, generate a new one, which invalidates the old. The username is
   listed next to the user in the same table.

   OVH does not publish a per-role permission matrix, so if an apply returns a 403, add the matching
   role and run it again. Changing a user's roles does not invalidate its password:

   | 403 on | Add |
   | ------------------------------------------- | --------------------------- |
   | `openstack_images_image_v2` | `image_operator` |
   | `openstack_networking_secgroup_v2`, or attaching the instance to `Ext-Net` | `network_operator` |
4. Add the new variables to your `.auto.tfvars`:

   ```hcl
   ovh_project_id         = "..."
   ovh_application_key    = "..."
   ovh_application_secret = "..."
   ovh_consumer_key       = "..."
   openstack_user_name    = "..."
   openstack_password     = "..."
   ssh_public_key         = "ssh-ed25519 AAAA... you@example.com"
   backup_bucket_name     = "..." # must be unique within the region
   ```

Leave `cutover_dns_to_ovh` at its default of `false`. While it is `false`, DNS keeps pointing at the
Droplet, so every step up to the cutover is safe to apply.

## Procedure

### 1. Provision the OVH instance and backup bucket

```shell
terraform init -upgrade
terraform apply
```

This creates the instance, its security group, the backup bucket and a bucket-scoped user, and
leaves DNS pointing at DigitalOcean. Note the new IP:

```shell
terraform output server_ip
```

### 2. Install a bare PDS on the new instance

The OVH Ubuntu images log in as `ubuntu`, not `root`.

```shell
ssh ubuntu@$(terraform output -raw server_ip)
sudo bash -c 'wget https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh && bash installer.sh'
```

Give the installer the same domain as the existing PDS. The secrets it generates are thrown away in
step 4, but running it is what installs Docker, the `pds` systemd unit and `pdsadmin`.

Stop it once the install finishes, so nothing is writing to `/pds` while you copy into it:

```shell
sudo systemctl stop pds
```

### 3. Warm copy, while the old PDS is still serving

This moves the bulk of the data with no downtime. Repeat it as often as you like; each run only
transfers what changed.

```shell
sudo rsync -aHAX --rsync-path='sudo rsync' \
  root@pds.<your root domain>:/pds/ /pds/
```

### 4. Cut over

Downtime starts here. Stop the old PDS first, so the two instances never serve the same repo at
once — running both would fork the firehose sequence.

```shell
# on your machine
ssh root@pds.<your root domain> 'systemctl stop pds'

# on the OVH instance
sudo rsync -aHAX --delete --rsync-path='sudo rsync' \
  root@pds.<your root domain>:/pds/ /pds/
```

The copy brings the Droplet's `pds.env` with it, including an SMTP URL on a port OVH blocks, so
repoint it at one of Resend's alternative ports before the PDS starts. This has to happen after the
final rsync, or the copy overwrites it:

```shell
# on the OVH instance, 465 -> 2465, or 587 -> 2587 if yours uses STARTTLS
sudo sed -i 's|@smtp\.resend\.com:465|@smtp.resend.com:2465|' /pds/pds.env
grep -i smtp /pds/pds.env
```

Point DNS at the new instance by setting `cutover_dns_to_ovh = true` in your `.auto.tfvars`, then:

```shell
terraform apply
```

The records have a 300 second TTL. Wait for it to expire, then start the new PDS:

```shell
ssh ubuntu@$(terraform output -raw server_ip) 'sudo systemctl start pds'
```

### 5. Verify

```shell
curl https://pds.<your root domain>/xrpc/_health
curl "https://pds.<your root domain>/xrpc/com.atproto.repo.describeRepo?repo=<your DID>"
curl https://plc.directory/<your DID>
```

The `describeRepo` call should return your handle and collections. The PLC entry should be
unchanged, still pointing at the same hostname — if it changed, something went wrong and you should
stop and investigate rather than continue.

Then log in from the Bluesky app and post.

### 6. Set up backups

See [Backups](#backups) below. Do this before decommissioning the Droplet, so you are never running
without one.

### 7. Decommission DigitalOcean

Wait about a week, and confirm backups are landing in the bucket, before you do this. Until the
Droplet is destroyed it remains a complete, bootable rollback.

Power the Droplet off first and run for a few days on OVH alone. Then remove the following from the
repository and apply:

- `module "pds_droplet"` and `output "droplet_ip"`
- the `digitalocean` provider and its `required_providers` entry
- the `digitalocean_token`, `digitalocean_ssh_key_id` and `droplet_region` variables
- the `cutover_dns_to_ovh` variable, replacing its use in `module "pds_dns"` with
  `module.pds_instance.ip_address`
- the `./modules/droplet` directory

Each of these is marked with a `TODO` referencing this document.

## Backups

The OVH instance has no managed snapshot workflow, by choice. The backup is a copy of `/pds` in OVH
Object Storage, which is also what you would restore from onto a fresh host — the same procedure you
just rehearsed above.

Terraform has already created the bucket and a user scoped to it alone. Install the credentials on
the instance:

```shell
terraform output -raw backup_access_key_id
terraform output -raw backup_secret_access_key
```

These are deliberately not injected via cloud-init, because instance metadata is readable by
anything running on the box and is stored by OVH. Write them out over SSH instead:

```shell
sudo install -m 600 /dev/null /root/.pds-backup.env
sudo tee /root/.pds-backup.env >/dev/null <<'EOF'
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=uk
export BACKUP_ENDPOINT=https://s3.uk.io.cloud.ovh.net
export BACKUP_BUCKET=...
EOF
```

### Why not rsync the SQLite files directly

`blocks/`, `caddy/`, `pds.env` and `compose.yaml` are safe to copy while the PDS runs. The SQLite
databases are not — they run in WAL mode, and copying an open one can produce a torn file that only
fails when you try to restore it. Use the SQLite online backup API for those, which is safe against
a live writer.

`sqlite3` is already installed; the PDS installer requires it.

```shell
sudo tee /usr/local/bin/pds-backup >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

. /root/.pds-backup.env

STAGE=/var/backups/pds
mkdir -p "$STAGE"

find /pds -name '*.sqlite' -print0 | while IFS= read -r -d '' db; do
  dest="$STAGE/${db#/pds/}"
  mkdir -p "$(dirname "$dest")"
  sqlite3 "$db" ".backup '$dest'"
done

rsync -a --delete --exclude '*.sqlite*' /pds/ "$STAGE/"

aws s3 sync "$STAGE/" "s3://$BACKUP_BUCKET/pds/" \
  --endpoint-url "$BACKUP_ENDPOINT" --delete
EOF
sudo chmod 700 /usr/local/bin/pds-backup
```

Then schedule it, for example nightly at 03:00:

```shell
echo '0 3 * * * root /usr/local/bin/pds-backup' | sudo tee /etc/cron.d/pds-backup
```

Run it once by hand and confirm objects appear in the bucket before relying on it.

### Restoring

Follow steps 1, 2 and 4 of the procedure above, replacing the `rsync` with an `aws s3 sync` in the
opposite direction, onto a stopped PDS.

## Notes

- **`d2-2` is OVH's Discovery range.** It is best effort with no SLA and cannot be resized into
  another family. `b3-8` is the general purpose equivalent if that becomes a problem.
- **Filtering is done by nftables on the instance, not by a security group.** The UK1 security
  group quota on this project is 0, so `instance-ovh` renders `firewall_rules_inbound` into
  `/etc/nftables.conf` through cloud-init and the instance sits on OVH's `default` group. The
  ruleset resets only its own `inet filter` table rather than running `flush ruleset`, which would
  also wipe the chains Docker installs for the PDS containers.
- **A host firewall does not cover container published ports.** Docker publishes 80 and 443 by
  DNAT, so that traffic traverses `forward`, not `input`, and the nftables `input` policy never
  sees it. Those two ports are meant to be open to the internet anyway, but it does mean the host
  firewall protects host services such as sshd and nothing else. A security group would cover both,
  which is the remaining reason to take the quota if OVH grants it.
- **OVH's `default` security group is permissive inbound but not outbound.** Its two ingress rules
  set no protocol, port or remote, so every port is reachable from the internet, IPv4 and IPv6. Its
  egress rules cover `1-24`, `26-464`, `466-586` and `588-65535`, which silently drops outbound
  SMTP on 25, 465 and 587 — connections to those ports hang rather than fail. Resend also listens
  on 2465 and 2587, which the ranges above allow, so the PDS reaches it on those. A security group
  you create yourself gets allow-all egress and does not have this problem.
- **The backup user is scoped by policy, not by role.** OVH has no object storage role narrower
  than `objectstore_operator`, which grants access to every bucket in the project. The
  `ovh_cloud_project_user_s3_policy` on that user is what reduces it to this one bucket, so the
  policy is load bearing — removing it widens the user's access rather than narrowing it.
- **`pds.env` contains the PLC rotation key.** Anywhere it is copied to needs to be treated as
  secret. Losing the key means you can never update your DID document; leaking it means someone else
  can. The backup bucket is encrypted at rest and reachable only by its own scoped user.
