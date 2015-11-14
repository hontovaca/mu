for ent in _G.io.lines "/etc/passwd" do
  local user, home = ent:match "^([^:]+):.*:(/home/%1):[^:]+$"

  if user then
    rc["user2:" .. user]:merge {
      type = "longrun",
      producer_for = "user2-log:" .. user,
      run = realign([[
      #!/usr/bin/execlineb -P
      fdclose 0 fdmove -c 2 1
      define USER %q
      export HOME %q import -i HOME
      getcwd SERVICE import -i SERVICE
      getpid USERPID import -i USERPID

      s6-envuidgid $USER
      if { import -i GID chgrp $GID supervise supervise/control }
      if { chmod g+x supervise }
      if { chmod g+w supervise/control }
      s6-applyuidgid -U

      cd $HOME
      tryexec -c { ./.user2-run }
      s6-svc -O $SERVICE
      ]]):format(user, home),
    }

    rc["user2-log:" .. user]:merge {
      type = "longrun",
      consumer_for = "user2:" .. user,
      run = realign([[
      #!/usr/bin/execlineb -P
      fdclose 0 fdclose 1 fdclose 2
      s6-setuidgid %q
      s6-log t %q/.user2-uncaught
      ]]):format(user, home),
    }

    install("user2:" .. user, 2, 3)
  end
end
