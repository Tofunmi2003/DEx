// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;




interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract SimpleDEX {

    address public tokenA;
    address public tokenB;
    uint public reserveA;
    uint public reserveB;

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(uint amountA, uint amountB) external {
        // Ensure the provided amounts have the correct ratio
        require(amountA * reserveB == amountB * reserveA, "Invalid input amount"); 

        // Transfer tokens from the user to the contract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        // Update reserves
        reserveA += amountA;
        reserveB += amountB;
    }

    function swap(uint amountAIn) external returns (uint amountBOut) {
        // Calculate the amount of tokenB to be received
        amountBOut = getAmountOut(amountAIn);

        // Transfer tokenA from the user to the contract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountAIn);

        // Transfer tokenB to the user
        IERC20(tokenB).transfer(msg.sender, amountBOut);

        // Update reserves
        reserveA += amountAIn;
        reserveB -= amountBOut;

        return amountBOut;
    }

    function getAmountOut(uint amountIn) public view returns (uint amountOut) {
        uint amountInWithFee = amountIn * 997; // 0.3% fee
        uint numerator = amountInWithFee * reserveB;
        uint denominator = (reserveA * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }
}