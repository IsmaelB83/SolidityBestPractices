const Employees = artifacts.require('Employees')
const EmployeesApp = artifacts.require('EmployeesApp')

contract('Employees', accounts => {

  it('can register Employee, add sale and calculate bonus', async () => {
        const employees = await Employees.deployed()
        const employeesApp = await EmployeesApp.deployed()
        await employees.authorizeContract(employeesApp.address)
        // ARRANGE
        let employee = { 
            id: 'test1',
            isAdmin: false,
            address: accounts[0]
        };
        let sale = 400;
        let expectedBonus = parseInt(sale * 0.07);
        // ACT
        await employees.registerEmployee(employee.id, employee.isAdmin, employee.address);
        await employeesApp.addSale(employee.id, 400);
        let bonus = await employees.getEmployeeBonus(employee.id);
        // ASSERT
        assert.equal(bonus.toNumber(), expectedBonus, "Calculated bonus is incorrect incorrect");
  });
});