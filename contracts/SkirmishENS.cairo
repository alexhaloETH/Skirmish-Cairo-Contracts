
# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.3.2 (contracts/SkirmishENS.cairo)


%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.math import assert_not_zero, assert_le, assert_lt,assert_nn_le, assert_nn,unsigned_div_rem

from openzeppelin.utils.constants.library import TRUE, FALSE
from openzeppelin.token.erc20.IERC20 import IERC20

from starkware.cairo.common.uint256 import Uint256,uint256_lt




#
#   notes
#







struct MatchData:
    member LH_address : felt
    member LJ_address : felt
    member wager_amount : Uint256
end




#
#   storage vars
#

# SNS = Skirmish Name Service
@storage_var
func AddressToSNSStorage(user:felt) -> (sns : felt):
end

@storage_var
func SNSToAddressStorage(sns:felt) -> (user : felt):
end

@storage_var
func _token() -> (token_address: felt):
end

@storage_var
func _SNS_cost() -> (SNS_cost: Uint256):
end

#this as a decimal maybe, to deal with
@storage_var
func _fee_perc() -> (fee_perc: felt):
end






# the match ID is given by unity
@storage_var
func _match(mathc_ID : felt) -> (res : MatchData):
end







#
#   constructor
#

@constructor
func constructor{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(token: felt):
    _token.write(token)
    _SNS_cost.write(Uint256(10 * 10 **18,0))
    _fee_perc.write(1)
    return ()
end



#
#   getter
#



# given an address fetch the SNS
@view
func get_SNS_from_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address : felt) -> (res : felt):
    let (res) = AddressToSNSStorage.read(user = address)
    return (res)
end

#get the Address of the owner of an SNS
@view
func get_address_from_SNS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(sns : felt) -> (address : felt):
    let (res) = SNSToAddressStorage.read(sns = sns)
    return (res)
end

#get the address of the token used for all of the transactions
@view
func get_accepted_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res) = _token.read()
    return (res)
end

#get the current cost to make a skirmish username
@view
func get_SNS_Cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : Uint256):
    let (res : Uint256) = _SNS_cost.read()
    return (res)
end

#see the current balance of the contract
@view
func see_balance_of_contract{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (balance : Uint256):

    let (contract_address) = get_contract_address()
    let (token) = _token.read()

    let (balance) = IERC20.balanceOf(contract_address=token, account=contract_address)
    return (balance)
end


#
#   setter
#


# set the address of the accepted paying token
@external
func set_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token_add : felt) -> ():
    _token.write(token_add)
    return ()
end

# set the fee, this is the % of the cut that the contract takes, need to be       equal OR more than 0 AND less than 90
@external
func set_fee{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(fee_perc : felt) -> ():

    with_attr error_mesage("fee is too high"):
        assert_nn_le(fee_perc,90)
    end

    _fee_perc.write(fee_perc)
    return ()
end

# sets the cost to make an skirmish name
@external
func set_SNS_Cost{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(cost : Uint256) -> ():

    #with_attr error_mesage("this cost is negative"):
        #assert_nn(cost)
    #end

    #with_attr error_mesage("this cost is 0"):
     #   assert_not_zero(cost)
    #end


    _SNS_cost.write(cost)
    return ()
end





#
#   interaction functions
#


# set the SNS of an address.
@external
func set_SNS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( sns : felt):

    alloc_locals
    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (token) = _token.read()
    
    let (balance) = IERC20.balanceOf(contract_address=token, account=caller)

    let (cost : Uint256) = _SNS_cost.read()
    #checks if SNS is free
    with_attr error_message("This SNS is already taken"):
            let (sns_read) = SNSToAddressStorage.read(sns)
            assert sns_read = 0
        end


    let (allowance : Uint256) = IERC20.allowance(contract_address=token, owner=caller, spender = contract_address)
    let (check_allowance) = uint256_lt(cost, allowance)
    with_attr error_mesage("the allowance is fucked"):
        assert check_allowance = TRUE
    end


    #checks if there are enoguh coin helf from caller
    let (check_balance) = uint256_lt(cost, balance)
    with_attr error_mesage("Owner does not hold enough tokens."):
        assert check_balance = TRUE
    end

    let (transfered) = IERC20.transferFrom(contract_address=token,sender=caller,recipient= contract_address, amount =cost)
    with_attr error_mesage("successful transfer"):
        assert transfered = TRUE
    end

    # .read functions return 0 if the given key is non existant
    let (address_read) = AddressToSNSStorage.read(caller)
    if address_read == FALSE:

        SNSToAddressStorage.write(sns,caller)
        AddressToSNSStorage.write(caller, sns)

        return()
    end



    # if that adress already had an sns set then 

    let(old_SNS) = AddressToSNSStorage.read(caller)
    SNSToAddressStorage.write(old_SNS,0)

    SNSToAddressStorage.write(sns,caller)
    AddressToSNSStorage.write(caller, sns)
    
    return ()
end


# owner only withdraws tokens from the contract
@external
func withdraw_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():

    let (contract_address) = get_contract_address()
    let (token) = _token.read()

    let (caller) = get_caller_address()
    let (balance) = IERC20.balanceOf(contract_address=token, account=contract_address)

    IERC20.transfer(contract_address=token,recipient= caller, amount =balance)

    return ()
end


@external
func Game_Lobby_Start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_matchID : felt, wager:Uint256) -> ():

    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (token) = _token.read()

    let _matchData : MatchData = MatchData(LH_address = caller, LJ_address = 0, wager_amount = wager)

    _match.write(_matchID, _matchData)
    IERC20.transferFrom(contract_address=token,sender=caller,recipient= contract_address, amount =wager)
    return ()
end





@view
func Game_Lobby_view{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_matchID : felt) -> (Lobby_host :felt, Lobby_joinee : felt, wager_amount : Uint256):

    let _matchData : MatchData = _match.read(_matchID)

    return (Lobby_host= _matchData.LH_address, Lobby_joinee = _matchData.LJ_address, wager_amount = _matchData.wager_amount)
end





@external
func Game_Lobby_Join{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_matchID : felt) -> ():



    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (token) = _token.read()

    let (_matchData : MatchData) = _match.read(_matchID)


    _match.write(_matchID, MatchData( _matchData.LH_address , caller , _matchData.wager_amount))
    IERC20.transferFrom(contract_address=token,sender=caller,recipient= contract_address, amount =_matchData.wager_amount)
    return ()
end



@external
func Game_outcome{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_matchID : felt, who_won : felt) -> ():


    alloc_locals
    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (token) = _token.read()
    let (perc) = _fee_perc.read()
    
    let (_matchData : MatchData) = _match.read(_matchID)


    if who_won == 0:

        IERC20.transfer(contract_address=token,recipient = _matchData.LH_address , amount = _matchData.wager_amount)
        return()
    end



    IERC20.transfer(contract_address=token,recipient = _matchData.LJ_address, amount = _matchData.wager_amount)

    return ()
end















#
#   non-interaction functions
#






