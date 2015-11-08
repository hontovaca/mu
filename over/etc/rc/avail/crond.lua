rc.crond:merge {
  type = "longrun",
  run = realign [[
    #!/usr/bin/execlineb -P
    fdmove -c 2 1
    crond -fd8
  ]],
}

install("crond", 2, 3)
