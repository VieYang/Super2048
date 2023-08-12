// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Super2048 is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping (address => uint256[16]) public grids;
    mapping (uint256 => uint256[16]) public grids2048;

    // Game
    bytes32 public seed;

    enum Direction { Up, Down, Left, Right }

    // mint
    uint256 public constant MAX_SUPPLY = 3; // 42096
    uint256 public constant MINT_THRESHOLD = 16; // 2048

    constructor() ERC721("Super2048", "2048") {
        seed = keccak256(abi.encodePacked(address(this), block.number, block.timestamp, msg.sender));
    }

  

    function storeNumbers(uint16[16] memory numbers) public pure returns (uint16[16] memory) {
        // For demonstration purposes, simply return the input numbers
        return numbers;
    }

    function getGrid(address account) public view returns(uint256[16] memory) {
        return grids[account];
    }

    function startGame() public {
        _startGame(msg.sender);
    }

    function _startGame(address account) internal  {
        for (uint256 i = 0; i < 16; i++) {
            if (grids[account][i] != 0) {
                // game started
                return;
            }
        }
        randomGrid(account);
    }

    function forceStartGame(address account) public {
        for (uint256 i = 0; i < 16; i++) {
            grids[account][i] = 0;
        }
        randomGrid(account);
    }

    function randomGrid(address account) public {
        uint256 i = uint256(seed) % 16;
        seed = keccak256(abi.encodePacked(seed, account, i));
        uint256 j = uint256(seed) % 16;
        if (i == j) {
            j = (j + 1)%16;
        }
        seed = keccak256(abi.encodePacked(seed, account, j));
       
        uint256[16] storage grid =  grids[account];
        uint256 n = 0;
        for (n = 0; n < 16; n++) {
            if (grid[(n+i)%16] == 0) {
                grid[(n+i)%16] = 2; // 2 or 4
                break;
            }
        }
        if (n == 16) {
            // endGame, but may not end
        }
       
        n = 0;
        for ( n = 0; n < 16; n++) {
            if (grid[(n+j)%16] == 0) {
                grid[(n+j)%16] = 2; // 2 or 4
                break ;
            }
        }
        if (n == 16) {
            // endGame, but may not end
        }
    }

    function move(Direction direction) public {
        if (moveCore(direction)) {
            randomGrid(msg.sender);
        }
    }

    function moveCore(Direction direction) public returns (bool moved){
        address account = msg.sender;
        uint256[16] storage grid =  grids[account];

        if (direction == Direction.Up) {
            for (uint x = 0; x < 4; x++) {
                uint256 newI = 0;
                bool check = false;
                for (uint y = 0; y < 4; y++) {
                    uint256 value = grid[x+4*y]; 
                    if (value == 0) {
                        continue;
                    }
                    if (check) {
                        if (grid[x+4*newI] == value) {
                            grid[x+4*newI] += value;
                            newI++;
                            check = false;
                        } else {
                            newI++;
                            grid[x+4*newI] = value;
                            check = true;
                        }
                    } else {
                        grid[x+4*newI] = value;
                        check = true;
                    }
                }
                if (check) {
                    newI++;
                }
                if (newI < 4) {
                    moved = true;
                    for ( ;newI < 4; newI++){
                        grid[x+4*newI] = 0;
                    }
                }
            }
        } else if (direction == Direction.Down) {
            for (uint x = 0; x < 4; x++) {
                uint256 newI = 0;
                bool check = false;
                for (uint y = 0; y < 4; y++) {
                    uint256 value = grid[x+12-4*y]; 
                    if (value == 0) {
                        continue;
                    }
                    if (check) {
                        if (grid[x+12-4*newI] == value) {
                            grid[x+12-4*newI] += value;
                            newI++;
                            check = false;
                        } else {
                            newI++;
                            grid[x+12-4*newI] = value;
                            check = true;
                        }
                    } else {
                        grid[x+12-4*newI] = value;
                        check = true;
                    }
                }
                if (check) {
                    newI++;
                }
                if (newI < 4) {
                    moved = true;
                    for ( ;newI < 4; newI++){
                        grid[x+12-4*newI] = 0;
                    }
                }
            }
        } else if (direction == Direction.Left) {
            for (uint x = 0; x < 4; x++) {
                uint256 newI = 0;
                bool check = false;
                for (uint y = 0; y < 4; y++) {
                    uint256 value = grid[x*4+y];
                    if (value == 0) {
                        continue;
                    }
                    if (check) {
                        if (grid[x*4+newI] == value) {
                            grid[x*4+newI] += value;
                            newI++;
                            check = false;
                        } else {
                            newI++;
                            grid[x*4+newI] = value;
                            check = true;
                        }
                    } else {
                        grid[x*4+newI] = value;
                        check = true;
                    }
                }
                if (check) {
                    newI++;
                }
                if (newI < 4) {
                    moved = true;
                    for ( ;newI < 4; newI++){
                        grid[x*4+newI] = 0;
                    }
                }
            }
        } else if (direction == Direction.Right) {
            for (uint x = 0; x < 4; x++) {
                uint256 newI = 0;
                bool check = false;
                for (uint y = 0; y < 4; y++) {
                    uint256 value = grid[x*4+3-y];
                    if (value == 0) {
                        continue;
                    }
                    if (check) {
                        if (grid[x*4+3-newI] == value) {
                            grid[x*4+3-newI] += value;
                            newI++;
                            check = false;
                        } else {
                            newI++;
                            grid[x*4+3-newI] = value;
                            check = true;
                        }
                    } else {
                        grid[x*4+3-newI] = value;
                        check = true;
                    }
                }
                if (check) {
                    newI++;
                }
                if (newI < 4) {
                    moved = true;
                    for ( ;newI < 4; newI++){
                        grid[x*4+3-newI] = 0;
                    }
                }
            }
        } 


        return true;
       
    }



    // mint NFT if have 2048
    function mint() public {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "max");
        address account = msg.sender;
        uint256[16] storage grid =  grids[account];
        for (uint256 i = 0; i < 16; i++) {
            if (grid[i] >= MINT_THRESHOLD) {
                uint256 tokenId = _tokenIdCounter.current();
                _tokenIdCounter.increment();
                _safeMint(account, tokenId);

                uint256[16] storage grid2048 = grids2048[tokenId];
                for (uint256 j = 0; j < 16; i++) {
                    (grid2048[j], grid[j]) = (grid[j], 0);
                }
            }
        }
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // TODO:
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
