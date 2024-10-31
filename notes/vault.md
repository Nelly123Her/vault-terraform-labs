
## Vault Installation on Mac OS

Install the HashiCorp tap, a repository of all HashiCorp Homebrew packages:

```sh
brew tap hashicorp/tap
```

Then, install Vault:

```sh
brew install hashicorp/tap/vault
```

For installation instructions on **Windows** and **Linux**, visit the official documentation:

**[Windows, Linux Installation](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-install)**

---

### Deploy Vault

1. **Create a Vault directory:**

```sh
mkdir Vault
cd Vault
```

2. **Create a configuration file (`config.hcl`):**

```hcl
storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

disable_mlock = true

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true
```

### Start the Server

The `./vault/data` directory that the Raft storage backend uses must exist, so create it before starting Vault:

```sh
mkdir -p ./vault/data
```

Start the Vault server with the configuration file:

```sh
vault server -config=config.hcl
```

### Initialize Vault

Initialization is the process of configuring Vault for the first time. This is required when starting with a new storage backend. The command below will initialize Vault and generate the unseal keys and the initial root token.

Set the Vault address environment variable:

```sh
export VAULT_ADDR='http://127.0.0.1:8200'
```

Run the initialization command:

```sh
vault operator init
```

**Example output:**

```sh
Unseal Key 1: 4jYbl2CBIv6SpkKj6Hos9iD32k5RfGkLzlosrrq/JgOm
Unseal Key 2: B05G1DRtfYckFV5BbdBvXq0wkK5HFqB9g2jcDmNfTQiS
Unseal Key 3: Arig0N9rN9ezkTRo7qTB7gsIZDaonOcc53EHo83F5chA
Unseal Key 4: 0cZE0C/gEk3YHaKjIWxhyyfs8REhqkRW/CSXTnmTilv+
Unseal Key 5: fYhZOseRgzxmJCmIqUdxEm9C3jB5Q27AowER9w4FC2Ck

Initial Root Token: s.KkNJYWF5g0pomcCLEmDdOVCW
```

### Seal/Unseal

Every initialized Vault server starts in a sealed state. Vault can access the physical storage but cannot read it until the data is decrypted. This process is called unsealing.

#### Why Vault Seals Itself:

- To protect data when Vault is restarted, such as after a system reboot or manual restart.
- To ensure that sensitive information is protected in case the server is compromised.

#### Unsealing the Vault:

```sh
vault operator unseal
```

**Example output:**

```sh
Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       d3d06528-aafd-c63d-a93c-e63ddb34b2a9
Version            1.7.0
Storage Type       raft
HA Enabled         true
```

When you initialize Vault, it generates a master key, which is divided into several pieces (key shares) and distributed to key holders. You need a certain number of these shares to unseal Vault and access its data.

---

### Removing Vault

To stop and remove Vault, run the following commands:

```sh
pgrep -f vault | xargs kill
rm -r ./vault/data
```



Vault secrets

KV version 1
```sh
vault secrets enable kv
```

KV version 2
```sh
vault secrets enable kv-v2
```