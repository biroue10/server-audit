#!/bin/bash
# ============================================
# SERVER AUDIT SCRIPT
# Author: Biroue Isaac
# Description: Audits a RHEL server and reports
# ============================================

DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)
REPORT="/tmp/audit-report.txt"

print_section() {
    echo ""
    echo "============================="
    echo "  $1"
    echo "============================="
}

# --- Check disk space ---
check_disk() {
    print_section "DISK SPACE"
    df -h | grep -v tmpfs
    echo ""

    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "WARNING: Disk usage is at ${DISK_USAGE}% - Action required!"
    else
        echo "OK: Disk usage is at ${DISK_USAGE}%"
    fi
}

# --- Check services ---
check_services() {
    print_section "SERVICES STATUS"
    SERVICES=("nginx" "mariadb" "sshd" "firewalld")

    for SERVICE in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$SERVICE"; then
            echo "OK:      $SERVICE is running"
        else
            echo "WARNING: $SERVICE is NOT running"
        fi
    done
}

# --- Check failed SSH logins ---
check_ssh_failures() {
    print_section "FAILED SSH LOGINS (last 24h)"
    FAILED=$(journalctl -u sshd --since "24 hours ago" | grep "Failed password" | wc -l)
    echo "Failed login attempts: $FAILED"
    echo ""
    journalctl -u sshd --since "24 hours ago" | grep "Failed password" | tail -5
}



# --- Check sudo users ---
check_sudo_users() {
    print_section "USERS WITH SUDO ACCESS"
    echo "Members of wheel group (sudo):"
    getent group wheel | cut -d: -f4
    echo ""
    echo "Sudoers file entries:"
    grep -v "^#" /etc/sudoers | grep -v "^$"
}

# --- Check open ports ---
check_open_ports() {
    print_section "OPEN PORTS"
    ss -tlnp | grep LISTEN
}




# --- Main ---
main() {
    echo "=============================" > "$REPORT"
    echo "  SERVER AUDIT REPORT"       >> "$REPORT"
    echo "  Date    : $DATE"           >> "$REPORT"
    echo "  Server  : $HOSTNAME"       >> "$REPORT"
    echo "=============================" >> "$REPORT"

    check_disk        >> "$REPORT" 2>&1
    check_services    >> "$REPORT" 2>&1
    check_ssh_failures >> "$REPORT" 2>&1
    check_sudo_users  >> "$REPORT" 2>&1
    check_open_ports  >> "$REPORT" 2>&1

    echo ""
    echo "Audit complete. Report saved to: $REPORT"
    cat "$REPORT"
}

main
