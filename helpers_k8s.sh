# Below scripts will be added to ~/.bashrc of the local user

alias k=kubectl

function current_ns() {
  ns=$(kubectl config view --minify | awk  '/namespace:/ {print $2}')
  echo $ns
}

function show_ns() {
    ns=$1
    if [[ -z "$ns" ]]; then
        ns=$(kubectl config view --minify | awk  '/namespace:/ {print $2}')
    fi
    echo "Current namespace=$ns"
    k get deploy,pod,rs,ds,sts,ep,svc,ing -o wide -n $ns --show-labels
}

function switch_ns() {
    ns=$1
    if [[ ! -z "$ns" ]]; then
        k config set-context --current --namespace=$ns
    else
        echo "Namespace missing!"
    fi
}

[[ $TERM != "screen" ]] && exec tmux
