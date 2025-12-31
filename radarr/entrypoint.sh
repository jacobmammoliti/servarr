#!/bin/sh
set -e

# Get desired UID/GID from environment variables
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Update the radarr user's UID/GID if they differ from defaults
if [ "$PUID" != "1000" ] || [ "$PGID" != "1000" ]; then
    echo "Updating radarr user to UID=$PUID, GID=$PGID"
    
    # Modify group first
    sed -i "s/^radarr:x:1000:/radarr:x:$PGID:/" /etc/group
    
    # Modify user
    sed -i "s/^radarr:x:1000:1000:/radarr:x:$PUID:$PGID:/" /etc/passwd
    
    # Update ownership of existing files
    chown -R $PUID:$PGID /config /radarr
fi

# Switch to radarr user and execute the application
exec su-exec radarr "$@"