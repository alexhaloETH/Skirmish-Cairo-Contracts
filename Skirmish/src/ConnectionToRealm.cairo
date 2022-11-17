// MIT LICENSE
// -----------------------------------


// functions ---

// get all of the realms held by the address

// get all the troops of a realm


%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin



@storage_var
func _ERC721RealmAddress() -> (res: felt) {
}

@storage_var
func _CombatAddress() -> (res: felt) {
}


@constructor
func constructor{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(_realms_address: felt, _combat_address : felt){
    _ERC721RealmAddress.write(_realms_address);
    _CombatAddress.write(_combat_address);

    return ();
}












