#!/bin/bash

# Start script
echo "Launch off script"

# Start LocalTunnel
lt --port 9000 --subdomain laravel-opendata & lt --port 3000 --subdomain app-opendata
echo "Started LocalTunnel for port 9000 & 3000"
