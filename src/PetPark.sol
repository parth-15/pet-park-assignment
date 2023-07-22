//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
}

enum Gender {
    Male,
    Female
}

struct BorrowInfo {
    Gender gender;
    AnimalType animalType;
    uint256 age;
}

contract PetPark {

    address public owner;
    AnimalType public animalType;
    Gender public gender;
    mapping(address => bool) public hasBorrowed;
    mapping(address => BorrowInfo) public borrowInfoMap;
    mapping(AnimalType => uint256) public availableCount;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function add(AnimalType _animalType, uint256 _count) external onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");
        availableCount[_animalType] += _count;
        emit Added(_animalType, _count);
    } 

    function borrow(uint256 _age, Gender _gender, AnimalType _animalType) external {
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(_age > 0, "invalid borrow age");
        require(availableCount[_animalType] > 0, "Selected animal not available");
        BorrowInfo memory info = borrowInfoMap[msg.sender];
        if (info.age != 0) {
            require(info.age == _age, "Invalid Age");
            require(info.gender == _gender, "Invalid Gender");
            require(info.animalType == AnimalType.None, "Already adopted a pet");
        }
        if (_gender == Gender.Male) {
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        }
        if (_gender == Gender.Female && _age < 40 && _animalType == AnimalType.Cat) {   
            require(false, "Invalid animal for women under 40");
        }


        availableCount[_animalType] -= 1;
        borrowInfoMap[msg.sender] = BorrowInfo({age: _age, gender: _gender, animalType: _animalType});
        hasBorrowed[msg.sender] = true;
        emit Borrowed(_animalType);


    }

    function giveBackAnimal() external{
       require(hasBorrowed[msg.sender], "No borrowed pets");
       hasBorrowed[msg.sender] = false;
       emit Returned(borrowInfoMap[msg.sender].animalType);
       availableCount[borrowInfoMap[msg.sender].animalType] += 1;
       borrowInfoMap[msg.sender].animalType = AnimalType.None;
    }

    function animalCounts(AnimalType _animalType) external view returns(uint256) {
        return availableCount[_animalType];
    }
    
}