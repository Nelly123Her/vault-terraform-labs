### Operator init
The operator init command initializes a Vault server. Initialization is the process by which Vault's storage backend is prepared to receive data. Since Vault servers share the same storage backend in HA mode, you only need to initialize one Vault to initialize the storage backend. This command cannot be run against already-initialized Vault cluster.

**-key-shares (int: 5)** - Number of key shares to split the generated master key into. This is the number of "unseal keys" to generate. This is aliased as -n.

**-key-threshold (int: 3)** - Number of key shares required to reconstruct the root key. This must be less than or equal to -key-shares. This is aliased as -t.

**-pgp-keys (string: "...")** - Comma-separated list of paths to files on disk containing public PGP keys OR a comma-separated list of Keybase usernames using the format keybase:<username>. When supplied, the generated unseal keys will be encrypted and base64-encoded in the order specified in this list. The number of entries must match -key-shares, unless -stored-shares are used.
#### »HSM and KMS Options
**-recovery-pgp-keys (string: "...")** - Behaves like **-pgp-keys**, but for the recovery key shares. This is only used with Auto Unseal seals (HSM, KMS and Transit seals).

**-recovery-shares (int: 5)** - Number of key shares to split the recovery key into. This is only used Auto Unseal seals (HSM, KMS and Transit seals).

**-recovery-threshold (int: 3)** - Number of key shares required to reconstruct the recovery key. This is only used Auto Unseal seals (HSM, KMS and Transit seals).
### Configuration File
1. Vault servers are configured using a file
1. Written in HCL or JSON
1. The configuration file includes different stanzas and parameters to define a variety of configuration options
1. Configuration file is specified when starting Vault using the – config flag
1. Usually stored somewhere in /etc (doesn’t have to be)
1. I store mine at /etc/vault.d/vault.hcl
```sh
 vault server –config <location>
```
```sh
vault server –config /etc/vault.d/vault.hcl
```
---
### Create a server on linux
```sh
ui = true

#mlock = true
#disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

#storage "consul" {
#  address = "127.0.0.1:8500"
#  path    = "vault"
#}

# HTTP listener
#listener "tcp" {
#  address = "127.0.0.1:8200"
#  tls_disable = 1
#}

# HTTPS listener
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable = true
}
```
#### Deploy a vault dev server

```sh
vault server -dev
```
---
# Auto Unseal
### 1. Auto Unseal AWS

```sh
seal "awskms" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  kms_key_id = "19ec80b0-dfdd-4d97-8164-c6examplekey"
  endpoint   = "https://vpce-0e1bb1852241f8cc6-pzi0do8n.kms.us-east-1.vpce.amazonaws.com"
}
```

### 2. Auto Unseal Azure

```sh
seal "azurekeyvault" {
  tenant_id      = "46646709-b63e-4747-be42-516edeaf1e14"
  client_id      = "03dc33fc-16d9-4b77-8152-3ec568f8af6e"
  client_secret  = "DUJDS3..."
  vault_name     = "hc-vault"
  key_name       = "vault_key"
}
```

### 3. Auto Unseal Google

```sh
seal "gcpckms" {
  credentials = "/usr/vault/vault-project-user-creds.json"
  project     = "vault-project"
  region      = "global"
  key_ring    = "vault-keyring"
  crypto_key  = "vault-key"
}
```

### Auto-transit

```sh
seal "transit" {
  address            = "https://vault:8200"
  token              = "s.Qf1s5zigZ4OX6akYjQXJC1jY"
  disable_renewal    = "false"

  // Key configuration
  key_name           = "transit_key_name"
  mount_path         = "transit/"
  namespace          = "ns1/"

  // TLS Configuration
  tls_ca_cert        = "/etc/vault/ca_cert.pem"
  tls_client_cert    = "/etc/vault/client_cert.pem"
  tls_client_key     = "/etc/vault/ca_cert.pem"
  tls_server_name    = "vault"
  tls_skip_verify    = "false"
}
```

```sh
api_addr          = "https://vault:8200"
cluster_addr      = "https://vault:8201"
#cluster_name      = "vault"
disable_mlock     = "true"
log_level         = "Info"
plugin_directory  = "/var/vault/plugins/"
ui                = "true"



listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/certs/tls.crt"
  tls_key_file  = "/opt/vault/certs/tls.key"
}

storage "raft" {
  path            = "/var/vault/storage/"
  #node_id         = "hostname"
}
```

```sh
storage "raft" {
path = "/opt/vault/data"
node_id = "node-a-us-east-1.example.com"
retry_join {
auto_join = "provider=aws region=us-east-1 tag_key=vault tag_value=us-east-1"
}
}
listener "tcp" {
address = "0.0.0.0:8200"
cluster_address = "0.0.0.0:8201"
tls_disable = 0
tls_cert_file = "/etc/vault.d/client.pem"
tls_key_file = "/etc/vault.d/cert.key"
tls_disable_client_certs = "true"
}
seal "awskms" {
region = "us-east-1"
kms_key_id = "12345678-abcd-1234-abcd-123456789101",
endpoint = "example.kms.us-east-1.vpce.amazonaws.com"
}
api_addr = "https://vault-us-east-1.example.com:8200"
cluster_addr = " https://node-a-us-east-1.example.com:8201"
cluster_name = "vault-prod-us-east-1"
ui = true
log_level = "INFO"
```


