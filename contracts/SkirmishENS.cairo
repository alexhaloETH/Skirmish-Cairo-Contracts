%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.math import assert_not_zero, assert_le, assert_lt

from openzeppelin.utils.constants.library import TRUE,FALSE
from openzeppelin.token.erc20.IERC20 import IERC20

from starkware.cairo.common.uint256 import Uint256,uint256_lt

# SNS = Skirmish Name Service
@storage_var
func AddressToSNSStorage(user:felt) -> (sns : felt):
end

@storage_var
func SNSToAddressStorage(sns:felt) -> (user : felt):
end


@storage_var
func _token() -> (res: felt):
end





@constructor
func constructor{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(token: felt):
    _token.write(token)
    return ()
end





# set the SNS of an address.
@external
func set_SNS{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( sns : felt):

    alloc_locals
    let (caller) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (token) = _token.read()
    
    let (balance) = IERC20.balanceOf(contract_address=token, account=caller)


    #checks if SNS is free
    with_attr error_message("This SNS is already taken"):
            let (sns_read) = SNSToAddressStorage.read(sns)
            assert sns_read = 0
        end


    #checks if there are enoguh coin helf from caller
    #let (check_balance) = uint256_lt(Uint256(10,0), balance)
    #with_attr error_mesage("Owner does not hold enough tokens."):
        #assert check_balance = TRUE
    #end


    IERC20.transfer(contract_address=token,recipient= contract_address, amount =Uint256(10,0))

    # .read functions return 0 if the given key is non existant
    let (address_read) = AddressToSNSStorage.read(caller)
    if address_read == FALSE:

        SNSToAddressStorage.write(sns,caller)
        AddressToSNSStorage.write(caller, sns)

        return()
    end



    # if that adress already had a an sns set then 

    let(old_SNS) = AddressToSNSStorage.read(caller)
    SNSToAddressStorage.write(old_SNS,0)

    SNSToAddressStorage.write(sns,caller)
    AddressToSNSStorage.write(caller, sns)
    
    return ()
end






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




