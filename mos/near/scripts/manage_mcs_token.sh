set -e

SCRIPT_DIR=$(dirname $0)
source $SCRIPT_DIR/config.sh
FILE_NAME=$0

function printHelp() {
  echo "Usage:"
  echo "  $FILE_NAME <command>"
  echo "Commands:"
  echo "  deploy <token name>                                   deploy mcs token"
  echo "  list                                                  view deployed mcs tokens and their to chains"
  echo "  register <token> <mintable>  transfer out ft token    register token"
  echo "  transfer <token> <to chain> <from> <to> <amount>      transfer out mcs token"
  echo "  deposit <token> <from> <to> <amount>                  deposit out mcs token"
  echo "  balance <token> <account>                             view account balance of mcs token"
  echo "  help                                                  show help"
}

function deploy() {
    echo "deploying $1 contract"
    echo near call $MCS_FACTORY_ACCOUNT deploy_mcs_token '{"name": "'$1'", "controller":"'$MCS_ACCOUNT'", "owner": "'$MULTISIG_ACCOUNT'"}'  --accountId $MASTER_ACCOUNT --deposit 10 --gas 300000000000000
    near call $MCS_FACTORY_ACCOUNT deploy_mcs_token '{"name": "'$1'", "controller":"'$MCS_ACCOUNT'", "owner": "'$MULTISIG_ACCOUNT'"}' --accountId $MASTER_ACCOUNT --deposit 10 --gas 300000000000000
}

function register() {
    echo "registering token $1"
    near call $MCS_ACCOUNT register_token '{"token":"'$1'", "mintable":'$2'}' --accountId $MASTER_ACCOUNT --deposit 1 --gas 300000000000000
}

function list_tokens() {
  echo "getting mcs token list from mcs contract"
  near view $MCS_ACCOUNT get_mcs_tokens '{}'
}

function transfer_out() {
  echo "transfer out $5 $1 token from $3 to $4 on chain $2"
  near call $MCS_ACCOUNT transfer_out_token '{"token":"'$1'", "to":'$4', "amount":"'$5'", "to_chain":"'$2'"}' --accountId $3 --gas 60000000000000  --depositYocto 1

}

function deposit_out() {
  echo "deposit out $4 $1 token from $2 to $3 on MAP chain"
  near call $MCS_ACCOUNT deposit_out_token '{"token":"'$1'", "to":'$3', "amount":"'$4'"}' --accountId $2 --gas 60000000000000  --depositYocto 1
}

function balance() {
  echo "get account $2 balance of token $1"
  near view $1 ft_balance_of '{"account_id":"'$2'"}'
}

if [[ $# -gt 0 ]]; then
  case $1 in
    deploy)
      if [[ $# == 2 ]]; then
        shift
        deploy $@
      else
        printHelp
        exit 1
      fi
      ;;
    register)
      if [[ $# == 3 ]]; then
        shift
        register $@
      else
        printHelp
        exit 1
      fi
      ;;
    metadata)
      if [[ $# == 3 ]]; then
        metadata $2 $3
      else
        printHelp
        exit 1
      fi
      ;;
    add)
      if [[ $# == 3 ]]; then
        add_to_chain $2 $3
      else
        printHelp
        exit 1
      fi
      ;;
    remove)
      if [[ $# == 3 ]]; then
        remove_to_chain $2 $3
      else
        printHelp
        exit 1
      fi
      ;;
    list)
      if [[ $# == 1 ]]; then
        list_tokens
      else
        printHelp
        exit 1
      fi
      ;;
    transfer)
      if [[ $# == 6 ]]; then
        shift
        transfer_out $@
      else
        printHelp
        exit 1
      fi
      ;;
    deposit)
      if [[ $# == 5 ]]; then
        shift
        deposit_out $@
      else
        printHelp
        exit 1
      fi
      ;;
    balance)
      if [[ $# == 3 ]]; then
        shift
        balance $@
      else
        printHelp
        exit 1
      fi
      ;;
    help)
      printHelp
      ;;
    *)
      echo "Unknown command $1"
      printHelp
      exit 1
      ;;
  esac
  else
    printHelp
    exit 1
fi
