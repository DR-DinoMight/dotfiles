#!/bin/bash
# Add Touch ID line to beginning of sudo file.
sed -i '' '2i\
auth       sufficient     pam_tid.so\
' /etc/pam.d/sudo
