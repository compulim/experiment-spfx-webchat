FROM node:16
EXPOSE 54321 35729

RUN npm install --location=global gulp@4 yo @microsoft/generator-sharepoint@1.15.0

RUN useradd --create-home --shell /bin/bash spfx && \
    usermod -aG sudo spfx && \
    mkdir -p /usr/app/spfx/ && \
    chown -R spfx:spfx /usr/app && \
    cd /usr/app/spfx
USER spfx

WORKDIR /usr/app/
RUN yo @microsoft/sharepoint --no-insight --skip-install --component-type webpart --component-name WebChat --framework react --solution-name spfx

WORKDIR /usr/app/spfx/
RUN npm install --save-dev concurrently http-proxy-middleware selfsigned
RUN gulp trust-dev-cert
ADD src/proxy.js /usr/app/spfx/proxy.js

ENTRYPOINT npx concurrently "node proxy" "gulp serve --nobrowser"
