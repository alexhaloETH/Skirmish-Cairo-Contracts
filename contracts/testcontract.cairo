
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





# need setter and getter implemente the bank here or whatevr is happening 
# owner transfer shits 
#also the hint for t
#set it as a fee not willy nilly
# 1000000000000000000







#
#   storage vars
#



@storage_var
func _token() -> (token_address: felt):
end






# account 1      alexhalo3115       30151089121334322374026277173
# account 2
# account 3       alexhalo        7020097486985456751
# account 4
















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
   
    return ()
end



#
#   getter
#



#need a function that return the readines of both plus the balance of both makes it quick return a touple





#
#   setter
#










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


    let (transfered) = IERC20.transferFrom(contract_address=token,sender=caller,recipient= contract_address, amount =Uint256(10000000000000000000,0))
    with_attr error_mesage("successful transfer"):
        assert transfered = TRUE
    end

    return()

end





