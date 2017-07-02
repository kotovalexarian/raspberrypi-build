log() {
  tput setaf 2 # Green color
  date +"[%T] $@"
  tput sgr0 # No color
}

log_begin() {
  log "Begin $1"
}

log_end() {
  log "End   $1"
}
