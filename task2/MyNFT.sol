// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721,Ownable,ERC721URIStorage{

    uint256 public _tokenIdCounter;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public mintPrice = 0.001 ether;

    event NFTMinted(address indexed owner,string indexed  uri,uint256 indexed tokenId);

    constructor(string memory _name,string memory _symbol)  ERC721(_name,_symbol) Ownable(msg.sender){
    
    }

    function mintNFT(address recipient,string memory uri) public payable returns(uint256){
        require(_tokenIdCounter < MAX_SUPPLY,"Max supply reached");
        require(msg.value >= mintPrice,"Sufficient payment");

        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId,uri);

        emit NFTMinted(recipient,uri,newTokenId);
        return newTokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage)returns (bool){
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    function withdraw() public onlyOwner{
        uint256 balance = getBalance();
        require(balance > 0,"No balance transfer");
        (bool success,) = payable(owner()).call{value:balance}("");
        require(success,"Transfer failed");
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}