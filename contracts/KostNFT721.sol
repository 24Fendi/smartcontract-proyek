// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KostNFT is ERC721, Ownable, ERC721URIStorage {
    uint256 public constant TOTALSUPPLY = 10;
    uint256 private _nextTokenId = 1;
    address private _markerplaceAddress;
    string private uri = "http://localhost:3000/metadata/";

    struct investors {
        uint index;
        address account;
    }

    address[] private _allInvestors;

    modifier onlyMarketPlace() {
        require(msg.sender == _markerplaceAddress, "Unauthorized");
        _;
    }

    constructor() ERC721("KostNFT", "KOST") Ownable(msg.sender) {}

    function setMarketplaceAddress(
        address marketplaceaddress
    ) external onlyOwner {
        _markerplaceAddress = marketplaceaddress;
    }

    function safeMint(address to) public onlyMarketPlace {
        uint256 tokenId = _nextTokenId++;
        require(tokenId <= TOTALSUPPLY, "Maximum Limit is 10");

        _allInvestors.push(to);
        _safeMint(to, tokenId);
        _setTokenURI(
            tokenId,
            string.concat(uri, Strings.toString(tokenId), ".json")
        );
    }

    function getAllInvestors() external view returns (address[] memory) {
        return _allInvestors;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getMarketplaceAddress() public view returns (address) {
        return _markerplaceAddress;
    }
}