# This is the main puppet catalog for mezzelune. Running this will ensure
# all items under puppet control are executed. Individual items can be
# run by eg
#    puppet apply -e 'include postfix'

include logrotate
include ntpd

class {'postfix':
  server_type  => 'satellite'
}

