#!/bin/sh
set -e

# Get desired UID/GID from environment variables
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Update the sonarr user's UID/GID if they differ from defaults
if [ "$PUID" != "1000" ] || [ "$PGID" != "1000" ]; then
    echo "Updating sonarr user to UID=$PUID, GID=$PGID"
    
    # Modify group first
    sed -i "s/^sonarr:x:1000:/sonarr:x:$PGID:/" /etc/group
    
    # Modify user
    sed -i "s/^sonarr:x:1000:1000:/sonarr:x:$PUID:$PGID:/" /etc/passwd
    
    # Update ownership of existing files
    chown -R $PUID:$PGID /config /sonarr
fi

# Switch to sonarr user and execute the application
exec su-exec sonarr "$@"