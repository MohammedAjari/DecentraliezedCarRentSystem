// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
contract carRent{

    struct carDetails{
        string CompanyName;
        string modelName;
        string modelYear;
        uint rentPrice;
        address currentRenter;
        uint totalRenters; // This will help the customer that how many customers have rented this car
        bool isRented;
    }

    event carBooked(string message);

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
        carDetails memory cd = carDetails(_companyName , _modelName , _modelYear , _rentPrice , owner , 0, false);
        carList[carCounter] = cd;
        carCounter++;
    } 

    function bookCar(uint id , uint noOfDays) public payable {
        // This function is used to book the car
        require(checkCarAvailabilty(id) , "Car is already rented");
        carDetails storage cd = carList[id];
        require(noOfDays > 0 , "Enter valid days value");
        uint totalRentPrice = cd.rentPrice * noOfDays;
        require(msg.value >= totalRentPrice , "Please provide complete rent");
        address payable carOwner = payable(owner);
        carOwner.transfer(totalRentPrice);
        cd.currentRenter = msg.sender;
        cd.isRented = true;
        cd.totalRenters = cd.totalRenters + 1;
    }




}
