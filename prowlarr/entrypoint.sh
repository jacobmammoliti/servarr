#!/bin/sh
set -e

# Get desired UID/GID from environment variables
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Update the prowlarr user's UID/GID if they differ from defaults
if [ "$PUID" != "1000" ] || [ "$PGID" != "1000" ]; then
    echo "Updating prowlarr user to UID=$PUID, GID=$PGID"
    
    # Modify group first
    sed -i "s/^prowlarr:x:1000:/prowlarr:x:$PGID:/" /etc/group
    
    # Modify user
    sed -i "s/^prowlarr:x:1000:1000:/prowlarr:x:$PUID:$PGID:/" /etc/passwd
    
    # Update ownership of existing files
    chown -R $PUID:$PGID /config /prowlarr
fi

# Switch to prowlarr user and execute the application
exec su-exec prowlarr "$@"