// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// we need to import the helper function from the Base64 contract
import { Base64 } from "./libraries/Base64.sol";

contract LatinNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter public _tokenTotal;

  string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: sans-serif; font-size: 18px; }</style><rect width='100%' height='100%' fill='";
  string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string [] firstWords = ["callide", "infula", "gratulor", "optimates", "paratus", "quemadmodum", "invado", "dimidium", "indagatio", "perpetuus"];
  string[] secondWords = ["audax", "curia", "nonnisi", "curiosus", "inclino", "munitio", "super", "vestis", "vorago", "quatinus", "inventor", "protesto", "appono", "cuius", "decorus", "pactus"];
  string[] thirdWords = ["sonitus", "certus", "audeo", "conspicio", "degenero", "lacrimosus", "infirmatio", "mansuetus", "oportunitas", "pecunia", "prolecto", "regina", "sapiens", "satura", "esurio"];

  string[] colors = ["#2a324b", "#d81159", "#bfb1c1", "#b5bec6", "#c7dbe6"];

  event LatinNFTMinted(address sender, uint256 tokenId);

  // We need to pass the name of our NFTs token and it's symbol.
  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract");
  }

  function pickRandomFirstWord(uint256 tokenId) private view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) private view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) private view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function pickRandomColor(uint256 tokenId) private view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colors.length;
    return colors[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeLatinNFT() public {
    require(_tokenIds.current() <= 50);

    uint256 newItemId = _tokenIds.current();

    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, ' ',  second, ' ', third));

    string memory randomColor = pickRandomColor(newItemId);
    string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            combinedWord,
            '", "description": "A concattenation of Latin words that will change your life.", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    // actually mint the NFT to the sender using msg.sender.
    _safeMint(msg.sender, newItemId);

    // set the NFTs data
    _setTokenURI(newItemId, finalTokenUri);

    // Increment the counter for when the next NFT is minted
    _tokenIds.increment();

    // Increment the total when the next is minted
    _tokenTotal.increment();

    // console.log to see who has minted and when it was minted
    console.log("An NFT w/ ID: %s , has been minted to %s", newItemId, msg.sender);
    console.log(_tokenTotal.current());

    emit LatinNFTMinted(msg.sender, newItemId);
  }

  function getTotalNFTsMintedSoFar() public view returns (uint) {
    return _tokenTotal.current();
  }
}