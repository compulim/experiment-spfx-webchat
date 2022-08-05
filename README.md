# experiment-spfx-webchat

Hosting Web Chat in SharePoint Framework (SPFx) in Docker.

# Prerequisites

1. Create your SharePoint tenant
1. Install Docker on WSL2

# How to use

1. `npm run build` - to build the Docker container
1. `npm start` - to run the Docker image
1. Browse to https://localhost:4321/ - to trust the self-signed certificate
   - When presented with a page saying "Your connection isn't private (NET::ERR_CERT_AUTHORITY_INVALID)"
   - On your keyboard, type `thisisunsafe`
1. Browse to https://<your-sharepoint>.sharepoint.com/sites/<your-site>/_layouts/15/workbench.aspx
1. Add the component "Web Chat" to the workbench

For development, it is recommended to use VS Code with Remote Containers extension to connect to the Docker image directly.

# Screenshots

![image](https://user-images.githubusercontent.com/1622400/183159245-2faa7d50-5cab-4e34-8c85-a6c0b101e708.png)

![image](https://user-images.githubusercontent.com/1622400/183159262-fafe1bd1-1f38-4da6-8918-96f62fd03dcd.png)

# Obstacles

When we worked on this repo, we hit a few obstacles. We are documenting them here so when we need to improve our repo at a latter time, we know why we did something.

## Majors

### SharePoint site always load https://localhost:4321/, with a self-signed certificate

Trusting a self-signed certificate generated dynamically in Docker is not trivial as the certificate change on every build. The host machine need to export the PEM and re-trust it on every build is a hassle.

Using `thisisunsafe` will trust the certificate temporarily in the browser.

### `gulp serve` server only listens to localhost but not 0.0.0.0

We tried to modify `config/serve.json/hostname` to listen to 0.0.0.0, however, the generated manifest will also point resources to https://0.0.0.0:4321/, which is bad.

Instead, we wrote a proxy to expose https://localhost:4321 as https://0.0.0.0:54321 (with another self-signed certificate).

## Minors

- Creating a new Microsoft 365 account takes hours
   - When creating a Microsoft account, it don't prompt for first name and last name. However, Microsoft 365 requires that.
   - Adding first name and last name to a Microsoft account takes 1-2 hours to propagate to Micrsoft 365.
- Yeoman does not like to run as root
- `npm install` takes 4 minutes to complete
   - Early development of the `Dockerfile` takes a lot of time
- No live reload functionality although the `gulp serve` hosted one
