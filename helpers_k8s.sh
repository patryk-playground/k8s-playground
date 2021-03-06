# Below scripts will be added to ~/.bashrc of the local user

alias k=kubectl
complete -F __start_kubectl k
alias kcd='kubectl config set-context --current --namespace'

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
    k get deploy,pod,rs,ds,sts,ep,svc,secrets,ing -o wide -n $ns --show-labels
}

function switch_ns() {
    ns=$1
    if [[ ! -z "$ns" ]]; then
        k config set-context --current --namespace=$ns
    else
        echo "Namespace missing!"
    fi
}

function show_storage(){
    kubectl get sc,pvc,pv --all-namespaces -o wide
}

# [[ $TERM != "screen" ]] && exec tmux -f ~/.tmux.conf
