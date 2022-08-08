FROM node:16
EXPOSE 54321 35729

RUN npm install --location=global gulp@4 yo @microsoft/generator-sharepoint@1.15.0

RUN useradd --create-home --shell /bin/bash spfx && \
    usermod -aG sudo spfx && \
    mkdir -p /usr/app/spfx/ && \
    chown -R spfx:spfx /usr/app && \
    cd /usr/app/spfx
USER spfx

RUN mkdir -p /usr/app/spfx/

WORKDIR /usr/app/
RUN yo @microsoft/sharepoint --no-insight --skip-install --component-type webpart --component-name WebChat --framework react --solution-name spfx

WORKDIR /usr/app/spfx/
RUN npm install --save-dev concurrently http-proxy-middleware selfsigned
RUN gulp trust-dev-cert
ADD src/proxy.js /usr/app/spfx/proxy.js

# Due to some problems in esbuild@0.12.15, either;
# 1. It has to be installed before botframework-webchat, or;
# 2. Install botframework-webchat, it will fail, then install again will succeed
RUN npm install esbuild@0.12.15

RUN npm install botframework-webchat

ADD --chown=spfx:spfx src/spfx/src/webparts/webChat /usr/app/spfx/src/webparts/webChat

RUN npm run build

# To run without development server (faster), use "npx serve".
ENTRYPOINT npx concurrently "node proxy" "npx serve -p 4321"

# To run with Webpack development server, use "gulp serve".
# ENTRYPOINT npx concurrently "node proxy" "gulp serve --nobrowser"