### Raft Storage
vault operator raft join https://active_node.example.com:8200

vault operator raft list-peers
#### HSM


---

###  Auth Methods
The approle auth method allows machines or apps to authenticate with Vault-defined roles.  
Each auth method is enabled at a path
1. You can choose the path name when (and only when) you enable the auth method
1. If you do not provide a name, the auth method will be enabled at its 
default path
1. The default path name is equal to the type of auth method (i.e., aws is 
mounted at "aws", approle is mounted at "approle")

#### Enabling an auth method
```sh
$ vault auth enable approle
```

#### Disabling an auth method
```sh
$ vault auth disable approle
```
#### Listing  auth methods
```sh
$ vault auth list
```

#### Enable an Auth Method at the default Path

```sh
$ vault auth enable approle
Success! Enabled approle auth method at: approle/
Enable an Auth Method using a Custom Path
```
#### Enable an Auth Method at the custom Path

```sh
$ vault auth enable –path=vault-custom approle
Success! Enabled approle auth method at: vault-course/
```

```sh
vault write auth/approle/role/vault-course \
secret_id_ttl=10m \
token_num_uses=10 \
token_ttl=20m \
token_max_ttl=30m \
secret_id_num_uses=40
```

### 1. Enable Approle
```sh
vault auth list
```
```sh
vault auth enable approle
```
#### Create a role
```sh
vault write auth/approle/role/my-role \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40
```
#### Another way to write a role
```sh
vault write auth/approle/role/my-role \
    token_ttl=20m \
    policies=mypolicy \
```
#### Generate a secret id
```sh
vault write -f auth/approle/role/my-role/secret-id
```
#### Get login with role-id and secret-id

```sh
vault write auth/approle/login role_id=""
secret-id=""
```

### 2. Enable Okta authentication

```sh
vault auth enable okta
```
#### 
```sh
vault write auth/okta/config \
   base_url="okta.com" \
   org_name="dev-123456" \
   api_token="00abcxyz..."
```
####  Login with okta
```sh
vault login -method=okta username=my-username
```
---



### Configuring Auth methods using cli
#### Enable userpass
```sh
vault auth enable userpass 
Success! Enabled userpass auth method at: userpass/
```

```sh
vault auth list  
Path         Type        Accessor                  Description
----         ----        --------                  -----------
token/       token       auth_token_2860d3d7       token based credentials
userpass/    userpass    auth_userpass_c0227363    n/a
```
 
```sh
 vault auth tune -default-lease-ttl=24h userpass 
Success! Tuned the auth method at: userpass/
```
```sh
vault  write auth/userpass/users/nelly password=vault policies=polisy.hcl   
Success! Data written to: auth/userpass/users/nelly
```
### Login with userpass method 

```sh
$ vault login -method=userpass username=nelly 
Password (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  "TOKEN"
token_accessor         ymmnrVi9DmZ8m6C3lugcRmm6
token_duration         768h
token_renewable        true
token_policies         ["admins" "default"]
identity_policies      []
policies               ["admins" "default"]
token_meta_username    nelly
```


---
### Policies

#### Vault Policies - Capabilities
• Create – create a new entry
• Read – read credentials, configurations, etc
• Update – overwrite the existing value of a secret or configuration
• Delete – delete something
• List – view what's there (doesn't allow you to read)
• Sudo – used for root-protected paths
• Deny – deny access – always takes presedence over any other capability

List all enabled policies:
```sh
$ vault policy list
```
  Create a policy named "my-policy" from contents on local disk:
```sh
$ vault policy write my-policy ./my-policy.hcl
```
  Delete the policy named my-policy:
```sh
$ vault policy delete my-policy
```
```sh
vault list auth/userpass/users/                                                                                       
Keys
----
vault read auth/userpass/users/
Key                        Value
---                        -----
policies                   [polisy.hcl]
token_bound_cidrs          []
token_explicit_max_ttl     0s
token_max_ttl              0s
token_no_default_policy    false
token_num_uses             0
token_period               0s
token_policies             [polisy.hcl]
token_ttl                  0s
token_type                 default
```





### Install Premium Version on RedHat distros
```sh
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum --showduplicates list vault-enterprise-hsm
yum --showduplicates list vault-enterprise
sudo yum -y install vault-enterprise-hsm.x86_64
sudo yum -y install vault-enterprise-hsm-1.9.4+ent-1.x86_64
sudo yum -y install vault-enterprise
sudo yum -y install vault
vault version
vault status
systemctl enable vault
systemctl start vault
systemctl status vault.service

 
firewall-cmd --zone=public --add-port=8200/tcp --permanent
  573  firewall-cmd --reload
export VAULT_LICENSE=HDDZLUpG7jP$)fA*)f<5_nYq#rgGkCL5qMT\~NRX;{;M.q~Y_heF+sP~$;#H?RVGrj+qt)mw"\Y[?h*$)

  
```

