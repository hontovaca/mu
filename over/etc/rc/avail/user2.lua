for ent in _G.io.lines "/etc/passwd" do
  local user, home = ent:match "^([^:]+):.*:(/home/%1):[^:]+$"

  if user then
    rc["user2:" .. user]:merge {
      type = "longrun",
      producer_for = "user2-log:" .. user,
      run = realign([[
      #!/usr/bin/execlineb -P
      fdclose 0 fdmove -c 2 1
      s6-setuidgid %s
      tryexec -c { %s/.user2-run }
      s6-pause
      ]]):format(user, home),
    }

    rc["user2-log:" .. user]:merge {
      type = "longrun",
      consumer_for = "user2:" .. user,
      run = realign([[
      #!/usr/bin/execlineb -P
      fdclose 1 fdclose 2
      s6-setuidgid %s
      s6-log t %s/.user2-uncaught
      ]]):format(user, home),
    }

    install("user2:" .. user, 2, 3)
  end
end
