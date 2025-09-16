module MyModule::CollaborativeWhiteboard {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::timestamp;

    /// Struct representing a collaborative whiteboard
    struct Whiteboard has store, key {
        name: String,           // Name of the whiteboard
        ipfs_cid: String,       // IPFS Content Identifier for stored content
        owner: address,         // Owner of the whiteboard
        collaborators: vector<address>, // List of allowed collaborators
        last_updated: u64,      // Timestamp of last update
        is_public: bool,        // Whether whiteboard is publicly accessible
    }

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_WHITEBOARD_NOT_FOUND: u64 = 2;

    /// Function to create a new collaborative whiteboard
    public fun create_whiteboard(
        creator: &signer, 
        name: String, 
        is_public: bool
    ) {
        let creator_addr = signer::address_of(creator);
        
        let whiteboard = Whiteboard {
            name,
            ipfs_cid: string::utf8(b""), // Initially empty, will be set on first save
            owner: creator_addr,
            collaborators: vector::empty<address>(),
            last_updated: timestamp::now_seconds(),
            is_public,
        };
        
        move_to(creator, whiteboard);
    }

    /// Function to update whiteboard content with new IPFS CID
    public fun update_content(
        user: &signer, 
        whiteboard_owner: address, 
        new_ipfs_cid: String
    ) acquires Whiteboard {
        let user_addr = signer::address_of(user);
        let whiteboard = borrow_global_mut<Whiteboard>(whiteboard_owner);
        
        // Check if user is authorized (owner, collaborator, or public board)
        assert!(
            whiteboard.owner == user_addr || 
            vector::contains(&whiteboard.collaborators, &user_addr) ||
            whiteboard.is_public, 
            E_NOT_AUTHORIZED
        );
        
        // Update the IPFS CID and timestamp
        whiteboard.ipfs_cid = new_ipfs_cid;
        whiteboard.last_updated = timestamp::now_seconds();
    }
}