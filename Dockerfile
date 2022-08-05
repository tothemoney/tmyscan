FROM elixir:latest

## Update & Install other dependancies
RUN apt-get update && \
    apt-get install wget curl automake autoconf python3 \
    file libtool inotify-tools gcc libgmp-dev make \
    g++ build-essential -y

## Install NodeJS & npm
RUN apt-get install nodejs npm -y

## Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

EXPOSE 4000

## Set default env
ENV MIX_ENV="prod" \
    SECRET_KEY_BASE="RMgI4C1HSkxsEjdhtGMfwAHfyT6CKWXOgzCboJflfSm4jeAlic52io05KB6mqzc5"

## Build blockscout

## Clone Blockscout
## git clone -b build-1 https://github.com/artemstrelnik/blockscout.git
RUN git clone https://github.com/alena/blockscout-1.git

WORKDIR /blockscout-1

## Compile
RUN mix local.hex --force && \ 
    mix do deps.get, local.rebar --force, deps.compile

RUN mix compile

## Install npm dependancies and compile frontend assets​
RUN cd apps/block_scout_web/assets/ && \
    npm install && \
    npm run deploy

RUN cd apps/explorer/ && \
    npm install

## Build static assets​
RUN mix phx.digest