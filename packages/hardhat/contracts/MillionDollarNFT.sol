// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "lib/ERC4907.sol";
import "lib/IERC4907.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract millionDollarHomepageNFT is ERC4907, Ownable {
    mapping (uint => string) internal _idToURI;
    uint64 expiryInit;
    uint64 oneYear;
    mapping (uint => uint) public salePrice; 
    event newURI(string indexed baseURI, uint indexed tokenId);

    constructor (string memory name, string memory symbol) ERC4907(name, symbol) {
        oneYear = 365 days;
        expiryInit = (uint64((block.timestamp) + oneYear)); 
    } 

    // admin override
    function setUser(uint256 tokenId, address user, uint64 expires) public override onlyOwner{
        registerUser(tokenId, user, expires); 
    }
   //internal function that handles the logic of setting the renter struct
   function registerUser (uint tokenId, address user, uint64 expires) internal {
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }
    
    //if the token is not expired, then return the address of renter, otherwise return the 0 address
    function userOf(uint256 tokenId) public view override returns(address){
        if( uint64(block.timestamp) < uint64(_users[tokenId].expires)){
            return _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    //initial mint
    function mint (address to, uint tokenId) external payable { 
        require(tokenId > 0 && tokenId <= 1000000, "invalid id");
        salePrice[tokenId] += 1 ether;
        require(msg.value >= salePrice[tokenId], "Insufficient MATIC");
        _mint(to, tokenId);
        registerUser(tokenId, to, expiryInit);
    }
    //register tokens once expired
    function registerExpiredToken (address to, uint tokenId) external payable{
        require (userOf(tokenId) == address(0), "Registered");
        require (_exists(tokenId), "must exist");
        salePrice[tokenId] += 1 ether;
        require(msg.value >= salePrice[tokenId], "Insufficient MATIC");
        _burn(tokenId);
        _mint(to, tokenId);
        registerUser(tokenId, to, expiryInit);
    }
    //renew token before expiry
    function renewToken (address to, uint tokenId) external payable {
        require (msg.sender == userOf(tokenId));
        salePrice[tokenId] += 1 ether;
        require(msg.value >= salePrice[tokenId], "Insufficient MATIC");
        if(to != ownerOf(tokenId)){
            _burn(tokenId);
            _mint(to, tokenId);
        }
        uint64 expiry = (oneYear + _users[tokenId].expires);
        registerUser(tokenId, to, expiry);
    }
    // @param newURI: <baseURI, points to decentralized storage>
     function setBaseURI (string memory newBaseURI, uint tokenId) external {
        require(msg.sender == userOf(tokenId), "not user or expired");
        _idToURI[tokenId] = newBaseURI;
        emit newURI(newBaseURI, tokenId);
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI(tokenId);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId, ".json")) : "";
    }
    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI(uint tokenId) internal view virtual returns (string memory) {
        return _idToURI[tokenId];
    }    
    function withdraw (address payable to) external onlyOwner {
        (bool success,) = to.call {value: address(this).balance}("");
        require(success);
    }
    //grant grace period to buyers for registration
    function _afterTokenTransfer(
        address /*from*/,
        address to,
        uint256 tokenId
    ) internal override virtual {
        uint64 gracePeriod = 1 weeks;
        if (userOf(tokenId) == address(0)){
            registerUser(tokenId, to, gracePeriod);
        }
    }
}
