pragma solidity ^0.8.1;
import "remix_tests.sol";
import "../contracts/PMS.sol";
import "remix_accounts.sol";
contract TestMessageCreation {
   
    PmsV1 pms;
    address acc0;
    address acc1;
    address acc2;
    address[] accs = [acc0, acc1];
    /// Initiate accounts variable
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(3); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }

    function deploy() public returns(bool) {
        pms = new PmsV1();
        return true;
    }
    
    function testSendMessage() public {
        pms.SendMessage(acc0, "hello");
        
        Assert.equal(pms.getPerAddressCounter(address(this)), 1, "Expected 1");
        Assert.equal(pms.getMessageNumberOf(address(this), 1), 1, "Expected 1" );
        Assert.equal(pms.getMessageById(1).from, address(this), "From Address mismatch");
        Assert.equal(pms.getMessageById(1).to, acc0, "To Address mismatch");
        Assert.equal(pms.getMessageById(1).content, "hello", "Content mismatch");
        Assert.equal(pms.ownerOf(1), acc0, "Owner is not the expected");
    }

    function testSendMessageAgain() public {
        pms.SendMessage(acc1, "hello1234");
        
        Assert.equal(pms.getPerAddressCounter(address(this)), 2, "Expected 2");
        Assert.equal(pms.getMessageNumberOf(address(this), 1), 1, "Expected 1" );
        Assert.equal(pms.getMessageById(2).from, address(this), "From Address mismatch");
        Assert.equal(pms.getMessageById(2).to, acc1, "To Address mismatch");
        Assert.equal(pms.getMessageById(2).content, "hello1234", "Content mismatch");
        Assert.equal(pms.ownerOf(2), acc1, "Owner is not the expected");
    }

     function testBatchSendMessageAgain() public {
        address[] memory addrs = new address[](4);
        addrs[0] = acc1;
        addrs[1] = acc1;
        addrs[2] = acc0;
        addrs[3] = acc2;
        for (uint i = 0; i < addrs.length; i++){
            pms.SendMessage(addrs[i], "Hello Boys");
        }
        Assert.equal(pms.getPerAddressCounter(address(this)), 6, "Expected 6");
        Assert.equal(pms.getMessageNumberOf(address(this), 3), 3, "Expected 3" );
        Assert.equal(pms.getMessageById(5).to, acc0, "To Address mismatch");
        Assert.equal(pms.getMessageById(6).to, acc2, "To Address mismatch");
        Assert.equal(pms.getMessageById(4).from, address(this), "From Address mismatch");
        Assert.equal(pms.getMessageById(4).content, "Hello Boys", "Content mismatch");
        Assert.equal(pms.ownerOf(2), acc1, "Owner is not the expected");
    }

    function testGetProgressiveChat() public {
        Assert.equal(pms.getChatProgressive(address(this), acc0)[0], 1, "Expected 1");
        Assert.equal(pms.getChatProgressive(address(this), acc1)[1], 2, "Expected 2");
        Assert.equal(pms.getChatProgressive(address(this), acc0)[4], 5, "Expected 5");
    }
    
    function testSubstring() public  {
        bytes memory strBytes = bytes("hello1234");
        uint startIndex = 0;
        uint endIndex = 5;
        bytes memory result = new bytes(endIndex-startIndex);
            for(uint i = startIndex; i < endIndex; i++) {
                result[i-startIndex] = strBytes[i];
            }
        Assert.equal(string(result), "hello", "Substring errored");
        strBytes = bytes("hello1234");
        startIndex = 5;
        endIndex = 9;
        result = new bytes(endIndex-startIndex);
            for(uint i = startIndex; i < endIndex; i++) {
                result[i-startIndex] = strBytes[i];
            }
        Assert.equal(string(result), "1234", "Substring errored");
     
    }
  

    
}
