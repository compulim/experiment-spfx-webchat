# experiment-spfx-webchat

Under Docker, host Web Chat and other Web Parts or React components in SharePoint Framework (SPFx).

# Prerequisites

1. Create your Microsoft 365 tenant with SharePoint
1. [Install Docker on WSL2](https://aka.ms/wsl2)

# How to use

1. `npm run build` - to build the Docker image
1. `npm start` - to run the Docker container
1. Browse to https://localhost:4321/ - to trust the self-signed certificate
   - When presented with a page saying "Your connection isn't private (NET::ERR_CERT_AUTHORITY_INVALID)"
   - On your keyboard, type `thisisunsafe`
1. Browse to https://&lt;your-sharepoint&gt;.sharepoint.com/sites/&lt;your-site&gt;/_layouts/15/workbench.aspx
1. Add the component "Web Chat" to the workbench

# How to develop

For development, it is recommended to use [Visual Studio Code Remote - Containers extension]([url](https://code.visualstudio.com/docs/remote/containers)) to connect to the Docker image directly:

1. Make sure the Docker container is running
1. Open Visual Studio Code
1. [Install the "Remote - Containers" extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
1. Open Command Palette (<kbd>F1</kbd>)
1. Type "Remote-Containers: Attach to Running Container..."

# Screenshots

![image](https://user-images.githubusercontent.com/1622400/183159352-e8bf4952-7d3e-4e1f-b81f-5b2c8f05caab.png)

![image](https://user-images.githubusercontent.com/1622400/183159262-fafe1bd1-1f38-4da6-8918-96f62fd03dcd.png)

# Obstacles

When we worked on this repo, we hit a few obstacles. We are documenting them here so when we need to improve our repo at a latter time, we know why we did something.

## Majors

### SharePoint site always load https://localhost:4321/, with a self-signed certificate

Trusting a self-signed certificate generated dynamically in Docker is not trivial as the certificate change on every build. The host machine need to export the PEM and re-trust it on every build is a hassle.

Few attempts:

- Modifying the URL via ?debugManifestsFile=http://localhost:4321/temp/manifests.js does not work
- The code in workbench did try to load via https://, then fallback to http://
   - However, their fallback code did not work and it fail at first attempt
   - Thus, it never try to load via http://

At the end, we used the `thisisunsafe` and temporarily trusting the certificate in the browser.

### `gulp serve` server only listens to localhost but not 0.0.0.0

We tried to modify `config/serve.json/hostname` to listen to 0.0.0.0, however, the generated manifest will also point resources to https://0.0.0.0:4321/, which is bad.

Instead, we wrote [a proxy](src/proxy.js) to expose https://localhost:4321 as https://0.0.0.0:54321 (with another [self-signed](https://npmjs.com/package/selfsigned) certificate).

## Minors

- Creating a new Microsoft 365 account takes hours
   - When creating a Microsoft account, it don't prompt for first and last name. However, Microsoft 365 requires first and last name
      - Microsoft 365 said "We're missing some information. Please add your first and last name to your Microsoft Account at https://account.microsoft.com/profile and try again later. It might take a few hours for the change to appear in the system."
   - In our experience, it took 1-2 hours before we can successfully create a tenant
- Yeoman does not like to run as root
   - We have to `useradd spfx`
- `npm install` for SPFx dependencies takes 4 minutes to complete
   - Early development of the `Dockerfile` takes a lot of time
- No live reload functionality although the `gulp serve` hosted one
   - Tried to trust the certificate on https://localhost:35729
