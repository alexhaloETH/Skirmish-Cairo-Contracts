// MIT LICENSE
// -----------------------------------





// every address that connects to the game will be given a private key, which is stored in the game database

// when the player wants to modify its squad we call setDeckData,
    //this function is dependent on the caller so no other caller can overwrite the deck of another player
    // this function takes the realmId of the sqaud that is being changed, it also take the already encrypted data
    //the data is encrypted using EAS method the key being the private key stored in the game, the data is encrypted then given so its not public

// on the view take the realmID of the specific squad to fetch plus the account of the holder
// this returns an encrypted message that can only be decrypted from the private key that is from that address stored in the game therefore everything is secure

// WIP 

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

struct SavedDeck {
    address: felt,
    realmId: felt,
}

@storage_var
func _DeckDatabase(savedDeck : SavedDeck) -> (secretPhrase: felt){
}


@external
func SetDeckData{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_realmId : felt, _encryptedData : felt){

    let (caller) = get_caller_address();
    let dummyStruct: SavedDeck = SavedDeck(address=caller, realmId=_realmId);

    _DeckDatabase.write(dummyStruct,_encryptedData);
    return();
    }

@view
func GetDeckData{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_realmId : felt, _address : felt) -> (encryptedData : felt){

    let dummyStruct: SavedDeck = SavedDeck(address=_address, realmId=_realmId);

    let secretData : felt = _DeckDatabase.read(dummyStruct);
    return(encryptedData = secretData);
    }







