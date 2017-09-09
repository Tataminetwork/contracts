pragma solidity ^0.4.11;

contract Lesson {
    uint public price;
    address public teacher;
    address public learner;
    enum State { Created, Booked, Inactive }
    State public state;

    /// set lesson price
    /// make sure it's an even number
    /// hold lesson price amount for escrow as well
    function Lesson() payable {
        teacher = msg.sender;
        price = msg.value / 2;
        require((2 * price) == msg.value);
    }

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyLearner() {
        require(msg.sender == learner);
        _;
    }

    modifier onlyTeacher() {
        require(msg.sender == teacher);
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    event Aborted();
    event LessonBookingConfirmed();
    event LessonReceived();

    /// Only teacher can abort the lesson
    /// and only before booking is confirmed
    function abort()
        onlyTeacher
        inState(State.Created)
    {
        Aborted();
        state = State.Inactive;
        teacher.transfer(this.balance);
    }

    /// Learner confirms lesson booking.
    /// Transaction has to include additional amount(lesson price) for escrow.
    function confirmLessonBooking()
        inState(State.Created)
        condition(msg.value == (2 * price))
        payable
    {
        LessonBookingConfirmed();
        learner = msg.sender;
        state = State.Booked;
    }

    /// Only learner can confirm receiving of the lesson
    /// release escrow for teacher and learner
    /// inactivate the contract
    function confirmLessonReceived()
        onlyLearner
        inState(State.Booked)
    {
        LessonReceived();
        state = State.Inactive;
        learner.transfer(price);
        teacher.transfer(this.balance);
    }
}
