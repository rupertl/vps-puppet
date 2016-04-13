# This class manages ssh authorized keys for a user

# Parameters:
# user - user to manage keys for
# keys - hash where hashkey is the comment and values are type and key

# Taken from https://ask.puppet.com/question/5201/why-doesnt-ssh_authorized_key-support-an-array-of-keys/

class ssh_public(String $user, Hash $keys) {
  $others = {
    'ensure'  => 'present',
    'user'    => $user,
  }

  create_resources('ssh_authorized_key', $keys, $others)
}
