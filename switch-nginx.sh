#!/bin/bash

if [ "$1" = "dev" ]; then
  cp g-scores-fe/nginx/default.conf g-scores-fe/nginx/default.conf.bak
  cp g-scores-fe/nginx/default.conf g-scores-fe/nginx/default.conf
  echo "Switched to development nginx configuration"
elif [ "$1" = "prod" ]; then
  cp g-scores-fe/nginx/default.conf.production g-scores-fe/nginx/default.conf
  echo "Switched to production nginx configuration"
else
  echo "Usage: ./switch-nginx.sh [dev|prod]"
  exit 1
fi 