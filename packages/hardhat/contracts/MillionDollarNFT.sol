// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "lib/ERC4907.sol";
import "lib/IERC4907.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract millionDollarHomepageNFT is ERC4907, ReentrancyGuard, Ownable{
    error expired();
    error registered();
    mapping (uint => string) internal _idToURI;
    uint64 expiryInit;
    mapping (uint => uint) public salePrice; 
    AggregatorV3Interface internal priceFeed;
    event newURI(string indexed baseURI, uint indexed tokenId);

    constructor (string memory name, string memory symbol) ERC4907(name, symbol) {
        expiryInit = (uint64((block.timestamp) + 365 days)); 
       // MATIC mainnet, MATIC/USD
        priceFeed = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);
    }


    function getLatestPrice() public view returns (int) {
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
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

    function getSalePrice (uint tokenId) public view returns (uint256) {
        return (salePrice[tokenId]/(uint256(getLatestPrice()))  * (10**18));
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
        require(msg.value >= getSalePrice(tokenId), "Insufficient MATIC");
        require (!_exists(tokenId), "Already Minted");
        require(tokenId > 0 && tokenId <= 10000);
        ++salePrice[tokenId];
        _mint(to, tokenId);
        registerUser(tokenId, to, expiryInit);
    }
    function registerExpiredToken (address to, uint tokenId) external payable{
        if (userOf(tokenId) == address(0) && _exists(tokenId)){
            //payment logic here
            ++salePrice[tokenId];
            require(msg.value >= getSalePrice(tokenId), "Insufficient MATIC");
            _burn(tokenId);
            _mint(to, tokenId);
            registerUser(tokenId, to, expiryInit);
        }
        else{
            revert registered();
        }
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

    //calls safeTransferFrom
    //transfers the lease too
    //don't call safeTransferFrom directly -- your token will transfer but it will be expired.
    function transferFrom (address from, address to, uint tokenId) public override nonReentrant{
        uint64 expiry = _users[tokenId].expires; 
        //take over lease
        //execute transfer
        //DO NOT REMOVE nonReentrant modifier, this function would otherwise be reentrant
        //if I switch the order, the owner is incorrect -- would be address(0)
        //thus, I'm taking the increased bytecode tradeoff
        safeTransferFrom(from, to, tokenId);
        registerUser(tokenId, to, expiry);
    }
}
