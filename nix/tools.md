# Nix Tools
## Deploy-rs
- _profile_: define some data to deploy and the user to use to deploy this data
  on the target machine. Usualy a `system` configuration is created with a
  nixosConfiguration for the data and `root` for the user.
  It is possible to define multiple profiles for a machine which will be deployed
  independently of each other.
- _node_: define a machine to deploy on. Must be reachable passwordless with ssh.
- _magic rollback_: after a deployment, if the machine is not reachable after
  some time (30 seconds by default), the deployment is rolled back to its previous
  state.
