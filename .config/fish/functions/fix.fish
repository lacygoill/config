function fix
# If you want the terminal to be in an unsane state, to test the function:{{{
#
#     printf '\e(0'
#}}}

  # For more info: https://unix.stackexchange.com/q/79684/289772
  reset

  stty sane
  # those settings come from the output of `stty(1)` in a non-broken terminal
  stty speed 38400
  stty quit undef
  stty start undef
  stty stop undef
  # breaks does *not* cause an interrupt signal
  stty -brkint
  stty -imaxbel
  # assume input characters are UTF-8 encoded
  stty iutf8

  # What's the `rs1` capability?{{{
  #
  # A Reset String.
  #
  #     man -Kw rs1
  #     man infocmp /rs1
  #     man tput /rs1
  #}}}
  tput rs1
  tput rs2
  tput rs3
  tput cnorm
  # make sure the cursor's shape is a steady block
  tput Se
  clear
  printf '\ec'
end
