/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here:
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract SimpleBank {

    //
    // State variables
    //

    /* Fill in the keyword. Hint: We want to protect our users balance from other contracts*/
    mapping (address => uint) internal balances;

    /* Fill in the keyword. We want to create a getter function and allow contracts to be able to see if a user is enrolled.  */
    mapping (address => bool) public enrolled;

    /* Let's make sure everyone knows who owns the bank. Use the appropriate keyword for this*/
    address public owner;
    address[] public customers;
    uint public customerCount;
    uint public transactionCount;
    mapping (uint => Transaction) public transactions;

    struct Transaction {
      address accountAddress;
      uint transactionAmount;
      bytes transactionType;
      bool executed;
    }

    //
    // Events - publicize actions to external listeners
    //

    /* Add an argument for this event, an accountAddress */
    event LogEnrolled(address indexed accountAddress);

    /* Add 2 arguments for this event, an accountAddress and an amount */
    event LogDepositMade(address indexed accountAddress, uint amount);

    /* Create an event called LogWithdrawal */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance */
    event LogWithdrawal(address indexed accountAddress, uint withdrawAmount, uint newBalance);

    //
    // Functions
    //

    /* Use the appropriate global variable to get the sender of the transaction */
    constructor() public {
        /* Set the owner to the creator of this contract */
           owner = msg.sender;
    }

    /// @notice Get balance
    /// @return The balance of the user
    // A SPECIAL KEYWORD prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function balance() public view returns (uint) {
        /* Get the balance of the sender of this transaction */

        require(enrolled[msg.sender]);
        uint accountBalance = balances[msg.sender];
        return accountBalance;
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool){
        /// check if enrolling customer already is an customer of the bank
        if (enrolled[msg.sender] == false) {
            customers.push(msg.sender) -1;
            enrolled[msg.sender] = true;
            balances[msg.sender] = 0;
            customerCount += 1;
            emit LogEnrolled(msg.sender);
            return true;
        }
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // Add the appropriate keyword so that this function can receive ether
    // Use the appropriate global variables to get the transaction sender and value
    // Emit the appropriate event
    function deposit() public payable returns (uint) {
        /* Add the amount to the user's balance, call the event associated with a deposit,
          then return the balance of the user */
        require(enrolled[msg.sender]);
        require(msg.value > 0);
        uint transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            accountAddress: msg.sender,
            transactionAmount: msg.value,
            transactionType: "Deposit",
            executed: true
        });
        balances[msg.sender] += msg.value;
        transactionCount += 1;
        emit LogDepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event
    function withdraw(uint withdrawAmount) public payable returns (uint) {
        /* If the sender's balance is at least the amount they want to withdraw,
           Subtract the amount from the sender's balance, and try to send that amount of ether
           to the user attempting to withdraw.
           return the user's balance.*/
        require(enrolled[msg.sender]);
        require(balances[msg.sender] + withdrawAmount >= balances[msg.sender]);
        uint transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            accountAddress: msg.sender,
            transactionAmount: withdrawAmount,
            transactionType: "Withdrawal",
            executed: true
        });
        balances[msg.sender] -= withdrawAmount;
        transactionCount += 1;
        emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
        return balances[msg.sender];
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function fallback() external pure {
        revert();
    }
}
