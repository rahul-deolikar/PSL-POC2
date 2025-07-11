using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
});

// Add rate limiting
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.Request.Headers.Host.ToString(),
            factory: partition => new FixedWindowRateLimiterOptions
            {
                AutoReplenishment = true,
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1)
            }));
});

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRateLimiter();
app.UseCors("AllowAll");
app.UseAuthorization();

// Health check endpoint
app.MapHealthChecks("/health");

// Hello World endpoints
app.MapGet("/", () => new
{
    message = "Hello World from .NET Core API!",
    version = "1.0.0",
    technology = ".NET Core 8.0 Web API",
    timestamp = DateTime.UtcNow
});

app.MapGet("/api/hello", (string? name) => new
{
    message = $"Hello, {name ?? "World"}!",
    technology = ".NET Core",
    timestamp = DateTime.UtcNow
});

app.MapPost("/api/hello", (HelloRequest request) => new
{
    message = $"Hello, {request.Name ?? "World"}! (POST request)",
    technology = ".NET Core",
    timestamp = DateTime.UtcNow,
    received = request
});

app.MapControllers();

app.Run();

public record HelloRequest(string? Name);