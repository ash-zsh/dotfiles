# Attempts to mount the tome and create a snapshot, if the tome is not already
# mounted. Sets CWD to within the tome.
export def --env mount []: nothing -> nothing {
  if (mountpoint ~/tome | complete | get exit_code) != 0 {
    sudo systemctl start systemd-cryptsetup@tome.service
    sudo mount ~/tome
    sudo snapper -c tome create --description 'mount' --read-only

    let window = tags | get number | last 2

    print 'Welcome! Summary of last session:'
    status $window.0 $window.1
  } else {
    print 'Tome already mounted'
  }

  cd ~/tome
}

# Unmounts the tome. Cannot be performed while something is open within it
# (f.e. shell).
export def --env umount []: nothing -> nothing {
  if (pwd | str starts-with ('~/tome' | path expand)) {
    cd ~
  }

  sudo umount -R ~/tome
  sudo systemctl stop systemd-cryptsetup@tome.service
}

# Views the dated revisions of the tome, which are BTRFS-snapper snapshots.
export def tags []: nothing -> table {
  sudo snapper -c tome --machine-readable csv list
  | from csv
  | select number date description
  | upsert date {|r|
    let trim = $r.date | str trim
    if ($trim | is-empty) { null } else { $trim | into datetime }
  }
}

# Marks a revision of the tome at the current time.
export def tag [
  description: string # The description of the revision.
]: nothing -> nothing {
  sudo snapper -c tome create --description $description
}

# Removes revision(s) of the tome according to the revision numbers provided
# through input.
export def untag []: list<int> -> nothing {
  sudo snapper -c tome delete ...$in
}

# Shows a small summary of filesystem changes between two revisions.
export def status [
  from: int, # The old revision to compare.
  to: int = 0 # The new revision to compare. 0 by default, meaning the current (unpinned) revision.
]: nothing -> string {
  sudo snapper -c tome status $"($from)..($to)"
}

# Shows file diffs between two revisions. For a more concise summary, see
# `tome status`.
export def diff [
  from: int, # The old revision to compare.
  to: int # The new revision to compare. 0 by default, meaning the current (unpinned) revision.
]: nothing -> string {
  sudo snapper -c tome diff $"($from)..($to)"
}

# Undoes specific filesystem changes between two revisions according to the
# paths provided through input.
export def undo [
  from: int, # The old revision to compare.
  to: int, # The new revision to compare. 0 by default, meaning the current (unpinned) revision.
]: list<path> -> string {
  sudo snapper -c tome undochange $"($from)..($to)" ...$in
} 
