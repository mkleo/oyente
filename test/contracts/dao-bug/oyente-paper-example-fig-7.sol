// Source: Oyente paper (http://www.comp.nus.edu.sg/~loiluu/papers/oyente.pdf, Figure 7)
// Class: "DAO bug" (re-entrancy)
// Description: recursively calling withdrawBalance() allows for repeatedly sending balance since
// userBalances is zeroed after the call

contract SendBalance {
  mapping (address => uint) userBalances;
  bool withdrawn = false;
  function getBalance(address u) constant returns (uint) {
    return userBalances[u];
  }

  function addToBalance() {
    userBalances[msg.sender] += msg.value;
  }

  function withdrawBalance() {
    if (!(msg.sender.call.value(userBalances[msg.sender])())) {
      throw;
    }

    userBalances[msg.sender] = 0;
  }
}
