cd $(dirname $0)/.. && 
  for repo in $(ls -d */.git | awk -F/ '{print $1}'); do cd $repo && git pull origin master && cd ..; done &&
  cd -
