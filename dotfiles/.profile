# Launch ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
fi


# Kill ssh-agent on exit
kill_ssh_agent() {
  if [ -n "$SSH_AUTH_SOCK" ] ; then
    eval `/usr/bin/ssh-agent -k`
  fi
}
trap kill_ssh_agent EXIT

