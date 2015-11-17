rc.sshd:merge {
  type = "longrun",
  producer_for = "sshd-log",
  run = realign [[
    #!/bin/execlineb -P
    fdmove -c 2 1
    if { ssh-keygen -A }
    /usr/sbin/sshd -De
  ]],
}

rc.sshd_log:merge {
  type = "longrun",
  consumer_for = "sshd",
  run = realign [[
    #!/bin/execlineb -P
    s6-setuidgid daemon
    s6-log 1 t /var/log/sshd
  ]],
}

install("sshd", 3)
