# Git

## Problems & Solutions
`warning: remote HEAD refers to nonexistent ref, unable to checkout.`
solution: go to your repo and issue `git symbolic-ref HEAD refs/heads/<branch>`
where `branch` is the default branch name you want to use.

Github turned off git protocol (port 9418, url like `git::`). To use https in
place of git tranparently use `git config --global url."https://".insteadOf git://`.
