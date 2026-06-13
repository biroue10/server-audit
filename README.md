# server-audit

A Bash script that audits a RHEL/Linux server and generates a structured health report. Built as part of my [syseng-journey](https://github.com/biroue10/syseng-journey) — a hands-on path from Service Desk to Junior Systems Administrator.

---

## What It Does

Runs five checks and writes a full report to `/tmp/audit-report.txt`:

| Check | What it detects |
|-------|----------------|
| Disk space | Usage per partition — warns if root > 80% |
| Services | nginx, mariadb, sshd, firewalld — running or not |
| SSH failures | Failed login attempts in the last 24 hours |
| Sudo access | Users in wheel group + active sudoers entries |
| Open ports | All TCP ports in LISTEN state with process name |

---

## Usage

```bash
git clone https://github.com/biroue10/server-audit.git
cd server-audit
chmod +x audit.sh
sudo ./audit.sh
```

> `sudo` is required for journalctl and /etc/sudoers access.

---

## Sample Output

```
=============================
  SERVER AUDIT REPORT
  Date    : 2026-06-13 04:46:35
  Server  : localhost.localdomain
=============================

=============================
  DISK SPACE
=============================
Filesystem              Size  Used  Avail  Use%  Mounted on
/dev/mapper/rhel-root    70G  6.0G   64G    9%   /
/dev/sda2               960M  355M  606M   37%   /boot

OK: Disk usage is at 9%

=============================
  SERVICES STATUS
=============================
OK:      nginx is running
OK:      mariadb is running
OK:      sshd is running
OK:      firewalld is running

=============================
  FAILED SSH LOGINS (last 24h)
=============================
Failed login attempts: 0

=============================
  USERS WITH SUDO ACCESS
=============================
Members of wheel group (sudo):
biroue

=============================
  OPEN PORTS
=============================
LISTEN  0.0.0.0:22    sshd
LISTEN  0.0.0.0:3306  mariadbd
LISTEN  [::]:80       nginx
LISTEN  *:9090        prometheus
LISTEN  *:3000        grafana
```

---

## Real Finding

Running the script revealed that MariaDB was listening on `0.0.0.0:3306` — all interfaces — instead of `127.0.0.1` only. A database should never be publicly accessible. This is exactly the kind of misconfiguration a regular audit catches before an attacker does.

---

## Bash Concepts Covered

- Variables and command substitution `$(...)`
- Functions — reusable blocks of code
- Arrays and for loops — iterate over services
- Conditionals — alert when thresholds are exceeded
- Pipes `|` — chain commands together
- Redirection `>` and `>>` — write report to file
- `awk`, `cut`, `grep`, `wc` — parse and extract data
- `2>&1` — redirect errors into the report

---

## Roadmap

- [ ] CPU and RAM usage checks
- [ ] Email alert when WARNING is detected
- [ ] Cron scheduling — run automatically every morning
- [ ] HTML report output

---

## Part of

[biroue10/syseng-journey](https://github.com/biroue10/syseng-journey) — documenting my path from Service Desk Analyst to Junior Systems Administrator.

Blog post: [Server Audit Script](https://biroue10.github.io/posts/server-audit-script/)
