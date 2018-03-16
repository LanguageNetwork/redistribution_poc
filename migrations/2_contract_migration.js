var NodeRelationship = artifacts.require("./NodeRelationship.sol");

module.exports = function(deployer, network) {
    console.log(network);
    console.log(deployer);
    console.log(NodeRelationship);
    deployer.deploy(NodeRelationship);
};
