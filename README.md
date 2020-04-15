# Decentralised Grading System
> This project was made as a part of EE 465 - **Cryptocurrency and Blockchain Technology** course in Autumn 2019 at Indian Institute of Technology (IIT) Bombay, India.

## Details

The project is a direct implementation of the marking and grading system followed at IIT Bombay, on a blockchain backend. We used blockchain to mitigate some of the most common mistakes committed by the teaching assistants and professors. The integrity and transpiracy provided by the blockchain helps to know the exact marks allotted to a student, which isn't possible in the case of a normal paper and google sheet scenario. Any student can get to know the exact amount of marks allocated to him, any increment promised to him has been done or not, also anyone can prove that the grades that are awarded at the end of an academic year are impartial to anyone.

The entire functionality is written in javascript. Truffle is used to migrate and compile the smart contracts written in solidity. NodeJS is used to create a backend server to deploy the smart contract. We used bootstrap and basic html to create a front end to the DApp interface.

## Future Work

We can ease the usage of the interface by adding some very desirable functionalities like, uploading the marks as a csv file rather than text format, directly upload the final grades to anywhere necessary without any tampering, etc.

A very important functionality is privacy. Any student should not have access to all of his peers. But rather he should be able to prove and convince himself that every calculation done is correct. We can provide this functionality by adding ring signature structures to hide the marks. This way anyone can do a proof of correctness without knowing the exact marks of anyone(with range proofs). Please refer, https://github.com/kendricktan/heiswap-dapp.

## Authors

* Saiteja Talluri - [saiteja-talluri](https://github.com/saiteja-talluri)
* Pavan Bhargav - [Pa1Bhargav](https://github.com/Pa1Bhargav)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

1. DApp tutorial by DApp university. (https://www.dappuniversity.com/articles/blockchain-app-tutorial)
2. Bootstrap basics (https://getbootstrap.com/docs/4.0/components/forms/)
