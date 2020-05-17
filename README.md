# Compendium Compose

Docker compose project for deploying the Compendium project.

## Deploying

1. Log into the Droplet `ssh root@167.172.234.65`. Ensure the firewall rules are ok first!
2. Clone this project onto the server.
3. Generate a GitLab Personal Access token on your GitLab account with "read_registry" permissions.
4. Copy the token in to a file called 'token.txt', in this project's folder.
5. Run `./setup.sh`
6. `sudo chmod o+x ./setup.sh`
