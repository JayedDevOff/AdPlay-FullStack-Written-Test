
public record CustomerOrderSummary(
    long CustomerId,
    int TotalOrders,
    decimal HighestOrderAmount,
    decimal AverageOrderAmount,
    DateTime? LatestOrderDate);

var summaries = await dbContext.Customers
    .AsNoTracking()
    .Select(customer => new CustomerOrderSummary(
        customer.Id,
        customer.Orders.Count(),
        customer.Orders.Max(order => (decimal?)order.Amount) ?? 0m,
        customer.Orders.Average(order => (decimal?)order.Amount) ?? 0m,
        customer.Orders.Max(order => (DateTime?)order.OrderDate)))
    .ToListAsync(cancellationToken);