### Wildcards on vault

### *

Can be used to signify anything "after" a path or as part of a pattern

1. secret/apps/application1/* - allows any path after application1
1. kv/platform/db-* - would match kv/platform/db-2 but not kv/platform/db2

### +
The plus (+) supports wildcard matching for a single directory in the
path 
• Can be used in multiple path segments (i.e., secret/+/+/db)
• Examples:
• secret/+/db - matches secret/db2/db or secret/app/db
• kv/data/apps/+/webapp – matches the following:
• kv/data/apps/dev/webapp
• kv/data/apps/qa/webapp
• kv/data/apps/prod/webapp


### Tokens vault
There are two types of tokens: service tokens and batch tokens.

#### hvs. Service token
#### hvr. Recovery token
#### hvb. Batch token

```sh
vault token  lookup "TOKEN"
Key                 Value
---                 -----
accessor            cSDqyjD2I73mp1d1uq0OP9Ha
creation_time       1655243739
creation_ttl        0s
display_name        root
entity_id           n/a
expire_time         <nil>
explicit_max_ttl    0s
id                  "TOKEN"
meta                <nil>
num_uses            0
orphan              true
path                auth/token/root
policies            [root]
ttl                 0s
type                service
```
### Command options tokens

  -no-default-policy
      Detach the "default" policy from the policy set for this token. The
      default is false.

  -orphan
      Create the token with no parent. This prevents the token from being
      revoked when the token which created it expires. Setting this value
      requires root or sudo permissions. The default is false.

  -period=<duration>
      If specified, every renewal will use the given period. Periodic tokens
      do not expire (unless -explicit-max-ttl is also provided). Setting this
      value requires sudo permissions. This is specified as a numeric string
      with suffix like "30s" or "5m".

  -policy=<string>
      Name of a policy to associate with this token. This can be specified
      multiple times to attach multiple policies.

  -renewable
      Allow the token to be renewed up to it's maximum TTL. The default is
      true.

  -role=<string>
      Name of the role to create the token against. Specifying -role may
      override other arguments. The locally authenticated Vault token must
      have permission for "auth/token/create/<role>".

  -ttl=<duration>
      Initial TTL to associate with the token. Token renewals may be able to
      extend beyond this value, depending on the configured maximum TTLs. This
      is specified as a numeric string with suffix like "30s" or "5m".

  -type=<string>
      The type of token to create. Can be "service" or "batch". The default is
      service.

  -use-limit=<int>
      Number of times this token can be used. After the last use, the token
      is automatically revoked. By default, tokens can be used an unlimited
      number of times until their expiration.



### Token Time-To-Live, Periodic Tokens, and Explicit Max TTLs

Every non-root token has a time-to-live (TTL) associated with it, which is a current period of validity since either the token's creation time or last renewal time, whichever is more recent. (Root tokens may have a TTL associated, but the TTL may also be 0, indicating a token that never expires).

### Periodic Tokens
In some cases, having a token be revoked would be problematic -- for instance, if a long-running service needs to maintain its SQL connection pool over a long period of time. In this scenario, a periodic token can be used.

Ways to create periodic tokens

1. By having sudo capability or a root token with the auth/token/create endpoint
1. By using token store roles
1. By using an auth method that supports issuing these, such as AppRole

**A periodic token have TTL but does not have MAX_TTL**
Periodic tokens have a TTL, but no max TTL
• Periodic tokens may live for an infinite amount of time, so long as
they are renewed within their TTL

**This is useful for long-running services/applications that cannot handle regenerating a token**

Use case: I have a long-running app which cannot handle the
regeneration of a token or secret Periodic Service Token
**Create a periodic token:**
 ```sh
 vault token create -policy=training -period=24h
 ```
**Service token with use limits** 
When you want to limit the number of requests coming to Vault from a
particular token:
• Limit the token's number of uses in addition to TTL and Max TTL
• Use limit tokens expire at the end of their last use, regardless of their remaining
TTLs
• Use limit tokens expire at the end of their TTLs, regardless of remaining uses

Use case: I need a token that gets revoked automatically after
one use
```sh
vault token create -policy="training" -use-limit=2
````
**Orphan token**
• Orphan tokens are not children of their parent; therefore, do not expire when their parent does
• Orphan tokens still expire when their own Max TTL is reached

Service Token with Use Limit
Use case: My app can't use a token where its expiration is influenced by its parent Orphan Service Token

**Create an orphan token**
```sh
$ vault token create -policy="training" -orphan
```
#### Batch tokens vs Service tokens

| Description                         | Services tokens      | Batch tokens                |
| ----------------------------------- | -------------------- | ------------                |
| Can Be Root Tokens                  | Yes                  | No                          |
| Can Create Child Tokens	            | Yes                  | No                          |
| Can be Renewable	                  | Yes                  | No                          |
| Can be periodic 	                  | Yes                  | No                          |
| Can have explicit MAX TTL	          | Yes                  | No(always uses a fixed TTL) |
| Has Accessors		                    | Yes                  | No                          |
| Has Cubbyhole	  	                  | Yes                  | No                          |
| Revoked with Parent (if not orphan)	| Yes                  | Stops working               |
| Dynamic Secrets Lease Assignment		| Yes                  | Parent if not orphan        |
| Can be Used Across Performance Replication Clusters		                  | No                  | Yes(if orphan)                          |
| Creation Scales with Performance Standby Node Count		                  | No                  | Yes                          |
---
### Managing tokens in vault 
![alt text](./vault/1.png)
![alt text](./vault/2.png)
---
### Root tokens

Initial root token comes from Vault initialization
• Only method of authentication when first deploying Vault
• Used for initial configuration – such as auth methods or audit devices
• Once your new auth method is configured and tested, the root token
should be revoked

#### Revoke root token

```sh
vault token revoke s.dhtIk8VsE3Mj61PuGP3ZfFrg
```
#### Create a root token from an existing root token
![root token](./vault/3.png)
So we login into vault with a root token and we create a new root token.


#### Create a root token using unseal/recovery keys
![root token](./vault/4.png)

![root token](./vault/5.png)
![root token](./vault/6.png)
![root token](./vault/7.png)
```sh
vault operator generate-root -init
A One-Time-Password has been generated for you and is shown in the OTP field.
You will need this value to decode the resulting root token, so keep it safe.
Nonce         9c3ae56a-5387-0b9e-a3c6-fbe212357034
Started       true
Progress      0/3
Complete      false
OTP           8vX64UVnVzMo0qspyUuUtvrQ2Uw5
OTP Length    28
```
```sh
vault operator generate-root
Operation nonce: 9c3ae56a-5387-0b9e-a3c6-fbe212357034
Unseal Key (will be hidden): 
Nonce       9c3ae56a-5387-0b9e-a3c6-fbe212357034
Started     true
Progress    1/3
Complete    false
```
```sh
vault operator generate-root
Operation nonce: 9c3ae56a-5387-0b9e-a3c6-fbe212357034
Unseal Key (will be hidden): 
Nonce       9c3ae56a-5387-0b9e-a3c6-fbe212357034
Started     true
Progress    2/3
Complete    false
```
```sh
vault operator generate-root
Operation nonce: 9c3ae56a-5387-0b9e-a3c6-fbe212357034
Unseal Key (will be hidden): 
Nonce            9c3ae56a-5387-0b9e-a3c6-fbe212357034
Started          true
Progress         3/3
Complete         true
Encoded Token    UAArGAI6ZyAjTAE6XURBHh4jQAQiPTobQAYhXw
```
---
### Token Accessors
Token accessors can be used to perform limited actions
• Look up token properties
• Look up the capabilities of a token
• Renew the token
• Revoke the token
 
---
### Leases 
With every dynamic secret and service type authentication token, Vault creates a lease: metadata containing information such as a time duration, renewability, and more. Vault promises that the data will be valid for the given duration, or Time To Live (TTL). Once the lease is expired, Vault can automatically revoke the data, and the consumer of the secret can no longer be certain that it is valid.

---

### KV and KV2
The difference between them is 2 is version key value store, where version 1 is not.

So if you're using version two and you write a secret to version two, not only do you get data
we also store such a metadata associated with that secret.

Now, if you overwrite that secret again, what can do is just create version two and that version three and so on. 

And if you're not deleting old versions, you can actually refer to previous versions of that secret.

So KV2 gives us that functionality.

If you overwrite a secret and version one, it just gets overwritten.



### Secrets Engines

---
**KV** 
stores static secrets
#### Enabling kv version 1
```sh
vault enable secrets kv
```
![root token](./vault/8.png)

#### Enabling kv version 2
```sh
vault secrets enable -version=2 kv
```
![root token](./vault/9.png)
#### Putting information on kv version 2
```sh
vault kv put kv/data/efe nelly=123
== Secret Path ==
kv/data/data/efe

======= Metadata =======
Key                Value
---                -----
created_time       2022-06-25T02:07:05.567346645Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```
#### Getting information about a path
```sh
vault kv get kv/data/efe
== Secret Path ==
kv/data/data/efe

======= Metadata =======
Key                Value
---                -----
created_time       2022-06-25T02:07:05.567346645Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```
#### Rolling back a version
```sh
 vault kv rollback -version=1 kv/data/efe
Key                Value
---                -----
created_time       2022-06-25T02:12:12.438209296Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            3
```
### Kv version 2
```sh
Subcommands:
    delete               Deletes versions in the KV store
    destroy              Permanently removes one or more versions in the KV store
    enable-versioning    Turns on versioning for a KV store
    get                  Retrieves data from the KV store
    list                 List data or secrets
    metadata             Interact with Vault's Key-Value storage
    patch                Sets or updates data in the KV store without overwriting
    put                  Sets or updates data in the KV store
    rollback             Rolls back to a previous version of data
    undelete             Undeletes versions in the KV store
```

![root token](./vault/10.png)

```sh
$ vault secrets enable -version=2 kv
Success! Enabled the kv secrets engine at: kv/
``` 

#### Writing data on a certain path 
Writes the data to the given path in the key-value store. The data can be of any type.

      $ vault kv put -mount=secret foo bar=baz

  The deprecated path-like syntax can also be used, but this should be avoided 
  for KV v2, as the fact that it is not actually the full API path to 
  the secret (secret/data/foo) can cause confusion: 
  
      $ vault kv put secret/foo bar=baz

For example: 
Note: by the way all are equivalent
```sh
vault kv put -mount=secret foo bar=baz 
= Secret Path =
secret/data/foo

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T01:25:39.252648791Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

---
vault kv put secret/foo bar=baz 
= Secret Path =
secret/data/foo

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T01:26:01.481917119Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            2
```
**Getting data from a certain path**
  Retrieves the value from Vault's key-value store at the given key name. If no
  key exists with that name, an error is returned. If a key exists with that
  name but has no data, nothing is returned.

      $ vault kv get -mount=secret foo

  The deprecated path-like syntax can also be used, but this should be avoided 
  for KV v2, as the fact that it is not actually the full API path to 
  the secret (secret/data/foo) can cause confusion: 
  
      $ vault kv get secret/foo
Note: Both are equivalent ways to retrieve data from a certain path.
```sh
vault kv get -mount=secret foo   
= Secret Path =
secret/data/foo

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T01:26:01.481917119Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            2

=== Data ===
Key    Value
---    -----
bar    baz

vault kv get secret/foo                    
= Secret Path =
secret/data/foo

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T01:26:01.481917119Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            2

=== Data ===
Key    Value
---    -----
bar    baz

```
**Listing information in a certain path**
Lists data from Vault's key-value store at the given path.

  List values under the "my-app" folder of the key-value store:

      $ vault kv list secret/my-app/

```sh
vault kv list secret/  
Keys
----
foo
new-secret
second-secret
third-secret
```
**Deleting secrets at a certain path**
Deletes the data for the provided version and path in the key-value store. The versioned data will not be fully removed, but marked as deleted and will no longer be returned in normal get requests.

  To delete the latest version of the key "foo": 

      $ vault kv delete -mount=secret foo

  The deprecated path-like syntax can also be used, but this should be avoided  for KV v2, as the fact that it is not actually the full API path to 
  the secret (secret/data/foo) can cause confusion: 
  
      $ vault kv delete secret/foo

  To delete version 3 of key foo:

      $ vault kv delete -mount=secret -versions=3 foo

  To delete all versions and metadata, see the "vault kv metadata" subcommand.

For example: we delete the information that is stored to secret/foo path, as we can see below both are equivalent
```sh
$ vault kv delete  secret/foo   
Success! Data deleted (if it existed) at: secret/data/foo

$ vault kv delete -mount=secret foo 
Success! Data deleted (if it existed) at: secret/data/foo
```
We can inspect in the UI to be sure if does not exist , as we can see both version 1 and 2 are deleted. But this delete its just a soft delete, we can un-delete what we have done. 
![root token](./vault/15.png)

**Undelete**

Undeletes the data for the provided version and path in the key-value store.
  This restores the data, allowing it to be returned on get requests.

  To undelete version 3 of key "foo":
  
      $ vault kv undelete -mount=secret -versions=3 foo

  The deprecated path-like syntax can also be used, but this should be avoided, 
  as the fact that it is not actually the full API path to 
  the secret (secret/data/foo) can cause confusion: 

      $ vault kv undelete -versions=3 secret/foo
In this case we have already delete all the information and we assure this info going to UI and verified both versions are deleted.
![root token](./vault/16.png)
For example:
```sh
vault kv undelete -mount=secret -versions=2 foo
Success! Data written to: secret/undelete/foo
```
And we get only the second version 
![root token](./vault/17.png)


```sh
vault kv rollback -version=1 kv/app/db 
Key                Value
---                -----
created_time       2022-06-30T19:12:33.421798Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            3
```
![root token](./vault/11.png)
#### Getting data 2 different ways
##### default (table)
```sh
vault kv get  kv/app/db
= Secret Path =
kv/data/app/db

======= Metadata =======
Key                Value
---                -----
created_time       2022-06-30T19:12:33.421798Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            3

==== Data ====
Key     Value
---     -----
api     a8ee4b50cce124
pass    123
user    admin
```


##### Format json
Useful for creating machine-readable outputs
```sh
vault kv get -format=json kv/app/db 
{
  "request_id": "4c96c352-a546-e879-f60b-0b570295b43a",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "data": {
      "api": "a8ee4b50cce124",
      "pass": "123",
      "user": "admin"
    },
    "metadata": {
      "created_time": "2022-06-30T19:12:33.421798Z",
      "custom_metadata": null,
      "deletion_time": "",
      "destroyed": false,
      "version": 3
    }
  },
  "warnings": null
}
```


---
**AWS**
```sh
vault enable secrets aws
```



---
**Database**

```sh
vault enable secrets database
```

```sh
vault secrets list
```

```sh
vault write database/config/my-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(127.0.0.1:3306)/" \
    allowed_roles="my-role" \
    username="root" \
    password="Mozart123%%%%"
```

```sh
vault write database/roles/my-role \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: database/roles/my-role
```
```sh
vault read database/creds/my-role
Key                Value
---                -----
lease_id           database/creds/my-role/RtRIbPsoQ5rkKA2rxz78nsJb
lease_duration     1h
lease_renewable    true
password           5FeDLJH-AnAl7HRsa6ai
username           v-root-my-role-YLEtMiV0MKn4VlBED
```

**We log in**

```sh
 sudo mysql -u v-root-my-role-YLEtMiV0MKn4VlBED -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 5.7.38-0ubuntu0.18.04.1 (Ubuntu)

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```


```sh
vault secrets list --detailed
```
if map is empty means its kv version 1

### Transit secrets engine
The primary function of the transit secrets engine is decrypt/encrypt data.
Vault's transit secrets engine handles cryptographic functions on data-in-transit. Vault doesn't store the data sent to the secrets engine, so it can also be viewed as encryption as a service.
```sh
vault secrets enable transit
```
Create a named encryption key
```sh
vault write -f transit/keys/orders
```
Encrypt plaintext
```sh
vault write transit/encrypt/orders \
    plaintext=$(base64 <<< "4111 1111 1111 1111")
```
The returned ciphertext starts with vault:v1:. The first prefix (vault) identifies that it has been wrapped by Vault. The v1 indicates the key version 1 was used to encrypt the plaintext; therefore, when you rotate keys, Vault knows which version to use for decryption. The rest is a base64 concatenation of the initialization vector (IV) and ciphertext.

Decrypt cipher text
```sh
vault write transit/decrypt/orders \
    ciphertext="vault:v1:cZNHVx+sxdMErXRSuDa1q/pz49fXTn1PScKfhf+PIZPvy8xKfkytpwKcbC0fF2U="
```
The resulting data is base64-encoded and must be decoded to reveal the plaintext.

Example:
![root token](./vault/13.png)
```sh
base64 --decode <<< "NDExMSAxMTExIDExMTEgMTExMQo="
```
### Rotate the encryption key
```sh
vault write -f transit/keys/orders/rotate
``` 
### RabbitMQ
We run a container in docker 
```sh
docker run --rm --name some-rabbit -p 15672:15672 \       
    -e RABBITMQ_DEFAULT_USER=learn_vault \
    -e RABBITMQ_DEFAULT_PASS=hashicorp \
    rabbitmq:3-management
```

```sh
vault secrets enable rabbitmq             
```
```sh
export RABBITMQ_URL=http://127.0.0.1:15672
```
```sh
vault write rabbitmq/config/connection \                                                                                   2 ✘ 
    connection_uri="http://localhost:15672" \
    username="learn_vault" \
    password="hashicorp"
```
```sh
vault write rabbitmq/roles/my-role \                                                                                         ✔ 
    vhosts='{"/":{"write": ".*", "read": ".*"}}'
```
```sh
vault read rabbitmq/creds/my-role                                                                                        127 ✘ 
Key                Value
---                -----
lease_id           rabbitmq/creds/my-role/9NPnQuvOEU9qJkn6HWlkNPsJ
lease_duration     768h
lease_renewable    true
password           9s6DNihshKWS5ShSk679kedDgbNFiW2TngV1
username           root-ad511cff-1375-ea33-f081-20c8213af914
```


---
### Vault Agent

![root token](./vault/12.png)
For some Vault deployments, making (and maintaining) these changes to applications may not be a problem, and may actually be preferred. This may be applied to scenarios where you have a small number of applications or you want to keep strict, customized control over how each application interacts with Vault. However, in other situations where you have a large number of applications, as in large enterprises, you may not have the resources or expertise to update and maintain the Vault integration code for every application. When third party applications are being deployed by the application, it is prohibited to add the Vault integration code.

Vault Agent aims to remove this initial hurdle to adopt Vault by providing a more scalable and simpler way for applications to integrate with Vault.

### Code to create a database in postgresql
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  type: ClusterIP
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    app: postgres

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      service: postgres
      app: postgres
  template:
    metadata:
      labels:
        service: postgres
        app: postgres
    spec:
      containers:
        - name: postgres
          image: hashicorpdemoapp/postgres:11.6
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_DB
              value: wizard
            - name: POSTGRES_USER
              value: postgres
            - name: POSTGRES_PASSWORD
              value: password
          volumeMounts:
            - mountPath: "/var/lib/postgresql/data"
              name: "pgdata"
      volumes:
        - name: pgdata
          emptyDir: {}
```

### Web policy 
```sh
path "database/creds/db-app" {
  capabilities = ["read"]
}
path "totp/keys/my-user"{
  capabilities = ["create", "read", "update", "delete","patch", "list"]
}
```
### Code to get a web deployment with database credentials, and TOTP verification.
```yaml
---
# Source: vault/templates/server-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: web
  namespace: default
  labels:
    app.kubernetes.io/name: web
    app.kubernetes.io/instance: web
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-db-creds: database/creds/db-app
        vault.hashicorp.com/agent-inject-serect-totp: totp/keys/my-user
        #vault.hashicorp.com/agent-inject-secret-transform: transform/decode/mobile-pay
        vault.hashicorp.com/agent-inject-template-db-creds: |
           <html>
           <body>
           <h1>Some secrets:</h1>
           {{- with secret "database/creds/db-app" }}
           <ul
           <h1>Database creds path at database/creds/db-app</h1>
           <li><pre>username: {{ .Data.username }}</pre></li>
           <li><pre>password: {{ .Data.password }}</pre></li>
           </ul>
           {{- end }}
           <h1>QR code generate by TOTP  path at totp/keys/my-user</h1>
           {{- with secret "totp/keys/my-user" "generate=true" "issuer=Vault" "account_name=user@test.com" }}
              <img src="data:image/png;base64, {{ .Data.barcode }}" alt="Red dot" />
           </body>
           </html>
           {{- end }}
         #  <h1>Decode a card</h1>
          # {{- with secret "transform/decode/mobile-pay" "transformation=credit-card" "value=eRwUjS2L9dkhdhWQ4LC88BAtkQAh9HRCFEgVsigECdECh88sZjJsSLG3YMLnfvJX45Dv1tR2A" }}
           #    {{ .Data.value }}"
           #</body>
           #</html>
           #{{- end }}
        vault.hashicorp.com/role: web
    spec:
      serviceAccountName: web
      containers:
        - image: nellie123her/nginx
          name: nginx-container
          ports:
            - containerPort: 80
```
```sh
kubectl exec -it $(kubectl get pods --selector "app=postgres" -o jsonpath="{.items[0].metadata.name}") -c postgres -- bash -c 'PGPASSWORD=gTUsL-WoC6jrpPN26qmK psql -U v-root-db-app-qnvUYVf8sm10AA86a8yJ-1657037958 -d wizard'
```
## Auth methods 
### LDAP
Auth methods must be configured in advance before users or machines can authenticate. These steps are usually completed by an operator or configuration management tool.

```sh
vault auth enable ldap
```   




### Sentinel policies

#### Delete if exist
```sh
******
vault delete sys/policies/egp/banned-words
vault delete sys/policies/egp/bussiness-hours
vault delete sys/policies/egp/max-kv-size
vault delete sys/policies/egp/password-check
vault delete sys/policies/egp/validate-delete-version
*****
```
### Apply sentinel policies
```sh

POLICY=$(base64 policies/banned-words.sentinel)
vault write sys/policies/egp/banned-words \
        policy="${POLICY}" \
        paths="kv/*" \
        enforcement_level="hard-mandatory"
vault read sys/policies/egp/banned-words
---------
POLICY=$(base64 policies/bussiness-hours.sentinel)
vault write sys/policies/egp/bussiness-hours \
        policy="${POLICY}" \
        paths="kv/*" \
        enforcement_level="hard-mandatory"
---------
POLICY=$(base64 policies/max-kv-size.sentinel)
vault write sys/policies/egp/max-kv-size \
        policy="${POLICY}" \
        paths="kv/*" \
        enforcement_level="soft-mandatory"
---------
POLICY=$(base64 policies/password-check.sentinel)
vault write sys/policies/egp/password-check \
        policy="${POLICY}" \
        paths="/auth/userpass/users/*" \
        enforcement_level="hard-mandatory"
----------
POLICY=$(base64 policies/validate-delete-version.sentinel)
vault write sys/policies/egp/validate-delete-version \
        policy="${POLICY}" \
        paths="kv/metadata/*" \
        enforcement_level="advisory"
---------
```
#### Testing sentinel policies

```sh
#Enabling kv version2
vault secrets enable -version=2 kv

#Creating new data
vault kv put kv/frontend pass=magia

#Creating a policy to permit a user or client create information at that path for example: secrets/foo
vault policy write kv-standard /policies/kv-standard.hcl
#Creating a new user to test our policies
vault write auth/userpass/users/nelly \
    password=123 \
    policies=kv-standard
#login with new user or client 
vault login -method=userpass \
    username=nelly \
    password=123
```


---
### Policies
```sh
# This section grants all access on "secret/*". Further restrictions can be
# applied to this broad policy, as shown below.
path "secret/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

# Even though we allowed secret/*, this line explicitly denies
# secret/super-secret. This takes precedence.
path "secret/super-secret" {
  capabilities = ["deny"]
}

# Policies can also specify allowed, disallowed, and required parameters. Here
# the key "secret/restricted" can only contain "foo" (any value) and "bar" (one
# of "zip" or "zap").
path "secret/restricted" {
  capabilities = ["create"]
  allowed_parameters = {
    "foo" = []
    "bar" = ["zip", "zap"]
  }
}
```
```sh
# This allows the user to update the userpass auth method's user
# configurations (e.g., "password") but cannot update the "token_policies"
# parameter value.
path "auth/userpass/users/*" {
  capabilities = ["update"]
  denied_parameters = {
    "token_policies" = []
  }
}
```
**Creating Policies**
```sh
vault policy write policy-name policy-file.hcl
```
**Creating tokens with policies**
```sh
vault token create -policy=dev-readonly -policy=logs
```

We create a policy called test with this information
```sh
path "kv/*" {
  capabilities = ["create","delete","list"]
}

path "secret/*"{
   capabilities = ["read","list","update"]
}
```
Basically this policy allows a user to create new data on kv path and update existing data at secret/ path 


with token root we anable kv v2 
```sh
vault secrets enable -path=secret -version=2 kv
```
and create some data just as below.
```sh
vault kv put secret/second-secret user=admin01
====== Secret Path ======
secret/data/second-secret

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-27T20:49:14.755457672Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```

finally we create a user  to test our ACL policies
```sh

#Creating a policy to permit a user or client create information at that path for example: secrets/foo
vault policy write kv-standard /policies/kv-standard.hcl
#Creating a new user to test our policies
vault write auth/userpass/users/nelly \
    password=123 \
    policies=kv-standard
```
we log into
```sh
#login with new user or client 
vault login -method=userpass \
    username=nelly \
    password=123
```

we can create a new version based on an existing path
```sh
vault kv put secret/second-secret user=admin04  
====== Secret Path ======
secret/data/second-secret

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T00:48:20.375386006Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            4
```
PUT command it's like an update, meanwhile it create a "path" for example:

```sh
 vault kv put secret/new-secret user=nelly password=mozart123                                                                 ✔ 
Error writing data to secret/data/new-secret: Error making API request.

URL: PUT http://0.0.0.0:8200/v1/secret/data/new-secret
Code: 403. Errors:

* 1 error occurred:
	* permission denied
```
So we cannot create a new info cuz our policies is not allowed.

if we update our police just as below. we added create capability 
```sh
path "secret/*"{
   capabilities = ["read","list","update","create"]
}
```

Execute the same command, so we will see we can create this new data
```sh
vault kv put secret/new-secret user=nelly password=mozart123
===== Secret Path =====
secret/data/new-secret

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T01:08:04.701374877Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```

GET it's the equivalent to read for example, we want to read what contains this path secret/new-secret
we execute this command **kv get**
```sh
vault kv get secret/new-secret  
===== Secret Path =====
secret/data/new-secret

======= Metadata =======
Key                Value
---                -----
created_time       2022-07-28T01:08:04.701374877Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
password    mozart123
user        nelly
```

If we want to list what contains certain path we use **kv list** in this case just as secret because in this are mounted our secrets we already put it on

```sh
vault kv list  secret/   
Keys
----
new-secret
second-secret
third-secret
```
**Delete secrets**


**kv delete**



### Replication performance
Vault supports two different types of replication, performance and disaster recovery (DR). Performance clusters create and maintain their own tokens. These tokens are NOT replicated to other clusters. DR clusters are essentially a warm-standby and do replicate tokens from the primary cluster.


### Disaster Recovery vs Performance Replication
|  Capability | Disaster recovery  |  Performance Replication |
|-------------|--------------------|--------------------------|
|  Mirrors the configuration of a primary cluster	 |   |   |
|  Mirrors the configuration of a primary cluster’s backends (i.e., auth methods, secrets engines, audit devices, etc.)	 |   |   |
|  Mirrors the tokens and leases for applications and users interacting with the primary cluster	 |   |   |
---
### Leases 
#### What is a lease?
Answer: With every dynamic secret and service type authentication token, Vault creates a lease: metadata containing information such as a time duration, renewability, and more. 
Revocation can happen manually via the API, via the vault lease revoke cli command, the user interface (UI) under the Access tab, or automatically by Vault.
When a lease is expired, Vault will automatically revoke that lease. When a token is revoked, Vault will revoke all leases that were created using that token.

When reading a dynamic secret, such as via vault read, Vault always returns a lease_id. This is the ID used with commands such as vault lease renew and vault lease revoke to manage the lease of the secret.

Usage
The following flags are available in addition to the standard set of flags included on all commands.

-force (bool: false) - Delete the lease from Vault even if the secret engine revocation fails. This is meant for recovery situations where the secret in the target secrets engine was manually removed. If this flag is specified, -prefix is also required. This is aliased as "-f". The default is false.

-prefix (bool: false) - Treat the ID as a prefix instead of an exact lease ID. This can revoke multiple leases simultaneously. The default is false.

-sync (bool: false) - Make the operation synchronous instead of queuing the revocations to be done in the background.



 Revokes secrets by their lease ID. This command can revoke a single secret
  or multiple secrets based on a path-matched prefix.

  The default behavior when not using -force is to revoke asynchronously; Vault
  will queue the revocation and keep trying if it fails (including across
  restarts). The -sync flag can be used to force a synchronous operation, but
  it is then up to the caller to retry on failure. Force mode always operates
  synchronously.

  Revoke a single lease:

      $ vault lease revoke database/creds/readonly/2f6a614c...

  Revoke all leases for a role:

      $ vault lease revoke -prefix aws/creds/deploy

  Force delete leases from Vault even if secret engine revocation fails:

      $ vault lease revoke -force -prefix consul/creds
