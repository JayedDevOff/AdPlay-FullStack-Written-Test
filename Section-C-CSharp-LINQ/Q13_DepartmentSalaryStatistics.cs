
public record DepartmentSalaryStatistics(
    long DepartmentId,
    decimal HighestSalary,
    decimal LowestSalary,
    decimal AverageSalary,
    decimal MedianSalary);

var employees = await dbContext.Employees
    .AsNoTracking()
    .Where(e => e.Salary != null)
    .Select(e => new
    {
        e.DepartmentId,
        Salary = e.Salary!.Value
    })
    .ToListAsync(cancellationToken);

var statistics = employees
    .GroupBy(e => e.DepartmentId)
    .Select(group =>
    {
        var salaries = group
            .Select(e => e.Salary)
            .OrderBy(salary => salary)
            .ToList();

        var count = salaries.Count;

        var median = count % 2 == 1
            ? salaries[count / 2]
            : (salaries[count / 2 - 1] + salaries[count / 2]) / 2m;

        return new DepartmentSalaryStatistics(
            group.Key,
            salaries[^1],
            salaries[0],
            salaries.Average(),
            median);
    })
    .ToList();
