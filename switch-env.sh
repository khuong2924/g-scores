#!/bin/bash

if [ "$1" = "dev" ]; then
    export NODE_ENV=development
    export RAILS_ENV=development
    export API_URL=http://localhost:3000
    export WS_URL=ws://localhost:3000/cable
    export ALLOWED_ORIGINS=http://localhost,http://localhost:80
    export CABLE_ALLOWED_REQUEST_ORIGINS=http://localhost,http://localhost:80
    export CABLE_URL=ws://localhost:3000/cable
    echo "Switched to development environment"
elif [ "$1" = "prod" ]; then
    export NODE_ENV=production
    export RAILS_ENV=production
    export API_URL=https://truongvinhkhuong.io.vn
    export WS_URL=wss://truongvinhkhuong.io.vn/cable
    export ALLOWED_ORIGINS=https://truongvinhkhuong.io.vn,http://truongvinhkhuong.io.vn
    export CABLE_ALLOWED_REQUEST_ORIGINS=https://truongvinhkhuong.io.vn,http://truongvinhkhuong.io.vn
    export CABLE_URL=wss://truongvinhkhuong.io.vn/cable
    export SSL_CERTS_PATH=./certs
    echo "Switched to production environment"
else
    echo "Usage: ./switch-env.sh [dev|prod]"
    exit 1
fi 