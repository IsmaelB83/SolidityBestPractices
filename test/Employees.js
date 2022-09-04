const Employees = artifacts.require('Employees')

contract('Employees', accounts => {

  it('can register Employee, add sale and calculate bonus', async () => {
        const employees = await Employees.deployed()
        // ARRANGE
        let employee = { 
            id: 'test1',
            isAdmin: false,
            address: config.testAddresses[0]
        };
        let sale = 400;
        let expectedBonus = parseInt(sale * 0.07);
        // ACT
        await employees.registerEmployee(employee.id, employee.isAdmin, employee.address);
        await employees.addSale(employee.id, 400);
        let bonus = await employees.getEmployeeBonus.call(employee.id);
        // ASSERT
        assert.equal(bonus.toNumber(), expectedBonus, "Calculated bonus is incorrect incorrect");
  });
});