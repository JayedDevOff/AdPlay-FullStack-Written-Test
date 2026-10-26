
using System.Diagnostics;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddProblemDetails();
builder.Services.AddHealthChecks();

builder.Services.AddHttpClient("ExternalService", client =>
{
    client.Timeout = TimeSpan.FromSeconds(10);
});

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        ServerVersion.AutoDetect(
            builder.Configuration.GetConnectionString("DefaultConnection")));
});

builder.Services.AddLogging(logging =>
{
    logging.AddConsole();
});

var app = builder.Build();

app.UseExceptionHandler();

app.Use(async (context, next) =>
{
    var stopwatch = Stopwatch.StartNew();
    var correlationId = context.TraceIdentifier;

    context.Response.Headers["X-Correlation-ID"] = correlationId;

    using (app.Logger.BeginScope(
        new Dictionary<string, object>
        {
            ["CorrelationId"] = correlationId
        }))
    {
        try
        {
            await next();
        }
        catch (Exception ex)
        {
            app.Logger.LogError(
                ex,
                "Request failed. Path: {Path}",
                context.Request.Path);

            throw;
        }
        finally
        {
            stopwatch.Stop();

            app.Logger.LogInformation(
                "Request completed. Path: {Path}, StatusCode: {StatusCode}, DurationMs: {DurationMs}",
                context.Request.Path,
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds);
        }
    }
});

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapHealthChecks("/health");
app.MapControllers();

app.Run();
