// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC4907.sol";

    
contract millionDollarHomepageNFT is ERC4907, Ownable{
    error expired();
    mapping (uint => string) internal _idToURI;
    uint expiryInit;
    uint price; 

    event newURI(string indexed baseURI, uint indexed tokenId);

    constructor (string memory name, string memory symbol) ERC4907(name, symbol) {
        expiryInit = 1 years; 
        price = 2 ether;
    }

    function setUser(uint256 tokenId, address user, uint64 expires) public override{
        require(msg.sender == owner() || _isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        uint64 expiry = _users[tokenId].expires; 
        if (msg.sender == owner()){
            registerUser(tokenId, user, expires);
        }
        else if(msg.sender != owner() && block.timestamp < expiry){
            registerUser(tokenId, user, expiry);
        } 
       else{
            revert expired();
       }
    }
    function setPrice (uint newPrice) external onlyOwner returns (uint){
        price = newPrice;
        return price;
    }

    function registerUser (uint tokenId, address user, uint expires) internal {
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }


    function userOf(uint256 tokenId) public view override returns(address){
        if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    function userExpires(uint256 tokenId) public view override returns(uint256){
        return _users[tokenId].expires;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    function mint (address to, uint tokenId) payable external {
        require (msg.sender == tx.origin, "no contracts allowed");
        require(msg.value > price, "Insufficient Ether");
        if (block.timestamp >= userExpires(tokenId)){
            _burn(tokenId);
        }
        _mint(to, tokenId);
        registerUser(tokenId, to, expiryInit);
        }
    }

    // @param newURI: <baseURI, points to decentralized storage>
     function setBaseURI (string memory newURI, uint tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        if (block.timestamp >= userExpires(tokenId)){
            revert expired();
        }
        _idToURI[tokenId] = newURI;
        emit newURI(newURI, tokenId);
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override{
        super._beforeTokenTransfer(from, to, tokenId);
        uint64 expiry = _users[tokenId].expires; 
        delete _users[tokenId];
        //take over lease
        if(msg.sender == owner()){
            emit UpdateUser(tokenId, address(0), 0);

        }
        else if (msg.sender != owner() && block.timestamp < expiry){
            setUser(tokenId, to, expiry); 
        }
        else{
            revert expired(); 
        }
    }
}
