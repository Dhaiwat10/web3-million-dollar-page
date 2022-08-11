// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC4907.sol";

    
contract millionDollarHomepageNFT is ERC4907, Ownable{
    error expired();
    error registered();
    mapping (uint => string) internal _idToURI;
    uint64 expiryInit;
    uint price; 
    event newURI(string indexed baseURI, uint indexed tokenId);

    constructor (string memory name, string memory symbol) ERC4907(name, symbol) {
        expiryInit = (uint64((block.timestamp) + 365 days)); 
        price = 0 ether;
    }

    function setUser(uint256 tokenId, address user, uint64 expires) public override onlyOwner{
        registerUser(tokenId, user, expires); 
    }
 
    function registerUser (uint tokenId, address user, uint64 expires) internal {
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    function setPrice (uint newPrice) external onlyOwner returns (uint){
        price = newPrice;
        return price;
    }


    function userOf(uint256 tokenId) public view override returns(address){
        if( uint64(block.timestamp) < uint64(_users[tokenId].expires)){
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
        require(msg.value >= price, "Insufficient Ether");
        require (!_exists(tokenId), "Already Minted");
        _mint(to, tokenId);
        registerUser(tokenId, to, expiryInit);
    }
    function registerExpiredToken (address to, uint tokenId) external payable{
        if (userOf(tokenId) == address(0)){
            //payment logic here
            _burn(tokenId);
            _mint(to, tokenId);
            registerUser(tokenId, to, expiryInit);
        }
        else{
            revert registered();
        }
    }

    // @param newURI: <baseURI, points to decentralized storage>
     function setBaseURI (string memory newBaseURI, uint tokenId) public {
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

    function transfer (address from, address to, uint tokenId) external {
        uint64 expiry = _users[tokenId].expires; 
        //take over lease
        //execute transfer
        safeTransferFrom(from, to, tokenId);
        registerUser(tokenId, to, expiry);

    }
}
