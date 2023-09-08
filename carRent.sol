// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
contract carRent{

    struct carDetails{
        string CompanyName;
        string modelName;
        string modelYear;
        uint rentPrice; // per day
        address currentRenter;
        uint totalRenters; // This will help the customer that how many customers have rented this car
        bool isRented;
        uint avalaibleAfter; // It shows that when the car will be avalaible again for rent
    }

    event carBooked(uint _id, address _renter , uint _noofDays , uint _avalaibleAfter);
    event amountTransferred(address indexed recipient , uint amount );
    event DebugValues(uint, uint,uint);
    event rentExtended(uint _id,address _renter,uint _noofDays,uint _avalaibleAfter);
    uint carCounter;
    // We create the array to store the names of the customers so that we can give some discount to them in future.
    address[] public regularCustomers;
    // The below mapping will store the list of the cars 
    mapping(uint => carDetails) public carList;
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can do this action");
        _;   
    }
    modifier ExceptOwner(){
        require(msg.sender != owner , "Owner can't do this action");
        _;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    }

    function checkCarAvailabilty(uint id) public view returns(bool){
        carDetails memory cd = carList[id];
        if(cd.isRented)
            return false;
        return true;
    }

    function addNewCar(string memory _companyName, string memory _modelName,string memory _modelYear,uint _rentPrice) public onlyOwner{
        require(_rentPrice > 0 ether , "Enter valid amount");
        carDetails memory cd = carDetails(_companyName , _modelName , _modelYear , _rentPrice , owner , 0, false,0);
        carList[carCounter] = cd;
        carCounter++;
    } 

    function checkCarDetails(uint _id) public view returns(carDetails memory){
        require(_id >= 0 && _id <= carCounter , "Enter valid id");
        return (carList[_id]);
    }
    
    
    function rentExtension(uint _id , uint _noofDays) public payable ExceptOwner{
        require(!checkCarAvailabilty(_id) , "Car is not rented yet");
        carDetails storage cd = carList[_id];
        require(cd.isRented , "Car is not rented yet");
        require(cd.currentRenter == msg.sender , "Only current renter can do rent extension functionality");
        // The below line ensures that the rent can be only extended if the rent time has not ended
        require(block.timestamp < cd.avalaibleAfter , "You have to rent the car again, You can't do this at current time");
        address payable carOwner = payable(owner);
        uint totalRent = (cd.rentPrice * _noofDays);
        require(msg.value >= totalRent, "Please provide complete rent");
        carOwner.transfer(msg.value);
        emit amountTransferred(carOwner, totalRent);
        uint unrentedAfter = cd.avalaibleAfter + (_noofDays * 1 days);
        cd.avalaibleAfter = unrentedAfter;
        emit rentExtended(_id, msg.sender, _noofDays, unrentedAfter);
    }

    function bookCar(uint _id , uint _noOfDays) public payable ExceptOwner{
        // This function is used to book the car
        require(checkCarAvailabilty(_id) , "Car is already rented");
        carDetails storage cd = carList[_id];
        require(_noOfDays > 0 , "Enter valid days value");
         // Calculate the total rent based on the daily rent price and number of days
        uint totalRent = (cd.rentPrice * _noOfDays);
        uint unrentedAfter = block.timestamp + (_noOfDays * 1 days);
        // Ensure that the amount sent is at least equal to the total rent
        require(msg.value >= totalRent, "Please provide complete rent");
        address payable carOwner = payable(owner);
        emit DebugValues(_noOfDays, cd.rentPrice, msg.value);
        carOwner.transfer(msg.value);
        emit amountTransferred(carOwner , totalRent);
        cd.currentRenter = msg.sender;
        cd.isRented = true;
        cd.totalRenters +=  1;
        cd.avalaibleAfter = unrentedAfter;
        emit carBooked(_id , msg.sender,_noOfDays , unrentedAfter);
    }

}
