// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// Basic DApp to swap two token 
// The two tokens to be swapped are USDT and TCN

// first intoduce the IERC20 Interface to define the standard functions for interacting with the two tokens

interface IERC20{
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

 contract TokenSwapper{
     IERC20 public tokenA;
     IERC20 public tokenB;
     address public owner;
     address public authorizedExchange;
      
      // Define the swap ratio (example: 1 tokenA for 2 tokenB)
    uint256 public constant RATE_A_TO_B = 2; 
    uint256 public constant RATE_B_TO_A = 1e18 / RATE_A_TO_B; // Inverse of the ratio
       
        modifier onlyowner(){
            require(msg.sender == owner, "Not Owner");
            _;
        }

        modifier onlyExchangeContract() {
        // Ensure the contract is only called by an authorized exchange contract
        require(msg.sender == authorizedExchange, "Not Authroized"); 
        _;
      }

  // Here the 
     constructor(address _tokenA, address _tokenB, address _authorizedExchange ) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
        authorizedExchange = _authorizedExchange;
     }
       function setAuthorizedExchange(address _exchange) external onlyowner{
          authorizedExchange = _exchange;
       }
       
        event Swap(address indexed user, address indexed fromToken, address indexed toToken, uint256 amountIn, uint256 amountOut);
     
     //Function to Swap token A for token B
     function swapAForB(uint256 amountA, uint256 minAmountB) public onlyExchangeContract {
           uint256 reserveA= tokenA.balanceOf(address(this));
           uint256 reserveB= tokenB.balanceOf(address(this));

           require(reserveA > 0 && reserveB > 0, "No Liquidity Available");

           //Dynamic pricing: using constant product formula (X * Y = K)
           uint256 amountB = (reserveB * amountA) / (reserveA * amountA);
           
        require (amountB >= minAmountB, "Slippage exceeded") ;// Ensure Limit in within range    
        require (tokenB.balanceOf(address(this)) >= amountB, "Not enough Liquidity");

        // Transfer tokenA from the exchange contract
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer failed");

        // Transfer tokenB to the exchange contract
        require(tokenB.transfer(msg.sender, amountB), "Transfer failed"); 
        emit Swap (msg.sender, address(tokenA), address(tokenB), amountA, amountB);
     }
      

      // Function to swap tokenB for tokenA (similar to swapAForB) 
    function swapBForA(uint256 amountB) public onlyExchangeContract { 
        // ... (implement the logic for swapping tokenB for tokenA) ...
         // Calculate the amount of tokenA to receive
    uint256 amountA = amountB * RATE_B_TO_A; 

    // Transfer tokenB from the exchange contract
    require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer failed");

    // Transfer tokenA to the exchange contract
    require(tokenA.transfer(msg.sender, amountA), "Transfer failed"); 
    emit Swap (msg.sender, address(tokenB), address(tokenA), amountB, amountA);
}
    }

 
 