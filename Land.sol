//pragma solidity ^0.8.12;
//pragma solidity >= 0.8.0;
pragma solidity >=0.5.2;
pragma experimental ABIEncoderV2;

//import "@openzeppelin/contracts/utils/Strings.sol";
contract Land {
    struct owner {
        address id;
        string name;
        uint age;
        string idNo;
        string PANPin;
        string landsOwned;
        string document;
    }

    struct Landreg {
        uint id;
        uint area;
        string city;
        string state;
        uint landPrice;
        uint propertyPID;
        uint physicalSurveyNumber;
        string ipfsHash;
        string document;
    }

    struct Buyer {
        address id;
        string name;
        uint age;
        string city;
        string idNo;
        string PANPin;
        string document;
        string email;
    }

    struct Seller {
        address id;
        string name;
        uint age;
        string idNo;
        string PANPin;
        string landsOwned;
        string document;
    }

    struct LandInspector {
        uint id;
        string name;
        uint age;
        string designation;
    }

    struct LandRequest {
        uint reqId;
        address sellerId;
        address buyerId;
        uint landId;
        // bool requestStatus;
        // bool requested;
    }

    //key value pairs
    mapping(uint => Landreg) public lands;
    mapping(uint => LandInspector) public InspectorMapping;
    mapping(address => Seller) public SellerMapping;
    mapping(address => Buyer) public BuyerMapping;
    mapping(uint => LandRequest) public RequestsMapping;

    mapping(address => bool) public RegisteredAddressMapping;
    mapping(address => bool) public RegisteredSellerMapping;
    mapping(address => bool) public RegisteredBuyerMapping;
    mapping(address => bool) public SellerVerification;
    mapping(address => bool) public SellerRejection;
    mapping(address => bool) public BuyerVerification;
    mapping(address => bool) public BuyerRejection;
    mapping(uint => bool) public LandVerification;
    mapping(uint => address) public LandOwner;
    mapping(uint => bool) public RequestStatus;
    mapping(uint => bool) public RequestedLands;
    mapping(uint => bool) public PaymentReceived;
    mapping(uint => owner[]) public land_id_to_ownermap;

    address public Land_Inspector;
    address[] public sellers;
    address[] public buyers;
    owner[] public heirarchy_arr;

    uint public landsCount;
    uint public inspectorsCount;
    uint public sellersCount;
    uint public buyersCount;
    uint public requestsCount;

    event Registration(address _registrationId);
    event AddingLand(uint indexed _landId);
    event Landrequested(address _sellerId);
    event requestApproved(address _buyerId);
    event Verified(address _id);
    event Rejected(address _id);

    constructor() public {
        Land_Inspector = msg.sender;
        addLandInspector("Inspector 1", 45, "Tehsil Manager");
    }

    function concat(
        string memory a,
        string memory b,
        string memory c
    ) public pure returns (string memory) {
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = bytes(c);
        string memory abc = new string(ba.length + bb.length + bc.length);
        bytes memory babc = bytes(abc);
        uint k = 0;
        for (uint i = 0; i < ba.length; i++) babc[k++] = ba[i];
        for (uint i = 0; i < bb.length; i++) babc[k++] = bb[i];
        for (uint i = 0; i < bc.length; i++) babc[k++] = bc[i];
        return string(babc);
    }

    function addLandInspector(
        string memory _name,
        uint _age,
        string memory _designation
    ) private {
        inspectorsCount++;
        InspectorMapping[inspectorsCount] = LandInspector(
            inspectorsCount,
            _name,
            _age,
            _designation
        );
    }

    function getLandsCount() public view returns (uint) {
        return landsCount;
    }

    function getBuyersCount() public view returns (uint) {
        return buyersCount;
    }

    function getSellersCount() public view returns (uint) {
        return sellersCount;
    }

    function getRequestsCount() public view returns (uint) {
        return requestsCount;
    }

    function getArea(uint i) public view returns (uint) {
        return lands[i].area;
    }

    function getCity(uint i) public view returns (string memory) {
        return lands[i].city;
    }

    function getState(uint i) public view returns (string memory) {
        return lands[i].state;
    }

    // function getStatus(uint i) public view returns (bool) {
    //     return lands[i].verificationStatus;
    // }
    function getPrice(uint i) public view returns (uint) {
        return lands[i].landPrice;
    }

    function getPID(uint i) public view returns (uint) {
        return lands[i].propertyPID;
    }

    function getSurveyNumber(uint i) public view returns (uint) {
        return lands[i].physicalSurveyNumber;
    }

    function getImage(uint i) public view returns (string memory) {
        return lands[i].ipfsHash;
    }

    function getDocument(uint i) public view returns (string memory) {
        return lands[i].document;
    }

    function getLandOwner(uint id) public view returns (address) {
        return LandOwner[id];
    }

    function verifySeller(address _sellerId) public {
        require(isLandInspector(msg.sender));

        SellerVerification[_sellerId] = true;
        emit Verified(_sellerId);
    }

    function rejectSeller(address _sellerId) public {
        require(isLandInspector(msg.sender));

        SellerRejection[_sellerId] = true;
        emit Rejected(_sellerId);
    }

    function verifyBuyer(address _buyerId) public {
        require(isLandInspector(msg.sender));

        BuyerVerification[_buyerId] = true;
        emit Verified(_buyerId);
    }

    function rejectBuyer(address _buyerId) public {
        require(isLandInspector(msg.sender));

        BuyerRejection[_buyerId] = true;
        emit Rejected(_buyerId);
    }

    function verifyLand(uint _landId) public {
        require(isLandInspector(msg.sender));

        LandVerification[_landId] = true;
    }

    function isLandVerified(uint _id) public view returns (bool) {
        if (LandVerification[_id]) {
            return true;
        }
    }

    function isVerified(address _id) public view returns (bool) {
        if (SellerVerification[_id] || BuyerVerification[_id]) {
            return true;
        }
    }

    function isRejected(address _id) public view returns (bool) {
        if (SellerRejection[_id] || BuyerRejection[_id]) {
            return true;
        }
    }

    function isSeller(address _id) public view returns (bool) {
        if (RegisteredSellerMapping[_id]) {
            return true;
        }
    }

    function isLandInspector(address _id) public view returns (bool) {
        if (Land_Inspector == _id) {
            return true;
        } else {
            return false;
        }
    }

    function isBuyer(address _id) public view returns (bool) {
        if (RegisteredBuyerMapping[_id]) {
            return true;
        }
    }

    function isRegistered(address _id) public view returns (bool) {
        if (RegisteredAddressMapping[_id]) {
            return true;
        }
    }

    function addLand(
        uint _area,
        string memory _city,
        string memory _state,
        uint landPrice,
        uint _propertyPID,
        uint _surveyNum,
        string memory _ipfsHash,
        string memory _document
    ) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
        landsCount++;
        lands[landsCount] = Landreg(
            landsCount,
            _area,
            _city,
            _state,
            landPrice,
            _propertyPID,
            _surveyNum,
            _ipfsHash,
            _document
        );
        LandOwner[landsCount] = msg.sender;
        string memory name;
        uint age;
        string memory idNo;
        string memory PANPin;
        string memory landsOwned;
        string memory document;
        (name, age, idNo, PANPin, landsOwned, document) = getSellerDetails(
            msg.sender
        );
        owner memory newOwner = owner({
            id: msg.sender,
            name: name,
            age: age,
            idNo: idNo,
            PANPin: PANPin,
            landsOwned: landsOwned,
            document: document
        });
        land_id_to_ownermap[landsCount].push(newOwner);

        // emit AddingLand(landsCount);
    }

    //registration of seller
    function registerSeller(
        string memory _name,
        uint _age,
        string memory _idNo,
        string memory _PANPin,
        string memory _landsOwned,
        string memory _document
    ) public {
        //require that Seller is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredSellerMapping[msg.sender] = true;
        sellersCount++;
        SellerMapping[msg.sender] = Seller(
            msg.sender,
            _name,
            _age,
            _idNo,
            _PANPin,
            _landsOwned,
            _document
        );
        sellers.push(msg.sender);
        emit Registration(msg.sender);
    }

    function updateSeller(
        string memory _name,
        uint _age,
        string memory _idNo,
        string memory _PANPin,
        string memory _landsOwned
    ) public {
        //require that Seller is already registered
        require(
            RegisteredAddressMapping[msg.sender] &&
                (SellerMapping[msg.sender].id == msg.sender)
        );

        SellerMapping[msg.sender].name = _name;
        SellerMapping[msg.sender].age = _age;
        SellerMapping[msg.sender].idNo = _idNo;
        SellerMapping[msg.sender].PANPin = _PANPin;
        SellerMapping[msg.sender].landsOwned = _landsOwned;
    }

    function getSeller() public view returns (address[] memory) {
        return (sellers);
    }

    function getSellerDetails(
        address i
    )
        public
        view
        returns (
            string memory,
            uint,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        return (
            SellerMapping[i].name,
            SellerMapping[i].age,
            SellerMapping[i].idNo,
            SellerMapping[i].PANPin,
            SellerMapping[i].landsOwned,
            SellerMapping[i].document
        );
    }

    function registerBuyer(
        string memory _name,
        uint _age,
        string memory _city,
        string memory _idNo,
        string memory _PANPin,
        string memory _document,
        string memory _email
    ) public {
        //require that Buyer is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredBuyerMapping[msg.sender] = true;
        buyersCount++;
        BuyerMapping[msg.sender] = Buyer(
            msg.sender,
            _name,
            _age,
            _city,
            _idNo,
            _PANPin,
            _document,
            _email
        );
        buyers.push(msg.sender);

        emit Registration(msg.sender);
    }

    function updateBuyer(
        string memory _name,
        uint _age,
        string memory _city,
        string memory _idNo,
        string memory _email,
        string memory _PANPin
    ) public {
        //require that Buyer is already registered
        require(
            RegisteredAddressMapping[msg.sender] &&
                (BuyerMapping[msg.sender].id == msg.sender)
        );

        BuyerMapping[msg.sender].name = _name;
        BuyerMapping[msg.sender].age = _age;
        BuyerMapping[msg.sender].city = _city;
        BuyerMapping[msg.sender].idNo = _idNo;
        BuyerMapping[msg.sender].email = _email;
        BuyerMapping[msg.sender].PANPin = _PANPin;
    }

    function getBuyer() public view returns (address[] memory) {
        return (buyers);
    }

    function getBuyerDetails(
        address i
    )
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            uint,
            string memory
        )
    {
        return (
            BuyerMapping[i].name,
            BuyerMapping[i].city,
            BuyerMapping[i].PANPin,
            BuyerMapping[i].document,
            BuyerMapping[i].email,
            BuyerMapping[i].age,
            BuyerMapping[i].idNo
        );
    }

    function requestLand(address _sellerId, uint _landId) public {
        require(isBuyer(msg.sender) && isVerified(msg.sender));

        requestsCount++;
        RequestsMapping[requestsCount] = LandRequest(
            requestsCount,
            _sellerId,
            msg.sender,
            _landId
        );
        RequestStatus[requestsCount] = false;
        RequestedLands[requestsCount] = true;

        emit Landrequested(_sellerId);
    }

    function getRequestDetails(
        uint i
    ) public view returns (address, address, uint, bool) {
        return (
            RequestsMapping[i].sellerId,
            RequestsMapping[i].buyerId,
            RequestsMapping[i].landId,
            RequestStatus[i]
        );
    }

    function isRequested(uint _id) public view returns (bool) {
        if (RequestedLands[_id]) {
            return true;
        }
    }

    function isApproved(uint _id) public view returns (bool) {
        if (RequestStatus[_id]) {
            return true;
        }
    }

    function approveRequest(uint _reqId) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));

        RequestStatus[_reqId] = true;
    }

    function LandOwnershipTransfer(uint _landId, address _newOwner) public {
        require(isLandInspector(msg.sender));

        LandOwner[_landId] = _newOwner;
        address id;
        string memory name;
        uint age;
        string memory city;
        string memory idNo;
        string memory PANPin;
        string memory document;
        string memory email;
        (name, city, PANPin, document, email, age, idNo) = getBuyerDetails(
            _newOwner
        );
        owner memory newowner = owner({
            id: _newOwner,
            name: name,
            age: 0,
            idNo: idNo,
            PANPin: PANPin,
            landsOwned: "land_owned",
            document: "document"
        });
        land_id_to_ownermap[landsCount].push(newowner);
    }

    function isPaid(uint _landId) public view returns (bool) {
        if (PaymentReceived[_landId]) {
            return true;
        }
    }

    function payment(address payable _receiver, uint _landId) public payable {
        PaymentReceived[_landId] = true;
        _receiver.transfer(msg.value);
    }

    function TrackLand(uint landid) public view returns (string memory) {
        uint i;
        string memory result;
        string memory data;
        for (i = 0; i < land_id_to_ownermap[landid].length; i++) {
            {
                data = concat(
                    land_id_to_ownermap[landid][i].idNo,
                    ":",
                    land_id_to_ownermap[landid][i].name
                );
                result = concat(result, ",", data);
            }
        }
        return (result);
    }
}
