pragma solidity ^0.8.0;
import "./Item.sol";
import "./Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract ItemManager is Ownable {

enum SupplyChainState{Created, Paid, Delivered }
 struct S_Item{
     Item _item;
     string identifier;
     uint itemPrice;
     SupplyChainState state;
 }
    mapping(uint=> S_Item) public items;
    uint _itemIndex;
    event SupplyChainStep(uint itemindex, uint _step, address itemAddress);

    function createItem(string memory name, uint itemPrice) public onlyOwner {
        Item item= new Item(this, itemPrice, _itemIndex);
        items[_itemIndex]._item= item;

        items[_itemIndex].identifier = name;
        items[_itemIndex].itemPrice= itemPrice;
        items[_itemIndex].state= SupplyChainState.Created;
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex].state), address(item));
        _itemIndex++;

    }

    function triggerPayment(uint itemIndex) public payable {
        require( items[itemIndex].itemPrice == msg.value ,"Only full Payments accepted");
        require(items[itemIndex].state == SupplyChainState.Created , "Item is furthur in the chain");
        items[itemIndex].state= SupplyChainState.Paid;

        emit SupplyChainStep(itemIndex, uint(items[itemIndex].state), address(items[itemIndex]._item));


    }
    function triggerDelivery(uint itemIndex) public onlyOwner {
        require(items[itemIndex].state == SupplyChainState.Paid , "Item is furthur in the chain");
        items[itemIndex].state= SupplyChainState.Delivered;

        emit SupplyChainStep(itemIndex, uint(items[itemIndex].state),address(items[itemIndex]._item));

    }

}