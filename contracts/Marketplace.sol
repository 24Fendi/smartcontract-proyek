// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDT.sol";


interface KostNFT {
    function safeMint(address to) external;
    function getAllInvestors() external view returns (address[] memory);
}

contract NFTMarketplace is Ownable {
    using Math for uint256;

    uint256 public constant NFTSUPPLY = 10;
    uint256 public immutable serviceFeePercentage = 10;
    uint256 public immutable environmentalContributionPercentage = 10;
    uint256 public immutable investorSharePercentage = 80;

    KostNFT private kostNft;
    uint256 public price = 100000;
    USDTTOKEN private usdtToken;
    uint256 private totalNFTSold;

    constructor(
        address _NftAddress,
        address _tokenAddress
    ) Ownable(msg.sender) {
        kostNft = KostNFT(_NftAddress);
        usdtToken = USDTTOKEN(_tokenAddress);
    }

    modifier onlyOperator() {
        require(msg.sender == owner() || isAdmin[msg.sender], "Not Operator");
        _;
    }

    mapping(address => bool) public isAdmin;
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event IncomeDistributed(address indexed investor, uint256 investorShare);

    function addAdmin(address newAdmin) external onlyOwner {
        require(!isAdmin[newAdmin], "Address is already an admin");
        isAdmin[newAdmin] = true;
        emit AdminAdded(newAdmin);
    }

    function removeAdmin(address adminToRemove) external onlyOwner {
        require(isAdmin[adminToRemove], "Address is not an admin");
        isAdmin[adminToRemove] = false;
        emit AdminRemoved(adminToRemove);
    }

    function isAddressAdmin(address addr) external view returns (bool) {
        return isAdmin[addr];
    }

    function mintNFT(address to) external {
        require(totalNFTSold < NFTSUPPLY, "Maximum limit of NFT is 10");
        require(
            usdtToken.balanceOf(msg.sender) >= price,
            "Saldo Tidak Mencukupi"
        );
        usdtToken.transferFrom(msg.sender, address(this), price);
        kostNft.safeMint(to);
        totalNFTSold++;
    }

    function getTotalNFTSold() external view returns (uint256) {
        return totalNFTSold;
    }

    function distributeIncome(uint256 incomeAmount) external onlyOperator {
        require(incomeAmount > 0, "Income amount must be greater than 0");

        uint256 investorShare = (incomeAmount * investorSharePercentage) /
            100 /
            NFTSUPPLY;
        uint256 serviceFee = (incomeAmount * serviceFeePercentage) / 100;
        uint256 environmentalContribution = (incomeAmount *
            environmentalContributionPercentage) / 100;

        require(
            usdtToken.transfer(owner(), serviceFee),
            "Service fee transfer failed"
        );
        require(
            usdtToken.transfer(owner(), environmentalContribution),
            "Environmental contribution transfer failed"
        );

        address[] memory investors = kostNft.getAllInvestors();
        for (uint i = 0; i < investors.length; i++) {
            if (investors[i] != address(0)) {
                require(
                    usdtToken.transfer(investors[i], investorShare),
                    "Investor share transfer failed"
                );

                emit IncomeDistributed(investors[i], investorShare);
            }
        }
    }
}