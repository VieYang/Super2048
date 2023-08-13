// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Super2048 is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping (address => uint256[16]) public grids;
    mapping (uint256 => uint256[16]) public grids2048;

    // Game
    bytes32 public seed;

    enum Direction { Up, Down, Left, Right }

    // mint
    uint256 public constant MAX_SUPPLY = 42096;
    uint256 public constant MINT_THRESHOLD = 2048;

    // event
    event GameStarted(address indexed account);
    event RandomGrid(address indexed account, bytes32 seed);
    event Move(address indexed account, Direction indexed direction);
    event EmptyGame(address indexed account);

    constructor() ERC721("Super2048", "2048") {
        seed = keccak256(abi.encodePacked(address(this), block.number, block.timestamp, msg.sender));
    }

    function getGrid(address account) public view returns(uint256[16] memory) {
        return grids[account];
    }

    function getGrid2048(uint256 tokenId) public view returns(uint256[16] memory) {
        return grids2048[tokenId];
    }

    function startGame() public {
        address account = msg.sender;
        bool started = false;
        for (uint256 i = 0; i < 16; i++) {
            if (grids[account][i] != 0) {
                started = true;
                break;
            }
        }
        require(!started, "game started");

        emit GameStarted(account);

        _randomGrid(account);
    }

    function forceStartGame() public {
        address account = msg.sender;
        for (uint256 i = 0; i < 16; i++) {
            grids[account][i] = 0;
        }

        emit EmptyGame(account);
        emit GameStarted(account);

        _randomGrid(account);
    }

    function _randomGrid(address account) internal {
        bytes32 seed0 = keccak256(abi.encodePacked(seed, address(this), block.number, block.timestamp, account));
        uint256 i = uint256(seed0) % 16;
        seed = keccak256(abi.encodePacked(seed0));
        uint256 j = uint256(seed) % 16;
        seed = keccak256(abi.encodePacked(seed));
        uint256 m = uint256(seed) % 16;
        seed = keccak256(abi.encodePacked(seed));
        uint256 n = uint256(seed) % 16;

        if (i == j) {
            j = (j + 1)%16;
        }
       
        uint256[16] storage grid =  grids[account];
        uint256 k = 0;
        for (k = 0; k < 16; k++) {
            if (grid[(k+i)%16] == 0) {
                if (m == 6 || m == 9) {
                    grid[(k+i)%16] = 4;
                } else {
                    grid[(k+i)%16] = 2;
                }
                break;
            }
        }
        // if (k == 16) {
        //     // no need to add, and may not end
        // }
       
        k = 0;
        for (k = 0; k < 16; k++) {
            if (grid[(k+j)%16] == 0) {
                if (n == 6 || n == 9) {
                    grid[(k+j)%16] = 4;
                } else {
                    grid[(k+j)%16] = 2;
                }
                break ;
            }
        }
        // if (k == 16) {
        //     // no need to add, and may not end
        // }

        emit RandomGrid(account, seed0);
    }

    // game can be start from move, we don't care the status of start or stop
    // event EmptyGame or GameStarted is just for offchain calc
    function move(Direction direction) public {
        if (_moveCore(direction)) {
            _randomGrid(msg.sender);
        }
    }

    function _moveCore(Direction direction) internal returns (bool moved){
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
        bool canMint = false;
        for (uint256 i = 0; i < 16; i++) {
            if (grid[i] >= MINT_THRESHOLD) {
                canMint = true;
                break;
                
            }
        }

        require(canMint, "not threshold");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(account, tokenId);

        uint256[16] storage grid2048 = grids2048[tokenId];
        for (uint256 j = 0; j < 16; j++) {
            (grid2048[j], grid[j]) = (grid[j], 0);
        }

        emit EmptyGame(account);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function getImageSvg(uint256 tokenId) public view returns (string memory) {
        uint256[16] memory grid2048 = grids2048[tokenId]; 

        bytes memory image1 = abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 562 562"><style>.b { fill: #776e65; font-family: serif; font-size: 32px; }</style><rect x="10" y="10" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="74" y="74" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[0] == 0 ? '' : Strings.toString(grid2048[0]) ,
                '</text><rect x="148" y="10" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="212" y="74" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[1] == 0 ? '' : Strings.toString(grid2048[1]),
                '</text><rect x="286" y="10" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="350" y="74" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[2] == 0 ? '' : Strings.toString(grid2048[2]),
                '</text><rect x="424" y="10" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="488" y="74" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[3] == 0 ? '' : Strings.toString(grid2048[3]));
        bytes memory image2 = abi.encodePacked(
                '</text><rect x="10" y="148" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="74" y="212" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[4] == 0 ? '' : Strings.toString(grid2048[4]),
                '</text><rect x="148" y="148" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="212" y="212" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[5] == 0 ? '' : Strings.toString(grid2048[5]),
                '</text><rect x="286" y="148" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="350" y="212" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[6] == 0 ? '' : Strings.toString(grid2048[6]),
                '</text><rect x="424" y="148" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="488" y="212" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[7] == 0 ? '' : Strings.toString(grid2048[7]));
        bytes memory image3 = abi.encodePacked(
                '</text><rect x="10" y="286" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="74" y="350" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[8] == 0 ? '' : Strings.toString(grid2048[8]),
                '</text><rect x="148" y="286" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="212" y="350" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[9] == 0 ? '' : Strings.toString(grid2048[9]),
                '</text><rect x="286" y="286" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="350" y="350" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[10] == 0 ? '' : Strings.toString(grid2048[10]),
                '</text><rect x="424" y="286" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="488" y="350" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[11] == 0 ? '' : Strings.toString(grid2048[11]));
        bytes memory image4 = abi.encodePacked(
                '</text><rect x="10" y="424" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="74" y="488" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[12] == 0 ? '' : Strings.toString(grid2048[12]),
                '</text><rect x="148" y="424" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="212" y="488" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[13] == 0 ? '' : Strings.toString(grid2048[13]),
                '</text><rect x="286" y="424" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="350" y="488" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[14] == 0 ? '' : Strings.toString(grid2048[14]),
                '</text><rect x="424" y="424" rx="8" ry="8" width="128" height="128" fill="#eee4da" /><text x="488" y="488" class="b" dominant-baseline="middle" text-anchor="middle">',
                grid2048[15] == 0 ? '' : Strings.toString(grid2048[15]));

            string memory image = Base64.encode(abi.encodePacked(image1, image2, image3, image4, '</text></svg>'));

            return image;
    }

    /**
     * @dev token uri
     */
    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        
        string memory image = getImageSvg(tokenId);
        
        uint256[16] memory grid2048 = grids2048[tokenId]; 
        uint256[16] memory numbers;
        uint256[16] memory counts;
        uint256 uniqueCount = 0;
        uint256 sum = 0;
        for (uint256 i = 0; i < 16; i++) {
            if (grid2048[i] == 0) {
                continue ;
            }

            sum+= grid2048[i];

            bool isNewNumber = true;
            
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (grid2048[i] == numbers[j]) {
                    counts[j]++;
                    isNewNumber = false;
                    break;
                }
            }
            
            if (isNewNumber) {
                numbers[uniqueCount] = grid2048[i];
                counts[uniqueCount] = 1;
                uniqueCount++;
            }
        }
        bytes memory attributes;
        for (uint256 i = 0; i < uniqueCount; i++) {
            attributes = abi.encodePacked(attributes, 
                '{"trait_type": "', 
                Strings.toString(numbers[i]),
                '","value": "',
                Strings.toString(counts[i]),
                '"}'
                );
            if (i + 1 < uniqueCount) {
                attributes = abi.encodePacked(attributes, ',');
            }
        }

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"description":"Super2048, onchain game of 2048. Superhack of ethglobal.","image":"data:image/svg+xml;base64,',
                            image,
                            '","name":"Super2048 #',
                            Strings.toString(tokenId),
                            '","attributes":[{"display_type":"number","trait_type":"Score","value":',
                            Strings.toString(sum),
                            '},',
                            attributes,
                            ']}'
                        )
                    )
                )
            )
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
